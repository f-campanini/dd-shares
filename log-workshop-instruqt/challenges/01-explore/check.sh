#!/bin/bash
# Challenge 1 check - verify basic setup

set -e

# Check agent is running
if ! systemctl is-active --quiet datadog-agent; then
    fail-message "Datadog agent is not running. Run: sudo systemctl start datadog-agent"
    exit 1
fi

# Check log files exist and have content
for service in api-gateway payment-service user-service legacy-monolith; do
    if [ ! -f "/var/log/workshop/${service}.log" ]; then
        fail-message "Log file /var/log/workshop/${service}.log not found"
        exit 1
    fi
    
    if [ ! -s "/var/log/workshop/${service}.log" ]; then
        fail-message "Log file /var/log/workshop/${service}.log is empty"
        exit 1
    fi
done

echo "All checks passed! Log files are being generated and agent is running."
