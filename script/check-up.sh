#!/usr/bin/env bash
#
# Ping the deployed app's /up health route every 2 minutes.
# Usage: ./script/check-up.sh [BASE_URL]
#   BASE_URL defaults to CHECK_UP_URL, then knowledge-vault on Render.
# Stop with Ctrl+C.

set -e

DEFAULT_URL="https://internalq.onrender.com"
BASE_URL="${1:-${CHECK_UP_URL:-$DEFAULT_URL}}"

# Strip trailing slash so we can append /up
BASE_URL="${BASE_URL%/}"
URL="${BASE_URL}/up"
INTERVAL=120

echo "Checking ${URL} every ${INTERVAL}s (Ctrl+C to stop)"
echo "---"

while true; do
  TS=$(date '+%Y-%m-%d %H:%M:%S')
  if HTTP=$(curl -s -o /dev/null -w '%{http_code}' --connect-timeout 10 --max-time 15 "$URL" 2>/dev/null); then
    if [[ "$HTTP" == "200" ]]; then
      echo "[$TS] UP (HTTP $HTTP)"
    else
      echo "[$TS] DOWN (HTTP $HTTP)"
    fi
  else
    echo "[$TS] DOWN (connection failed)"
  fi
  sleep "$INTERVAL"
done
