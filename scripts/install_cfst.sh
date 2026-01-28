#!/bin/bash
set -e

REPO="XIU2/CloudflareSpeedTest"

# Detect architecture
ARCH_RAW=$(uname -m)
case "$ARCH_RAW" in
    x86_64)      ARCH="amd64" ;;
    aarch64)     ARCH="arm64" ;;
    armv7l|armv7) ARCH="armv7" ;;
    i386|i686)   ARCH="386"   ;;
    *)           echo "Unsupported architecture: $ARCH_RAW"; exit 1 ;;
esac

echo "Detected architecture: $ARCH"
echo "Fetching latest release for $REPO..."
LATEST_TAG=$(bash "$(dirname "$0")/get_version.sh")

if [ -z "$LATEST_TAG" ]; then
    echo "Failed to fetch latest tag"
    exit 1
fi

echo "Latest tag: $LATEST_TAG"

DOWNLOAD_URL="https://github.com/$REPO/releases/download/$LATEST_TAG/cfst_linux_$ARCH.tar.gz"

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
