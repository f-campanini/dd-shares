#!/bin/bash
# Challenge 3 check - verify multiline processing is configured for user-service

set -e

CONFIG_FILE="/etc/datadog-agent/conf.d/workshop-logs.d/conf.yaml"

# Check if log_processing_rules is present for user-service
if ! grep -A 15 "user-service" "$CONFIG_FILE" | grep -q "log_processing_rules"; then
    fail-message "log_processing_rules not found in user-service configuration. Did you add the multiline rule via Fleet Automation?"
    exit 1
fi

# Check if multi_line type is configured
if ! grep -A 20 "user-service" "$CONFIG_FILE" | grep -q "type: multi_line"; then
    fail-message "multi_line type not found for user-service."
    exit 1
fi

# Check if pattern contains <log>
if ! grep -A 20 "user-service" "$CONFIG_FILE" | grep -q "'<log>'"; then
    fail-message "Pattern '<log>' not found. Make sure you set pattern: '<log>'"
    exit 1
fi

echo "Multiline processing is correctly configured for user-service!"
echo "XML logs should now appear as complete documents in Datadog."
