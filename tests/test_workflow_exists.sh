#!/bin/bash
set -e

WORKFLOW=".github/workflows/docker-publish.yml"

if [ ! -f "$WORKFLOW" ]; then
    echo "FAILED: $WORKFLOW does not exist"
    exit 1
fi

# Check for key requirements
for KEY in "ghcr.io" "platforms" "docker/build-push-action" "linux/amd64" "linux/arm64"; do
    if ! grep -q "$KEY" "$WORKFLOW"; then
        echo "FAILED: Required keyword '$KEY' not found in $WORKFLOW"
        exit 1
    fi
done

echo "SUCCESS: Workflow file exists and contains basic requirements"
