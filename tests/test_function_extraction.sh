#!/bin/bash
# Test if entrypoint.sh defines run_speedtest function

ENTRYPOINT="./entrypoint.sh"

if [ ! -f "$ENTRYPOINT" ]; then
    echo "FAILED: $ENTRYPOINT not found"
    exit 1
fi

# Load entrypoint.sh and check if function is defined
# We use a subshell to avoid executing the whole script if it has top-level logic
if (source "$ENTRYPOINT" > /dev/null 2>&1; declare -f run_speedtest > /dev/null); then
    echo "SUCCESS: run_speedtest function is defined"
    exit 0
else
    echo "FAILED: run_speedtest function is NOT defined"
    exit 1
fi
