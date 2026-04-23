#!/bin/bash
# Challenge 2 setup - ensure some error logs with stack traces exist
echo "Challenge 2: Generating additional error logs with stack traces..."

# Temporarily increase error rate to ensure stack traces are generated
export ERROR_RATE=50
export STACK_TRACE_PROBABILITY=80

# Generate a burst of legacy monolith logs
for i in {1..10}; do
    /opt/log-generator.sh --burst 2>/dev/null &
    sleep 1
    pkill -f "log-generator.sh --burst" 2>/dev/null || true
done

# Reset to normal
unset ERROR_RATE
unset STACK_TRACE_PROBABILITY

echo "Error logs with stack traces have been generated."
