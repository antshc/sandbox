# Copilot Instructions

## Project

Sandboxed container for Copilot agent. All outbound HTTP/HTTPS routed through mitmproxy firewall.

## Structure

- `Dockerfile` — Ubuntu 24.04, .NET 8, Node 22, mitmproxy, gh CLI
- `entrypoint.sh` — starts mitmproxy, sets proxy env vars, execs CMD
- `config/firewall.py` — mitmproxy addon, loads rules from `config/rules/`
- `config/rules/` — per-service allowlists (hosts + optional `check_request`)
- `docker-compose.yml` — build & run config
- `hello/` — test .NET app

## Build & Test

```bash
docker compose build
docker compose run --rm sandbox dotnet run
```

### Test Copilot connectivity

```bash
docker compose run --rm sandbox copilot -p "hello world"
```

Requires `COPILOT_GITHUB_TOKEN` env var set on the host (loaded via docker-compose).

## Security

Review `SECURITY.md` before making changes. Do not introduce:
- sudo or privilege escalation
- writable mounts for system directories (CA store, `/etc`)
- direct network access bypassing the proxy
- new capabilities or Docker socket mounts

## Key Conventions

- Container user: `ubuntu` (UID 1000), no sudo
- mitmproxy CA trusted at build time (no runtime privilege escalation)
- Firewall rules: add file in `config/rules/`, register in `config/rules/__init__.py`
- Workspace bind-mounted at `/home/ubuntu/workspace`
- Logs volume at `/var/log/mitmproxy`
