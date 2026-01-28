#!/bin/bash

# Test script for logging functionality in entrypoint.sh
LOG_FILE="speedtest.log"
ENTRYPOINT="./entrypoint.sh"

echo "Running Red Stage: Testing logging functionality..."

# Mock CloudflareSpeedTest so the script doesn't fail on execution
mkdir -p mock_bin
echo '#!/bin/bash' > mock_bin/CloudflareSpeedTest
echo 'echo "Mock Speedtest Run"' >> mock_bin/CloudflareSpeedTest
chmod +x mock_bin/CloudflareSpeedTest
export PATH="$(pwd)/mock_bin:$PATH"

# Create a dirty log file
echo "Old log content" > "$LOG_FILE"

# Run entrypoint and capture output
# We pass a dummy GIST_TOKEN to avoid early exit if token check exists
export GIST_TOKEN="dummy"
CONSOLE_OUTPUT=$(bash "$ENTRYPOINT" 2>&1)

echo "Checking if log file was cleared..."
if grep -q "Old log content" "$LOG_FILE"; then
    echo "FAILED: Old log content still exists in $LOG_FILE"
    exit 1
fi

echo "Checking for INFO level in console..."
if ! echo "$CONSOLE_OUTPUT" | grep -q "\[INFO\]"; then
    echo "FAILED: [INFO] level tag not found in console output"
    exit 1
fi

echo "Checking for INFO level in log file..."
if ! grep -q "\[INFO\]" "$LOG_FILE"; then
    echo "FAILED: [INFO] level tag not found in log file"
    exit 1
fi

echo "Checking for multi-output..."
TEST_MSG="Test Message"
# This requires entrypoint.sh to have a way to log a custom message or we just check if normal flow logs match
if ! echo "$CONSOLE_OUTPUT" | grep -q "Starting Cloudflare Speed Test"; then
    echo "FAILED: Expected start message not found in console"
    exit 1
fi

if ! grep -q "Starting Cloudflare Speed Test" "$LOG_FILE"; then
    echo "FAILED: Expected start message not found in log file"
    exit 1
fi

echo "SUCCESS: Logging functionality verified (clearing, levels, multi-output)"
rm -rf mock_bin "$LOG_FILE"
