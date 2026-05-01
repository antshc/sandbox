# Security hardening

Known security gaps and their remediation status:

| Status | Severity | Risk | Issue | Fix |
|--------|----------|------|-------|-----|
| ☑ | 🔴 Critical | Sudo access | Agent had `NOPASSWD:ALL` sudo, could bypass container restrictions | Removed sudoers entry and sudo package |
| ☐ | 🔴 Critical | Proxy bypass | Agent can `unset HTTP_PROXY` or kill mitmproxy | Use iptables/network policy to force all traffic through proxy |
| ☐ | 🟠 High | Non-HTTP traffic | Raw TCP/UDP (SSH, DNS to external) isn't intercepted by mitmproxy | iptables rules to drop non-proxy traffic |
| ☐ | 🟠 High | DNS exfiltration | DNS queries go directly to host resolver, bypassing proxy | Lock DNS to internal resolver only |
| ☑ | 🟠 High | Network allowlist | All HTTP/HTTPS traffic filtered through mitmproxy firewall rules | Done |
| ☑ | 🟠 High | Non-root user | Container runs as `ubuntu` (UID 1000), not root | Done |
| ☐ | 🟡 Medium | Host filesystem | Mounted volumes may be writable, agent can modify host files | Use `:ro` on all mounts except workspace |
| ☐ | 🟡 Medium | Docker socket | If host Docker socket is mounted, agent gets full host access | Never mount `/var/run/docker.sock` |
| ☐ | 🟡 Medium | Environment variables | Secrets passed via env vars are readable by the agent | Minimize env vars, use mounted secrets files |
| ☐ | 🟡 Medium | Linux capabilities | Container runs with default capabilities | Drop all with `--cap-drop=ALL` |
| ☑ | 🟡 Medium | Read-only config | Firewall config mounted as `:ro` | Done |
