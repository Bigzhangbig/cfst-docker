#!/bin/bash
# Test for log rotation logic

ENTRYPOINT="./entrypoint.sh"
LOG_FILE="speedtest.log"

# Fill log with 2000 lines
echo "Filling log with 2000 lines..."
for i in {1..2000}; do echo "Log entry $i" >> "$LOG_FILE"; done

# Run entrypoint in one-shot mode (it should perform rotation if implemented)
# Use a mock CloudflareSpeedTest to speed up
mkdir -p bin_mock_rot
echo -e "#!/bin/bash\necho \"Running\"" > bin_mock_rot/CloudflareSpeedTest
chmod +x bin_mock_rot/CloudflareSpeedTest

echo "Executing entrypoint..."
PATH="$(pwd)/bin_mock_rot:$PATH" bash "$ENTRYPOINT" > rotation_run.log 2>&1

LINE_COUNT=$(wc -l < "$LOG_FILE")
echo "Log file lines after run: $LINE_COUNT"

rm -rf bin_mock_rot rotation_run.log

# We expect it to be <= 1000 + some small overhead for the current run
if [ "$LINE_COUNT" -le 1100 ]; then
    echo "SUCCESS: Log rotation performed"
    exit 0
else
    echo "FAILED: Log rotation NOT performed (Lines: $LINE_COUNT)"
    exit 1
fi
