FROM alpine:latest

# Install dependencies
RUN apk add --no-cache \
    bash \
    curl \
    jq \
    ca-certificates \
    tzdata

WORKDIR /app

# Install CloudflareSpeedTest from GitHub
COPY scripts/install_cfst.sh /tmp/install_cfst.sh
RUN chmod +x /tmp/install_cfst.sh && /tmp/install_cfst.sh && rm /tmp/install_cfst.sh

# Copy IP data files
COPY ip.txt ipv6.txt /app/

# Copy entrypoint script
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# Create data directory for volume mounting
RUN mkdir -p /app/data

ENTRYPOINT ["/app/entrypoint.sh"]