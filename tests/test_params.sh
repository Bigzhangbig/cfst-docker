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
OUTPUT_DEFAULT=$(bash "$ENTRYPOINT" 2>&1)
# We expect some default args, e.g., -n 200 -t 4
if ! echo "$OUTPUT_DEFAULT" | grep -q "ARGS:.*-n 200"; then
    echo "FAILED: Default -n 200 not found"
    exit 1
fi

# Test 2: Overriding with env vars
echo "Testing overrides..."
export CF_N=500
export CF_T=10
OUTPUT_OVERRIDE=$(bash "$ENTRYPOINT" 2>&1)
if ! echo "$OUTPUT_OVERRIDE" | grep -q "ARGS:.*-n 500"; then
    echo "FAILED: Override -n 500 not found"
    exit 1
fi
if ! echo "$OUTPUT_OVERRIDE" | grep -q "ARGS:.*-t 10"; then
    echo "FAILED: Override -t 10 not found"
    exit 1
fi

echo "SUCCESS: Parameter parsing and overrides verified"
rm -rf mock_bin speedtest.log
