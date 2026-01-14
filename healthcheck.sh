#!/bin/sh

# Check if wireproxy process is running
if ! pgrep -x "wireproxy" > /dev/null; then
    echo "Healthcheck Failed: wireproxy process not running."
    exit 1
fi

# Check if port 1080 is listening (using netstat as lsof/ss might not be in alpine)
if ! netstat -nlp | grep -q ":1080 "; then
    echo "Healthcheck Failed: Port 1080 not listening."
    exit 1
fi

exit 0
