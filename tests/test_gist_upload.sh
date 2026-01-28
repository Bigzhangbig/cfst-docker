#!/bin/bash

# Test script for result extraction and Gist upload
LOG_FILE="speedtest.log"
ENTRYPOINT="./entrypoint.sh"
RESULT_CSV="result.csv"

echo "Running Red Stage: Testing result extraction and Gist upload..."

# Mock curl to intercept Gist API call
mkdir -p mock_bin
cat << 'EOF' > mock_bin/curl
#!/bin/bash
# If it's a POST request to Gists API, log the payload
if [[ "$*" == *"api.github.com/gists"* ]] && [[ "$*" == *"-d"* ]]; then
    echo "GIST_API_CALLED"
    echo "PAYLOAD: $@" > gist_payload.tmp
fi
# Execute real curl for other things (like fetching latest tag if needed)
/usr/bin/curl "$@"
EOF
chmod +x mock_bin/curl
export PATH="$(pwd)/mock_bin:$PATH"

# Mock CloudflareSpeedTest to produce a result.csv
cat << 'EOF' > mock_bin/CloudflareSpeedTest
#!/bin/bash
echo "IP 地址,端口,数据中心,响应时间,下载速度 (MB/s),上载速度 (MB/s)" > result.csv
echo "1.1.1.1,443,HKG,50.5,100.2,50.1" >> result.csv
echo "Mock Speedtest Finished"
EOF
chmod +x mock_bin/CloudflareSpeedTest

# Set required env vars
export GIST_TOKEN="ghp_test_token"
export GIST_ID="test_gist_id"

# Run entrypoint
bash "$ENTRYPOINT" > /dev/null 2>&1

echo "Checking if result was extracted from CSV..."
# The script should log the summary
if ! grep -q "1.1.1.1" "$LOG_FILE"; then
    echo "FAILED: Result (1.1.1.1) not found in log"
    exit 1
fi

echo "Checking if Gist API was called..."
if ! grep -q "GIST_API_CALLED" gist_payload.tmp 2>/dev/null; then
    # Note: If GIST_TOKEN is dummy, the real curl might fail, 
    # but our mock should have caught the call before execution.
    if [ ! -f gist_payload.tmp ]; then
        echo "FAILED: Gist API was not called"
        exit 1
    fi
fi

echo "SUCCESS: Result extraction and Gist upload logic verified"
rm -rf mock_bin "$LOG_FILE" "$RESULT_CSV" gist_payload.tmp
