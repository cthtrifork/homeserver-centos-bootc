#!/usr/bin/env bash
set -euo pipefail

echo "Verifying reverse proxy..."
curl -iv -u admin:yourpassword http://localhost:8080/
