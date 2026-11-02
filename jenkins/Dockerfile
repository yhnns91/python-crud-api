# Image Jenkins kustom untuk praktikum CI/CD (Windows/macOS/Linux).
# Menambahkan Python 3 (untuk stage syntax check) dan Docker CLI (untuk stage build & deploy).
# Docker CLI diambil dari image resmi docker:cli, jadi tidak perlu me-mount binary docker dari host.
FROM jenkins/jenkins:lts

USER root
RUN apt-get update \
 && apt-get install -y --no-install-recommends python3 curl git \
 && rm -rf /var/lib/apt/lists/*

COPY --from=docker:cli /usr/local/bin/docker /usr/local/bin/docker
COPY --from=docker:cli /usr/local/libexec/docker/cli-plugins/docker-buildx /usr/local/libexec/docker/cli-plugins/docker-buildx

USER jenkins
