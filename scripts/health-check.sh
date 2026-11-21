#!/usr/bin/env bash
set -euo pipefail

# Usage: ./scripts/health-check.sh https://<cloudfront-domain>
BASE_URL="${1:?Usage: health-check.sh <base-url>}"

for i in $(seq 1 10); do
  code=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/api/v1/health" || true)
  if [ "$code" = "200" ]; then
    echo "Healthy (HTTP 200)"
    exit 0
  fi
  echo "Attempt $i: HTTP $code, retrying in 10s..."
  sleep 10
done

echo "Health check failed"
exit 1
