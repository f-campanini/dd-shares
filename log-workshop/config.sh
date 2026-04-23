#!/bin/bash
# =============================================================================
# Log Generator Configuration
# =============================================================================

# -----------------------------------------------------------------------------
# Output Directory
# - In Docker: /var/log/workshop (set via environment)
# - On host: ~/workshop-logs (no sudo required)
# -----------------------------------------------------------------------------
if [ -f /.dockerenv ]; then
    LOG_DIR="${LOG_DIR:-/var/log/workshop}"
else
    LOG_DIR="${LOG_DIR:-$HOME/workshop-logs}"
fi

# -----------------------------------------------------------------------------
# Log Generation Rate (logs per minute per service)
# -----------------------------------------------------------------------------
API_GATEWAY_RATE="${API_GATEWAY_RATE:-30}"
PAYMENT_SERVICE_RATE="${PAYMENT_SERVICE_RATE:-20}"
USER_SERVICE_RATE="${USER_SERVICE_RATE:-25}"
LEGACY_MONOLITH_RATE="${LEGACY_MONOLITH_RATE:-15}"

# -----------------------------------------------------------------------------
# Burst Configuration
# -----------------------------------------------------------------------------
# Probability of a burst occurring (1-100)
BURST_PROBABILITY="${BURST_PROBABILITY:-5}"
# Number of logs in a burst
BURST_SIZE="${BURST_SIZE:-15}"

# -----------------------------------------------------------------------------
# Error Rate (percentage of logs that are errors, 1-100)
# -----------------------------------------------------------------------------
ERROR_RATE="${ERROR_RATE:-10}"

# -----------------------------------------------------------------------------
# Stack Trace Probability (percentage of errors with stack traces, 1-100)
# -----------------------------------------------------------------------------
STACK_TRACE_PROBABILITY="${STACK_TRACE_PROBABILITY:-40}"

# -----------------------------------------------------------------------------
# Service Names (used as source tags)
# -----------------------------------------------------------------------------
API_GATEWAY_SERVICE="api-gateway"
PAYMENT_SERVICE_SERVICE="payment-service"
USER_SERVICE_SERVICE="user-service"
LEGACY_MONOLITH_SERVICE="legacy-monolith"

# -----------------------------------------------------------------------------
# Log File Names
# -----------------------------------------------------------------------------
API_GATEWAY_LOG="api-gateway.log"
PAYMENT_SERVICE_LOG="payment-service.log"
USER_SERVICE_LOG="user-service.log"
LEGACY_MONOLITH_LOG="legacy-monolith.log"

# -----------------------------------------------------------------------------
# Intentional Issues Toggle (for workshop scenarios)
# Set to "true" to enable broken scenarios
# -----------------------------------------------------------------------------
ENABLE_BROKEN_TIMESTAMPS="${ENABLE_BROKEN_TIMESTAMPS:-true}"
ENABLE_MISSING_FIELDS="${ENABLE_MISSING_FIELDS:-true}"
ENABLE_MULTILINE_ISSUES="${ENABLE_MULTILINE_ISSUES:-true}"
ENABLE_MIXED_FORMATS="${ENABLE_MIXED_FORMATS:-true}"
