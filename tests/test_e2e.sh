#!/bin/bash

# End-to-End integration test script (Accelerated via Mocking)
# Covers One-shot and Loop modes.

IMAGE_NAME="cfst-e2e-test"
ENV_FILE=".env.test"
OUTPUT_DIR="./e2e_output"
MOCK_FILE="/tmp/CloudflareSpeedTest_mock"

echo "Running E2E Verification (Mocked)..."

# Create a mock binary
echo -e "#!/bin/bash\necho \"可用: 1 / 1\"\nmkdir -p data && echo \"IP,Sent,Recv,Loss,Ping,DL,Region\" > data/result.csv && echo \"1.1.1.1,4,4,0,10,100,HKG\" >> data/result.csv\nexit 0" > "$MOCK_FILE"
chmod +x "$MOCK_FILE"

# 1. Build the image
echo "Building docker image..."
if ! docker build -q -t "$IMAGE_NAME" . > /dev/null ; then
    echo "FAILED: Docker build failed"
    exit 1
fi

cleanup() {
    rm -rf "$ENV_FILE" "$OUTPUT_DIR" e2e_run.log "$MOCK_FILE"
}

# --- Test Case 1: One-shot mode ---
echo "Testing Case 1: One-shot mode..."
cat << EOF > "$ENV_FILE"
CF_N=1
CF_DN=1
EOF
mkdir -p "$OUTPUT_DIR"

if ! docker run --rm --env-file "$ENV_FILE" \
    -v "$(pwd)/$OUTPUT_DIR:/app/data" \
    -v "$MOCK_FILE:/usr/local/bin/CloudflareSpeedTest" \
    "$IMAGE_NAME" > e2e_run.log 2>&1; then
    echo "FAILED: One-shot container crashed"
    cat e2e_run.log
    exit 1
fi

if grep -q "Running in One-shot mode" e2e_run.log && grep -q "Best Result: IP: 1.1.1.1" e2e_run.log; then
    echo "SUCCESS: One-shot mode verified"
else
    echo "FAILED: One-shot mode indicators not found"
    cat e2e_run.log
    exit 1
fi
cleanup

# --- Test Case 2: Loop mode ---
echo "Testing Case 2: Loop mode (Wait for 2 rounds)..."
cat << EOF > "$ENV_FILE"
CF_N=1
CF_DN=1
LOOP_INTERVAL=2
EOF
mkdir -p "$OUTPUT_DIR"
touch "$MOCK_FILE" && chmod +x "$MOCK_FILE" # Re-ensure mock exists

docker run --rm --name "cfst-loop-tester" --env-file "$ENV_FILE" \
    -v "$(pwd)/$OUTPUT_DIR:/app/data" \
    -v "$MOCK_FILE:/usr/local/bin/CloudflareSpeedTest" \
    "$IMAGE_NAME" > e2e_run.log 2>&1 &
PID=$!

echo "Waiting 8 seconds for 2 rounds to complete..."
sleep 8
docker stop "cfst-loop-tester" > /dev/null 2>&1

if grep -q "Starting Round 1" e2e_run.log && grep -q "Starting Round 2" e2e_run.log; then
    echo "SUCCESS: Loop mode rounds verified"
else
    echo "FAILED: Loop mode rounds not detected in E2E logs"
    cat e2e_run.log
    exit 1
fi

cleanup
echo "SUCCESS: ALL E2E test cases passed"
