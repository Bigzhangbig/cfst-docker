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
# If it's a Gists API call with data
if [[ "$*" == *"api.github.com/gists"* ]] && [[ "$*" == *"-d"* ]]; then
    echo "PAYLOAD: $@" > gist_payload.tmp
    echo '{"html_url": "https://gist.github.com/test_gist_id", "status": "success"}'
    exit 0
fi
# Execute real curl for other things
/usr/bin/curl "$@"
EOF
chmod +x mock_bin/curl
export PATH="$(pwd)/mock_bin:$PATH"

# Mock CloudflareSpeedTest to produce a result.csv in the expected directory
# Since entrypoint.sh does 'cd data && CloudflareSpeedTest', we need to handle that.
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
bash "$ENTRYPOINT"

echo "Checking if result was placed in data/ directory..."
if [ ! -f "data/result.csv" ]; then
    echo "FAILED: data/result.csv not found"
    exit 1
fi

echo "Checking if result was extracted from CSV for logging..."
# The script should log the summary
if ! grep -q "1.1.1.1" "$LOG_FILE"; then
    echo "FAILED: Result (1.1.1.1) not found in log"
    exit 1
fi

echo "Checking if Gist API was called with CSV content..."
if [ ! -f gist_payload.tmp ]; then
    echo "FAILED: Gist API was not called (gist_payload.tmp missing)"
    exit 1
fi

if ! grep -q "IP 地址,端口,数据中心" gist_payload.tmp 2>/dev/null; then
    echo "FAILED: Gist payload does not contain CSV header"
    exit 1
fi

echo "SUCCESS: Result directory and full CSV upload verified"
rm -rf mock_bin "$LOG_FILE" data gist_payload.tmp
