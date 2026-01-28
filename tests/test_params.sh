#!/bin/bash

# Test script for parameter parsing in entrypoint.sh
ENTRYPOINT="./entrypoint.sh"

echo "Running Red Stage: Testing parameter parsing and defaults..."

# Mock CloudflareSpeedTest to capture its arguments
mkdir -p mock_bin
cat << 'EOF' > mock_bin/CloudflareSpeedTest
#!/bin/bash
echo "ARGS: $@"
EOF
chmod +x mock_bin/CloudflareSpeedTest
export PATH="$(pwd)/mock_bin:$PATH"

# Test 1: Default values (no env vars set)
echo "Testing defaults..."
bash "$ENTRYPOINT" > /dev/null 2>&1
# Check ARGS in speedtest.log
if ! grep -q "ARGS:.*-n 20" speedtest.log; then
    echo "FAILED: Default -n 20 not found in speedtest.log"
    exit 1
fi

# Test 2: Overriding with env vars
echo "Testing overrides..."
export CF_N=500
export CF_T=10
export CF_HTTPING=true
export CF_SL=5.5
bash "$ENTRYPOINT" > /dev/null 2>&1
if ! grep -q "ARGS:.*-n 500" speedtest.log; then
    echo "FAILED: Override -n 500 not found"
    exit 1
fi
if ! grep -q "ARGS:.*-t 10" speedtest.log; then
    echo "FAILED: Override -t 10 not found"
    exit 1
fi
if ! grep -q "ARGS:.*-httping" speedtest.log; then
    echo "FAILED: Override -httping not found"
    exit 1
fi
if ! grep -q "ARGS:.*-sl 5.5" speedtest.log; then
    echo "FAILED: Override -sl 5.5 not found"
    exit 1
fi

# Test 3: Port and Threshold
echo "Testing port and latency threshold..."
export CF_TP=2096
export CF_TL=500
bash "$ENTRYPOINT" > /dev/null 2>&1
if ! grep -q "ARGS:.*-tp 2096" speedtest.log; then
    echo "FAILED: Override -tp 2096 not found"
    exit 1
fi
if ! grep -q "ARGS:.*-tl 500" speedtest.log; then
    echo "FAILED: Override -tl 500 not found"
    exit 1
fi

echo "SUCCESS: Parameter parsing and overrides verified"
rm -rf mock_bin speedtest.log
