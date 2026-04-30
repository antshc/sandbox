FROM mcr.microsoft.com/dotnet/sdk:8.0

ARG USERNAME=agent
ARG USER_UID=1000
ARG USER_GID=1000

ENV DEBIAN_FRONTEND=noninteractive
ENV DOTNET_CLI_TELEMETRY_OPTOUT=1
ENV DOTNET_NOLOGO=1

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        curl wget git jq ca-certificates gnupg sudo unzip bash openssh-client \
        python3 python3-pip python3-venv \
    && curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && npm install -g @github/copilot \
    && python3 -m venv /opt/mitmproxy \
    && /opt/mitmproxy/bin/pip install --no-cache-dir mitmproxy \
    && ln -s /opt/mitmproxy/bin/mitmdump /usr/local/bin/mitmdump \
    && groupadd --gid ${USER_GID} ${USERNAME} \
    && useradd --uid ${USER_UID} --gid ${USER_GID} -m ${USERNAME} -s /bin/bash \
    && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME} \
    && chmod 0440 /etc/sudoers.d/${USERNAME} \
    && mkdir -p /etc/mitmproxy /workspace \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENV HTTP_PROXY=http://127.0.0.1:8080
ENV HTTPS_PROXY=http://127.0.0.1:8080
ENV ALL_PROXY=http://127.0.0.1:8080
ENV NO_PROXY=localhost,127.0.0.1

RUN chmod -R a+rx /etc/mitmproxy \
    && chown -R ${USERNAME}:${USERNAME} /workspace /home/${USERNAME} /etc/mitmproxy

USER ${USERNAME}
WORKDIR /workspace

ENTRYPOINT ["/etc/mitmproxy/entrypoint.sh"]
CMD ["/bin/bash"]