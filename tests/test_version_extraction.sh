#!/bin/bash
set -e

# Test if get_version.sh exists
if [ ! -f "scripts/get_version.sh" ]; then
    echo "FAILED: scripts/get_version.sh does not exist"
    exit 1
fi

# Run the script and capture output
VERSION=$(bash scripts/get_version.sh)

# Validate format (starts with v and followed by numbers and dots)
if [[ ! $VERSION =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "FAILED: Invalid version format: $VERSION"
    exit 1
fi

echo "SUCCESS: Version extraction verified: $VERSION"
