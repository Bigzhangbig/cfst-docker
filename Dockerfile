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

# Set default shell
SHELL ["/bin/bash", "-c"]

CMD ["bash"]

