FROM alpine:latest

# Install dependencies
RUN apk add --no-cache \
    bash \
    curl \
    jq \
    ca-certificates \
    tzdata

WORKDIR /app

# Set default shell
SHELL ["/bin/bash", "-c"]

CMD ["bash"]

