#!/usr/bin/env bash
set -euo pipefail

echo "Verifying reverse proxy..."

sudo tree /var/lib/caddy-demo
resp=$(curl -u admin:yourpassword -s -w "%{http_code}" http://localhost:8080/health)
body=${resp::-3}
code=${resp: -3}

if [[ "$code" == "200" && "$body" == "ok" ]]; then
  echo "✅ Reverse proxy is working (200 + ok)"
else
  echo "❌ Test failed (code=$code, body='$body')"
  curl -iv -u admin:yourpassword -s http://localhost:8080/health
  exit 1
fi