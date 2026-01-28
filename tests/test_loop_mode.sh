#!/bin/bash
# Test for Loop mode execution

ENTRYPOINT="./entrypoint.sh"
MOCK_BIN_DIR="bin_mock_loop"
MOCK_RAN_FILE="mock_ran_count"

setup_mock() {
    mkdir -p "$MOCK_BIN_DIR"
    # Create a mock that increments a counter file
    echo '#!/bin/bash' > "$MOCK_BIN_DIR/CloudflareSpeedTest"
    echo "if [ ! -f $MOCK_RAN_FILE ]; then echo 0 > $MOCK_RAN_FILE; fi" >> "$MOCK_BIN_DIR/CloudflareSpeedTest"
    echo "count=\$(cat $MOCK_RAN_FILE)" >> "$MOCK_BIN_DIR/CloudflareSpeedTest"
    echo "echo \$((count + 1)) > $MOCK_RAN_FILE" >> "$MOCK_BIN_DIR/CloudflareSpeedTest"
    chmod +x "$MOCK_BIN_DIR/CloudflareSpeedTest"
}

cleanup() {
    rm -rf "$MOCK_BIN_DIR" "$MOCK_RAN_FILE" loop_test.log
}

setup_mock

echo "Testing LOOP_INTERVAL=1 (Waiting 8 seconds to see multiple runs)..."
export LOOP_INTERVAL=1
export PATH="$(pwd)/$MOCK_BIN_DIR:$PATH"

# Run in background
bash "$ENTRYPOINT" > loop_test.log 2>&1 &
PID=$!

sleep 8
kill $PID 2>/dev/null || true

RUN_COUNT=$(cat $MOCK_RAN_FILE 2>/dev/null || echo 0)
echo "Total mock runs: $RUN_COUNT"

if [ "$RUN_COUNT" -ge 2 ]; then
    if grep -q "Starting Round 1" loop_test.log && grep -q "Starting Round 2" loop_test.log; then
        echo "SUCCESS: Loop logic executed multiple times with round indicators"
        cleanup
        exit 0
    else
        echo "FAILED: Round indicators not found in log"
        cat loop_test.log
        cleanup
        exit 1
    fi
else
    echo "FAILED: Loop logic did not execute multiple times (Runs: $RUN_COUNT)"
    cleanup
    exit 1
fi
