FROM debian:latest

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl gnupg dbus cloudflare-warp

# Ensure Cloudflare WARP is installed
RUN curl -fsSL https://pkg.cloudflareclient.com/pubkey.gpg | tee /etc/apt/trusted.gpg.d/cloudflare.asc \
    && echo "deb [signed-by=/etc/apt/trusted.gpg.d/cloudflare.asc] https://pkg.cloudflareclient.com/$(lsb_release -cs) main" | tee /etc/apt/sources.list.d/cloudflare-client.list \
    && apt-get update \
    && apt-get install -y cloudflare-warp \
    && apt-get clean

# Add entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Start entrypoint script
CMD ["/entrypoint.sh"]
