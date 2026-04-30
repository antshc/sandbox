#!/usr/bin/env bash
set -euo pipefail

mitmdump \
  --listen-host 127.0.0.1 \
  --listen-port 8080 \
  -s /etc/mitmproxy/azure_firewall.py \
  --set block_global=false \
  >/tmp/mitmproxy.log 2>&1 &

export HTTP_PROXY=http://127.0.0.1:8080
export HTTPS_PROXY=http://127.0.0.1:8080
export ALL_PROXY=http://127.0.0.1:8080
export NO_PROXY=localhost,127.0.0.1

exec "$@"