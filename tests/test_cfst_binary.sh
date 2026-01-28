#!/bin/bash
set -e

IMAGE_NAME="cfst-docker-test-binary"

echo "Running Red Stage: Testing if CloudflareSpeedTest is integrated..."

docker build -t "$IMAGE_NAME" .

echo "Checking for CloudflareSpeedTest binary..."
docker run --rm "$IMAGE_NAME" CloudflareSpeedTest -v || (echo "FAILED: CloudflareSpeedTest not found or not executable"; exit 1)

echo "SUCCESS: CloudflareSpeedTest is integrated"
