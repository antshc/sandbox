# Copilot Sandbox — Quickstart

A sandboxed Docker container for the Copilot agent. All outbound traffic is forced through a mitmproxy firewall — only Copilot, GitHub, npm, and NuGet endpoints are permitted by default.

## Prerequisites

- Docker with Compose v2
- A GitHub token with Copilot access

## 1. Set your token

```bash
export COPILOT_GITHUB_TOKEN=<your-github-token>
```

## 2. Mount your workspace

Edit `docker-compose.yml` and uncomment the workspace volume, pointing it to your project:

```yaml
volumes:
  # ...
  - /absolute/path/to/your/project:/home/ubuntu/workspace
```

## 3. Run

```bash
# docker compose
docker compose run --rm sandbox cop "explain this codebase"

# docker run
docker run --rm \
  --cap-add NET_ADMIN --cap-add SETUID --cap-add SETGID --cap-drop ALL \
  -e COPILOT_GITHUB_TOKEN="$COPILOT_GITHUB_TOKEN" \
  -v "$(pwd)/firewall:/etc/mitmproxy/config:ro" \
  -v "$(pwd)/logs/mitmproxy:/var/log/mitmproxy" \
  -v "$(pwd)/logs/copilot:/var/log/copilot" \
  -v "/absolute/path/to/your/project:/home/ubuntu/workspace" \
  khdevnet/sandbox cop "explain this codebase"

# Interactive shell
docker compose run --rm -it sandbox bash
```

> On first run Docker pulls the image automatically (may take a few minutes).

## Configuration

All Copilot CLI flags are configurable via environment variables — set them in your shell or add them to `docker-compose.yml` under `environment:`.

| Variable | Default | Description |
|----------|---------|-------------|
| `COPILOT_GITHUB_TOKEN` | *(required)* | GitHub token for Copilot CLI |
| `COPILOT_MODEL` | `claude-haiku-4.5` | Model: `claude-haiku-4.5`, `claude-sonnet-4.6`, `claude-opus-4` |
| `COPILOT_EFFORT` | *(unset)* | Effort level: `low`, `medium`, `high`. Omitted when unset — not all models support it. |
| `COPILOT_OUTPUT_FORMAT` | `text` | Output format: `text`, `json`, `stream-json` |
| `COPILOT_ALLOW_ALL_TOOLS` | `true` | Pass `--allow-all-tools` to the CLI |
| `COPILOT_NO_ASK_USER` | `true` | Pass `--no-ask-user` to the CLI |
| `COPILOT_LOG_LEVEL` | `info` | Log verbosity: `none`, `error`, `warning`, `info`, `debug`, `all` |
| `SANDBOX_TAG` | `latest` | Docker Hub image tag to pull |
| `FIREWALL_ENVS` | `copilot,github,nuget,npm` | Comma-separated network allowlists to enable |

```bash
# Use a more powerful model with high effort
COPILOT_MODEL=claude-sonnet-4.6 COPILOT_EFFORT=high \
  docker compose run --rm sandbox cop "refactor the auth module"
```

## Logs

Proxy and Copilot CLI logs are written to `./logs/` on the host:

| Path | Contents |
|------|---------|
| `./logs/mitmproxy/` | Network proxy logs (timestamped) |
| `./logs/copilot/` | Copilot CLI session logs |

## Optional startup script

Create a `setup.sh` and mount it by uncommenting the line in `docker-compose.yml`:

```yaml
- ./setup.sh:/etc/sandbox/setup.sh:ro
```

The script runs as the `ubuntu` user after the proxy is ready, before your command. If it exits non-zero the container aborts.

Available env vars in the script: `COPILOT_GITHUB_TOKEN`, `GH_TOKEN`, `HTTP_PROXY`, `HTTPS_PROXY`, `NODE_EXTRA_CA_CERTS`.

## Extending the firewall

Add a new rule file under `firewall/rules/` and register it in `firewall/rules/__init__.py`:

```python
# firewall/rules/myservice.py
ENVIRONMENT = {
    "hosts": {"api.myservice.com"},
}
```

```python
# firewall/rules/__init__.py
from .myservice import ENVIRONMENT as MYSERVICE

ENVIRONMENTS = {
    # ... existing entries ...
    "myservice": MYSERVICE,
}
```

Then enable it via `FIREWALL_ENVS`:

```bash
FIREWALL_ENVS=copilot,github,myservice docker compose run --rm sandbox cop "..."
```
