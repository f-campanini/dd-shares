#!/bin/bash
# Challenge 2 check - verify multiline processing is configured for legacy-monolith

set -e

CONFIG_FILE="/etc/datadog-agent/conf.d/workshop-logs.d/conf.yaml"

# Check if the config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    fail-message "Agent config file not found at $CONFIG_FILE"
    exit 1
fi

# Check if log_processing_rules is present for legacy-monolith
if ! grep -A 20 "legacy-monolith" "$CONFIG_FILE" | grep -q "log_processing_rules"; then
    fail-message "log_processing_rules not found in legacy-monolith configuration. Did you add the multiline rule via Fleet Automation?"
    exit 1
fi

# Check if multi_line type is configured
if ! grep -A 25 "legacy-monolith" "$CONFIG_FILE" | grep -q "type: multi_line"; then
    fail-message "multi_line type not found. Make sure you added 'type: multi_line' in the log_processing_rules."
    exit 1
fi

# Check if pattern is configured
if ! grep -A 25 "legacy-monolith" "$CONFIG_FILE" | grep -q "pattern:"; then
    fail-message "pattern not found in log_processing_rules. Make sure you added a pattern to match timestamp lines."
    exit 1
fi

echo "Multiline processing is correctly configured for legacy-monolith!"
echo "Java stack traces should now appear as single log entries in Datadog."
