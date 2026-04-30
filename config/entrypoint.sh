#!/usr/bin/env bash
set -euo pipefail

mitmdump \
  --listen-host 127.0.0.1 \
  --listen-port 8080 \
  -s /etc/mitmproxy/firewall_rules.py \
  --set block_global=false \
  >/tmp/mitmproxy.log 2>&1 &

sleep 1

export HTTP_PROXY=http://127.0.0.1:8080
export HTTPS_PROXY=http://127.0.0.1:8080
export ALL_PROXY=http://127.0.0.1:8080
export NO_PROXY=localhost,127.0.0.1
export NODE_EXTRA_CA_CERTS="$HOME/.mitmproxy/mitmproxy-ca-cert.pem"

exec "$@"