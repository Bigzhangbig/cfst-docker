FROM alpine:latest

# Install dependencies
RUN apk add --no-cache \
    bash \
    curl \
    jq \
    ca-certificates \
    tzdata

WORKDIR /app

# Install CloudflareSpeedTest (Local copy for stability during dev)
COPY cfst /usr/local/bin/CloudflareSpeedTest
RUN chmod +x /usr/local/bin/CloudflareSpeedTest
COPY ip.txt ipv6.txt /app/

COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

ENTRYPOINT ["/app/entrypoint.sh"]

