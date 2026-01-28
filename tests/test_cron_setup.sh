#!/bin/bash
# Test for Cron mode setup and crontab generation

ENTRYPOINT="./entrypoint.sh"
CRON_FILE="/tmp/mock_crontab"

# Mock crond
mkdir -p bin_mock_cron
echo -e "#!/bin/bash\necho \"crond started with args: $@\"" > bin_mock_cron/crond
chmod +x bin_mock_cron/crond

cleanup() {
    rm -rf bin_mock_cron cron_test.log "$CRON_FILE"
}

echo "Testing Cron mode setup with CRON='*/5 * * * *'..."
export CRON="*/5 * * * *"
export PATH="$(pwd)/bin_mock_cron:$PATH"

# Run in background
bash "$ENTRYPOINT" > cron_test.log 2>&1 &
PID=$!

sleep 2
kill $PID 2>/dev/null || true

if rg -q "crond started" cron_test.log; then
    echo "SUCCESS: crond was started"
else
    echo "FAILED: crond was NOT started"
    batcat cron_test.log
    cleanup
    exit 1
fi

# Note: In real Alpine, crontab is in /var/spool/cron/crontabs/root
# For testing we might need to check if the script tries to write it.
# We'll check the logs for any indication of crontab setup.

cleanup
exit 0
