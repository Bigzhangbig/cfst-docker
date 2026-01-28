#!/bin/bash
# Test for execution mode dispatching logic

ENTRYPOINT="./entrypoint.sh"

run_and_check() {
    local env_var="$1"
    local env_val="$2"
    local expected_msg="$3"
    
    echo "Testing $env_var=$env_val..."
    export "$env_var"="$env_val"
    
    # Run in background, wait a bit, then kill
    # We use a mock CloudflareSpeedTest to avoid real runs
    mkdir -p bin_mock
    echo -e "#!/bin/bash\ntouch mock_ran" > bin_mock/CloudflareSpeedTest
    chmod +x bin_mock/CloudflareSpeedTest
    
    PATH="$(pwd)/bin_mock:$PATH" bash "$ENTRYPOINT" > dispatch_test.log 2>&1 &
    local PID=$!
    sleep 2
    kill $PID 2>/dev/null
    
    if grep -q "$expected_msg" dispatch_test.log; then
        echo "SUCCESS: Found '$expected_msg'"
        return 0
    else
        echo "FAILED: '$expected_msg' not found in log"
        cat dispatch_test.log
        return 1
    fi
}

# Test 1: Default (One-shot)
run_and_check "DUMMY" "val" "Starting Cloudflare Speed Test execution..." || exit 1

# Test 2: Cron Mode (Should show "Entering Cron mode")
unset LOOP_INTERVAL
run_and_check "CRON" "*/5 * * * *" "Entering Cron mode with schedule:" || exit 1

# Test 3: Loop Mode (Should show "Entering Loop mode")
unset CRON
run_and_check "LOOP_INTERVAL" "60" "Entering Loop mode with interval:" || exit 1

rm -rf bin_mock mock_ran dispatch_test.log
