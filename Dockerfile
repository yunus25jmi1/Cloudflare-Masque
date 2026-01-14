FROM alpine:latest

# Install dependencies for fetching binaries and processing config
RUN apk add --no-cache curl grep sed jq ca-certificates

# Set versions
ARG WGCF_VERSION=2.2.22
ARG WIREPROXY_VERSION=1.0.9
ARG GOST_VERSION=2.11.5

# Download wgcf (for account registration)
RUN curl -fsSL "https://github.com/ViRb3/wgcf/releases/download/v${WGCF_VERSION}/wgcf_${WGCF_VERSION}_linux_amd64" -o /usr/local/bin/wgcf \
    && chmod +x /usr/local/bin/wgcf

# Download wireproxy (for userspace networking)
RUN curl -fsSL "https://github.com/pufferffish/wireproxy/releases/download/v${WIREPROXY_VERSION}/wireproxy_linux_amd64.tar.gz" -o wireproxy.tar.gz \
    && tar -xzf wireproxy.tar.gz -C /usr/local/bin/ \
    && rm wireproxy.tar.gz \
    && chmod +x /usr/local/bin/wireproxy

# Download gost (for WebSocket tunneling)
RUN curl -fsSL "https://github.com/ginuerzh/gost/releases/download/v${GOST_VERSION}/gost-linux-amd64-${GOST_VERSION}.gz" -o gost.gz \
    && gzip -d gost.gz \
    && mv gost /usr/local/bin/gost \
    && chmod +x /usr/local/bin/gost

# Setup workspace
WORKDIR /app
COPY entrypoint.sh /app/entrypoint.sh
COPY healthcheck.sh /app/healthcheck.sh
RUN chmod +x /app/entrypoint.sh /app/healthcheck.sh

# Expose SOCKS5 port
EXPOSE 1080 8080

# Healthcheck
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD /app/healthcheck.sh || exit 1

# Run
CMD ["/app/entrypoint.sh"]
