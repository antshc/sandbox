from mitmproxy import http
import re

ALLOWED_SUBSCRIPTIONS = {
    "00000000-0000-0000-0000-000000000000"
}

ALLOWED_RESOURCE_GROUPS = {
    "rg-dev-sandbox",
    "rg-ci-tests"
}

ALLOWED_HOSTS = {
    "management.azure.com",
    "login.microsoftonline.com",
    "github.com",
    "api.github.com",
    "objects.githubusercontent.com",
    "raw.githubusercontent.com",
    "api.nuget.org",
    "www.nuget.org",
    # Copilot CLI
    "api.githubcopilot.com",
    "copilot-proxy.githubusercontent.com",
    "default.exp-tas.com",
    "registry.npmjs.org",
    "api.business.githubcopilot.com",
    "telemetry.business.githubcopilot.com",
}

ARM_RE = re.compile(
    r"^/subscriptions/([^/]+)/resourceGroups/([^/?#]+)(/.*)?$",
    re.IGNORECASE,
)

def request(flow: http.HTTPFlow) -> None:
    host = flow.request.pretty_host.lower()

    if host not in ALLOWED_HOSTS:
        flow.response = http.Response.make(
            403,
            f"Blocked host: {host}".encode(),
            {"Content-Type": "text/plain"},
        )
        return

    if host != "management.azure.com":
        return

    match = ARM_RE.match(flow.request.path)
    if not match:
        flow.response = http.Response.make(
            403,
            b"Blocked Azure ARM path",
            {"Content-Type": "text/plain"},
        )
        return

    subscription_id = match.group(1).lower()
    resource_group = match.group(2)

    if subscription_id not in ALLOWED_SUBSCRIPTIONS:
        flow.response = http.Response.make(
            403,
            b"Blocked Azure subscription",
            {"Content-Type": "text/plain"},
        )
        return

    if resource_group not in ALLOWED_RESOURCE_GROUPS:
        flow.response = http.Response.make(
            403,
            b"Blocked Azure resource group",
            {"Content-Type": "text/plain"},
        )