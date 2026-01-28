#!/bin/bash
set -e

IMAGE_NAME="cfst-docker-test-base"

echo "Running Red Stage: Testing if Dockerfile exists and can be built with dependencies..."

if [ ! -f Dockerfile ]; then
    echo "FAILED: Dockerfile not found"
    exit 1
fi

docker build -t "$IMAGE_NAME" .

echo "Checking for curl..."
docker run --rm "$IMAGE_NAME" curl --version > /dev/null || (echo "FAILED: curl not found"; exit 1)

echo "Checking for jq..."
docker run --rm "$IMAGE_NAME" jq --version > /dev/null || (echo "FAILED: jq not found"; exit 1)

echo "SUCCESS: Base image has required dependencies"
