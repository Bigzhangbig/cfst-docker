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
# CF_N: 测速数量 (default: 500)
# CF_T: 测试线程 (default: 4)
# CF_DN: 下载测试数量 (default: 20)
# CF_URL: 自定义测速地址
N=${CF_N:-500}
T=${CF_T:-4}
DN=${CF_DN:-20}
URL=${CF_URL:-""}
DT=${CF_DT:-""}
TP=${CF_TP:-""}
HTTPING=${CF_HTTPING:-""}
HTTPING_CODE=${CF_HTTPING_CODE:-""}
CFCOLO=${CF_COLO:-""}
TL=${CF_TL:-1000}
TLL=${CF_TLL:-""}
TLR=${CF_TLR:-""}
SL=${CF_SL:-""}
P=${CF_P:-""}
F=${CF_F:-""}
IP_DATA=${CF_IP:-""}
DD=${CF_DD:-""}
ALLIP=${CF_ALLIP:-""}

OPTS="-n $N -t $T -dn $DN"
[ -n "$URL" ] && OPTS="$OPTS -url $URL"
[ -n "$DT" ] && OPTS="$OPTS -dt $DT"
[ -n "$TP" ] && OPTS="$OPTS -tp $TP"
[ "$HTTPING" = "true" ] && OPTS="$OPTS -httping"
[ -n "$HTTPING_CODE" ] && OPTS="$OPTS -httping-code $HTTPING_CODE"
[ -n "$CFCOLO" ] && OPTS="$OPTS -cfcolo $CFCOLO"
[ -n "$TL" ] && OPTS="$OPTS -tl $TL"
[ -n "$TLL" ] && OPTS="$OPTS -tll $TLL"
[ -n "$TLR" ] && OPTS="$OPTS -tlr $TLR"
[ -n "$SL" ] && OPTS="$OPTS -sl $SL"
[ -n "$P" ] && OPTS="$OPTS -p $P"
[ -n "$F" ] && OPTS="$OPTS -f $F"
[ -n "$IP_DATA" ] && OPTS="$OPTS -ip $IP_DATA"
[ "$DD" = "true" ] && OPTS="$OPTS -dd"
[ "$ALLIP" = "true" ] && OPTS="$OPTS -allip"

# Placeholder for SpeedTest execution
if command -v CloudflareSpeedTest > /dev/null; then
    log_info "Executing CloudflareSpeedTest with options: $OPTS"
    log_info "Running speed test, please wait (detailed logs in $LOG_FILE)..."
    
    # Run in background and redirect all output to log file
    CloudflareSpeedTest $OPTS -o "$RESULT_FILE" >> "$LOG_FILE" 2>&1 &
    CFST_PID=$!

    # Monitor progress every 5 seconds
    while kill -0 $CFST_PID 2>/dev/null; do
        # Extract the latest line containing "可用:"
        # Use tail -c to read from end of file for efficiency if it gets large
        # We need to handle the \r and ANSI codes from the original progress bar
        PROGRESS=$(tr '\r' '\n' < "$LOG_FILE" | grep "可用:" | tail -n 1 | sed 's/\x1b\[[0-9;]*[a-zA-Z]//g')
        
        if [ -n "$PROGRESS" ]; then
            # Use \r to overwrite the line and -n to stay on the same line
            printf "\r[PROGRESS] %-80s" "${PROGRESS}"
        fi
        sleep 5
    done
    # Print a newline after monitoring is done to clear the printf line
    echo ""

    wait $CFST_PID
    EXIT_CODE=$?

    if [ $EXIT_CODE -ne 0 ]; then
        log_error "CloudflareSpeedTest failed (Exit Code: $EXIT_CODE). Check $LOG_FILE for details."
        exit $EXIT_CODE
    fi
else
    log_error "CloudflareSpeedTest binary not found in PATH"
    exit 1
fi

# Result extraction and Gist upload
if [ -f "$RESULT_FILE" ]; then
    # Extract the first result line for log summary
    BEST_RESULT=$(sed -n '2p' "$RESULT_FILE")
    
    if [ -n "$BEST_RESULT" ]; then
        # CSV Format: IP, Sent, Recv, LossRate, AvgLatency, Speed, Region
        IFS=',' read -r IP SENT RECV LOSS PING DL REGION <<< "$BEST_RESULT"
        SUMMARY="IP: $IP ($REGION), Ping: ${PING}ms, DL: ${DL}MB/s"
        log_info "Best Result: $SUMMARY"
        
        # Upload to Gist if credentials provided
        if [ -n "$GIST_TOKEN" ] && [ -n "$GIST_ID" ]; then
            log_info "Filtering top 20 results by lowest latency with speed > 0..."
            
            # 1. Get Header
            HEADER=$(head -n 1 "$RESULT_FILE")
            
            # 2. Filter rows where download speed (col 6) > 0, 
            #    sort by latency (col 5) numerically, and take top 20.
            # We use tail to skip header in the process, then re-attach it.
            DATA_ROWS=$(tail -n +2 "$RESULT_FILE" | awk -F, '$6 > 0' | sort -t, -k5,5n | head -n 20)
            
            if [ -n "$DATA_ROWS" ]; then
                CSV_CONTENT_FOR_GIST=$(printf "%s\n%s" "$HEADER" "$DATA_ROWS")
                FILENAME="result.csv"
                
                log_info "Uploading filtered top 20 results to Gist $GIST_ID..."
                
                JSON_PAYLOAD=$(jq -n \
                    --arg fn "$FILENAME" \
                    --arg cont "$CSV_CONTENT_FOR_GIST" \
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
                log_warn "No results with download speed found to upload."
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
