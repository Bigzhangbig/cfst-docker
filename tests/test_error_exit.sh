#!/bin/bash
# Test for strict error exit in Loop mode

ENTRYPOINT="./entrypoint.sh"
MOCK_BIN_DIR="bin_mock_error"

setup_mock() {
    mkdir -p "$MOCK_BIN_DIR"
    # Create a mock that fails (exit 1)
    echo -e '#!/bin/bash
echo "Simulating error"
exit 1' > "$MOCK_BIN_DIR/CloudflareSpeedTest"
    chmod +x "$MOCK_BIN_DIR/CloudflareSpeedTest"
}

cleanup() {
    rm -rf "$MOCK_BIN_DIR" error_exit_test.log
}

setup_mock

echo "Testing error exit with LOOP_INTERVAL=1..."
export LOOP_INTERVAL=1
export PATH="$(pwd)/$MOCK_BIN_DIR:$PATH"

# Run in background and wait for exit
bash "$ENTRYPOINT" > error_exit_test.log 2>&1 &
PID=$!

echo "Waiting for script to detect error and exit (10 seconds)..."
sleep 10

if kill -0 $PID 2>/dev/null; then
    echo "FAILED: Script is still running after error"
    kill $PID 2>/dev/null
    cleanup
    exit 1
else
    echo "SUCCESS: Script exited after error"
    # Verify the error was logged using rg
    if rg -q "Critical error detected" error_exit_test.log || rg -q "Speed test failed" error_exit_test.log; then
        echo "SUCCESS: Error message found in logs"
        cleanup
        exit 0
    else
        echo "FAILED: Expected error message not found in logs"
        batcat error_exit_test.log
        cleanup
        exit 1
    fi
fi
