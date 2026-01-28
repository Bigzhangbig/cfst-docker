#!/bin/bash

# Configuration
LOG_FILE="speedtest.log"
DATA_DIR="data"
RESULT_FILE="$DATA_DIR/result.csv"

# Ensure data directory exists
mkdir -p "$DATA_DIR"

# Logging functions
log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    local log_entry="[$timestamp] [$level] $message"
    echo "$log_entry"
    echo "$log_entry" >> "$LOG_FILE"
}

log_info() { log "INFO" "$1"; }
log_warn() { log "WARN" "$1"; }
log_error() { log "ERROR" "$1"; }

# Simple log rotation
rotate_logs() {
    if [ -f "$LOG_FILE" ]; then
        local line_count=$(wc -l < "$LOG_FILE")
        if [ "$line_count" -gt 1000 ]; then
            log_info "Log rotation: Truncating $LOG_FILE (Current lines: $line_count)"
            local tmp_log=$(mktemp)
            tail -n 1000 "$LOG_FILE" > "$tmp_log"
            cat "$tmp_log" > "$LOG_FILE"
            rm "$tmp_log"
        fi
    fi
}

# Core Speed Test Function
run_speedtest() {
    rotate_logs
    log_info "Starting Cloudflare Speed Test execution..."

    # Parameters with defaults
    local N=${CF_N:-500}
    local T=${CF_T:-4}
    local DN=${CF_DN:-20}
    local URL=${CF_URL:-""}
    local DT=${CF_DT:-""}
    local TP=${CF_TP:-""}
    local HTTPING=${CF_HTTPING:-""}
    local HTTPING_CODE=${CF_HTTPING_CODE:-""}
    local CFCOLO=${CF_COLO:-""}
    local TL=${CF_TL:-1000}
    local TLL=${CF_TLL:-""}
    local TLR=${CF_TLR:-""}
    local SL=${CF_SL:-""}
    local P=${CF_P:-""}
    local F=${CF_F:-""}
    local IP_DATA=${CF_IP:-""}
    local DD=${CF_DD:-""}
    local ALLIP=${CF_ALLIP:-""}

    local OPTS="-n $N -t $T -dn $DN"
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

    if ! command -v CloudflareSpeedTest > /dev/null; then
        log_error "CloudflareSpeedTest binary not found in PATH"
        return 1
    fi

    log_info "Executing CloudflareSpeedTest with options: $OPTS"
    
    # Run in background and redirect all output to log file
    CloudflareSpeedTest $OPTS -o "$RESULT_FILE" >> "$LOG_FILE" 2>&1 &
    local CFST_PID=$!

    # Monitor progress every 5 seconds
    while kill -0 $CFST_PID 2>/dev/null; do
        local PROGRESS=$(tr '\r' '\n' < "$LOG_FILE" | grep "可用:" | tail -n 1 | sed 's/\x1b\[[0-9;]*[a-zA-Z]//g')
        if [ -n "$PROGRESS" ]; then
            printf "\r[PROGRESS] %-80s" "${PROGRESS}"
        fi
        sleep 5
    done
    echo "" # Newline after progress bar

    wait $CFST_PID
    local EXIT_CODE=$?

    if [ $EXIT_CODE -ne 0 ]; then
        log_error "CloudflareSpeedTest failed (Exit Code: $EXIT_CODE). Check $LOG_FILE for details."
        return $EXIT_CODE
    fi

    # Result extraction and Gist upload
    if [ -f "$RESULT_FILE" ]; then
        local BEST_RESULT=$(sed -n '2p' "$RESULT_FILE")
        if [ -n "$BEST_RESULT" ]; then
            IFS=',' read -r IP SENT RECV LOSS PING DL REGION <<< "$BEST_RESULT"
            log_info "Best Result: IP: $IP ($REGION), Ping: ${PING}ms, DL: ${DL}MB/s"
            
            if [ -n "$GIST_TOKEN" ] && [ -n "$GIST_ID" ]; then
                log_info "Filtering top 20 results and uploading to Gist $GIST_ID..."
                local HEADER=$(head -n 1 "$RESULT_FILE")
                local DATA_ROWS=$(tail -n +2 "$RESULT_FILE" | awk -F, '$6 > 0' | sort -t, -k5,5n | head -n 20)
                
                if [ -n "$DATA_ROWS" ]; then
                    local CSV_CONTENT=$(printf "%s\n%s" "$HEADER" "$DATA_ROWS")
                    local JSON_PAYLOAD=$(jq -n --arg fn "result.csv" --arg cont "$CSV_CONTENT" '{files: {($fn): {content: $cont}}}')
                    
                    local RESPONSE=$(curl -s -X PATCH \
                        -H "Authorization: token $GIST_TOKEN" \
                        -H "Accept: application/vnd.github.v3+json" \
                        -d "$JSON_PAYLOAD" \
                        "https://api.github.com/gists/$GIST_ID")
                    
                    local GIST_URL=$(echo "$RESPONSE" | jq -r '.html_url // empty')
                    if [ -n "$GIST_URL" ]; then
                        log_info "Successfully uploaded to Gist: $GIST_URL"
                    else
                        log_error "Failed to upload to Gist. Check credentials."
                        log_warn "API Response: $(echo "$RESPONSE" | jq -c '.' 2>/dev/null || echo "$RESPONSE")"
                    fi
                else
                    log_warn "No results with download speed found to upload."
                fi
            fi
        else
            log_warn "No results found in $RESULT_FILE."
        fi
    fi
    log_info "Cloudflare Speed Test execution finished."
}

# Main Dispatch Logic

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then

    if [ -n "$CRON" ]; then

        log_info "Entering Cron mode with schedule: $CRON"

        # Placeholder for actual crond start

        sleep infinity

        elif [ -n "$LOOP_INTERVAL" ]; then

            log_info "Entering Loop mode with interval: $LOOP_INTERVAL seconds"

            while true; do

                run_speedtest

                log_info "Sleeping for $LOOP_INTERVAL seconds before next run..."

                sleep "$LOOP_INTERVAL"

            done

        else

    

        log_info "Running in One-shot mode."

        run_speedtest

    fi

fi
