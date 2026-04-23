#!/bin/bash
# =============================================================================
# Workshop Container Entrypoint
# Starts both the log generator and the Datadog agent
# =============================================================================

set -e

echo "============================================"
echo "  Datadog Logs Workshop Container Starting  "
echo "============================================"
echo ""

# Start the log generator in the background
echo "[*] Starting log generator..."
/opt/workshop/log-generator.sh > /var/log/workshop/generator.log 2>&1 &
GENERATOR_PID=$!
echo "[*] Log generator started (PID: $GENERATOR_PID)"

# Give it a moment to create the first logs
sleep 2

# Verify logs are being created
echo "[*] Verifying log generation..."
ls -la /var/log/workshop/

echo ""
echo "[*] Starting Datadog Agent..."
echo ""

# Start the Datadog agent (this is the main process)
exec /init
