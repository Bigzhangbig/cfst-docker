#!/bin/bash
set -e

REPO="XIU2/CloudflareSpeedTest"
ARCH="amd64" # Default to amd64 for this project

echo "Fetching latest release for $REPO..."
LATEST_TAG=$(curl --retry 5 -s "https://api.github.com/repos/$REPO/releases/latest" | jq -r '.tag_name')

if [ -z "$LATEST_TAG" ] || [ "$LATEST_TAG" == "null" ]; then
    echo "Failed to fetch latest tag"
    exit 1
fi

echo "Latest tag: $LATEST_TAG"

DOWNLOAD_URL="https://github.boki.moe/https://github.com/$REPO/releases/download/$LATEST_TAG/cfst_linux_$ARCH.tar.gz"

echo "Downloading from $DOWNLOAD_URL..."
curl --retry 5 -L "$DOWNLOAD_URL" -o cfst.tar.gz

echo "Extracting..."
tar -xzf cfst.tar.gz

if [ -f "cfst" ]; then
    mv cfst /usr/local/bin/CloudflareSpeedTest
    chmod +x /usr/local/bin/CloudflareSpeedTest
    echo "Installed CloudflareSpeedTest to /usr/local/bin/"
else
    echo "Binary cfst not found after extraction"
    ls -R
    exit 1
fi

rm cfst.tar.gz
echo "Cleaned up"
