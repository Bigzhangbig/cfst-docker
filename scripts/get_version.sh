#!/bin/bash
set -e

REPO="XIU2/CloudflareSpeedTest"
LATEST_TAG=$(curl --retry 5 -s "https://api.github.com/repos/$REPO/releases/latest" | jq -r '.tag_name')

if [ -z "$LATEST_TAG" ] || [ "$LATEST_TAG" == "null" ]; then
    # Fallback or error
    exit 1
fi

echo "$LATEST_TAG"
