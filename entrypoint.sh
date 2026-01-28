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

# Ensure data directory exists for mounting
DATA_DIR="data"
mkdir -p "$DATA_DIR"
RESULT_FILE="$DATA_DIR/result.csv"

# Parameters with defaults
# CF_N: 测速数量 (default: 20)
# CF_T: 测试线程 (default: 4)
# CF_DN: 下载测试数量 (default: 10)
# CF_URL: 自定义测速地址
N=${CF_N:-20}
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
    # Specify output file in data directory
    CloudflareSpeedTest $OPTS -o "$RESULT_FILE"
else
    log_error "CloudflareSpeedTest binary not found in PATH"
    exit 1
fi

# Result extraction and Gist upload
if [ -f "$RESULT_FILE" ]; then
    # Extract the first result line for log summary
    BEST_RESULT=$(sed -n '2p' "$RESULT_FILE")
    
    if [ -n "$BEST_RESULT" ]; then
        IFS=',' read -r IP PORT DC PING DL UP <<< "$BEST_RESULT"
        SUMMARY="IP: $IP ($DC), Ping: ${PING}ms, DL: ${DL}MB/s, UL: ${UP}MB/s"
        log_info "Best Result: $SUMMARY"
        
        # Upload to Gist if credentials provided
        if [ -n "$GIST_TOKEN" ] && [ -n "$GIST_ID" ]; then
            log_info "Uploading result.csv to Gist $GIST_ID..."
            
            # Read full content of result.csv
            CSV_CONTENT=$(cat "$RESULT_FILE")
            FILENAME="result.csv"
            
            JSON_PAYLOAD=$(jq -n \
                --arg fn "$FILENAME" \
                --arg cont "$CSV_CONTENT" \
                '{files: {($fn): {content: $cont}}}')
            
            RESPONSE=$(curl -s -X PATCH \
                -H "Authorization: token $GIST_TOKEN" \
                -H "Accept: application/vnd.github.v3+json" \
                -d "$JSON_PAYLOAD" \
                "https://api.github.com/gists/$GIST_ID")
            
            GIST_URL=$(echo "$RESPONSE" | jq -r '.html_url // empty')
            
            if [ -n "$GIST_URL" ]; then
                log_info "Successfully uploaded to Gist: $GIST_URL"
            else
                log_error "Failed to upload to Gist. Check your GIST_TOKEN and GIST_ID."
                log_warn "API Response: $(echo "$RESPONSE" | jq -c '.' 2>/dev/null || echo "$RESPONSE")"
            fi
        else
            log_warn "GIST_TOKEN or GIST_ID not set, skipping Gist upload."
        fi
    else
        log_warn "No results found in $RESULT_FILE."
    fi
else
    log_error "Result file $RESULT_FILE not found."
fi

log_info "Cloudflare Speed Test execution finished."
