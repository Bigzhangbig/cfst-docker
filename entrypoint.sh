#!/bin/bash

# Configuration
LOG_FILE="speedtest.log"

# Clear old log file
> "$LOG_FILE"

# Logging function
log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    local log_entry="[$timestamp] [$level] $message"
    
    # Output to console
    echo "$log_entry"
    
    # Output to log file
    echo "$log_entry" >> "$LOG_FILE"
}

log_info() { log "INFO" "$1"; }
log_warn() { log "WARN" "$1"; }
log_error() { log "ERROR" "$1"; }

# Main execution start
log_info "Starting Cloudflare Speed Test wrapper..."

# Parameters with defaults
# CF_N: 测速数量 (default: 200)
# CF_T: 测试线程 (default: 4)
# CF_DN: 下载测试数量 (default: 10)
# CF_URL: 自定义测速地址
N=${CF_N:-200}
T=${CF_T:-4}
DN=${CF_DN:-10}
URL=${CF_URL:-""}

OPTS="-n $N -t $T -dn $DN"
if [ -n "$URL" ]; then
    OPTS="$OPTS -url $URL"
fi

# Placeholder for SpeedTest execution
if command -v CloudflareSpeedTest > /dev/null; then
    log_info "Executing CloudflareSpeedTest with options: $OPTS"
    CloudflareSpeedTest $OPTS
else
    log_error "CloudflareSpeedTest binary not found in PATH"
    exit 1
fi

log_info "Cloudflare Speed Test execution finished."
