#!/bin/bash

# End-to-End integration test script
# It will build the image and run it with a mock env file.

IMAGE_NAME="cfst-e2e-test"
ENV_FILE=".env.test"
OUTPUT_DIR="./e2e_output"

echo "Running Red Stage: E2E Verification..."

# 1. Prepare mock environment
cat << EOF > "$ENV_FILE"
GIST_TOKEN=ghp_mock_token
GIST_ID=mock_gist_id
CF_N=500
CF_DN=1
EOF

mkdir -p "$OUTPUT_DIR"

# 2. Build the image (This ensures Dockerfile is valid)
echo "Building docker image..."
if ! docker build -t "$IMAGE_NAME" . ; then
    echo "FAILED: Docker build failed"
    exit 1
fi

# 3. Run the container
echo "Running container..."
if ! docker run --rm --env-file "$ENV_FILE" -v "$(pwd)/$OUTPUT_DIR:/app/data" "$IMAGE_NAME" > e2e_run.log 2>&1; then
    echo "WARNING: Container exited with non-zero code (expected for mock Gist credentials)"
fi

# 4. Verify results
echo "Verifying outputs..."

if [ ! -f "$OUTPUT_DIR/result.csv" ]; then
    echo "FAILED: result.csv not produced in mounted volume"
    exit 1
fi

if ! grep -q "Best Result: IP:" e2e_run.log; then
    echo "FAILED: Success summary (Best Result) not found in logs"
    cat e2e_run.log
    exit 1
fi

if ! grep -q "Uploading filtered top 20 results" e2e_run.log; then
    # If no results had speed > 0, this might be missing. 
    # But with 500 threads, we usually find something.
    if grep -q "No results with download speed found to upload" e2e_run.log; then
        echo "INFO: No results with download speed found, skipping upload check"
    else
        echo "FAILED: Gist upload logic neither attempted nor explicitly skipped"
        cat e2e_run.log
        exit 1
    fi
fi

echo "SUCCESS: E2E verification passed (Build + Run + Volume + Logs)"

# Cleanup only on success
rm -rf "$ENV_FILE" "$OUTPUT_DIR" e2e_run.log
# Note: Keep the image for now, or use docker rmi
