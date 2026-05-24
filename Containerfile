# Allow build scripts to be referenced without being copied into the final image
ARG FEDORA_VERSION="44"

FROM scratch AS ctx
COPY build_files /

# Base Image
FROM registry.gitlab.com/origami-linux/images/origami:latest

ARG FEDORA_VERSION
ENV FEDORA_VERSION=${FEDORA_VERSION}

# Mounting additional files, such as systemd services
COPY system_files /

# Building the image
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
  --mount=type=cache,dst=/var/cache \
  --mount=type=cache,dst=/var/log \
  --mount=type=tmpfs,dst=/tmp \
  for script in /ctx/??-*.sh; do bash "$script"; done && \
  ostree container commit

### LINTING
## Verify final image and contents are correct.
RUN bootc container lint
