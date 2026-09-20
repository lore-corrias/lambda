# Allow build scripts to be referenced without being copied into the final image
ARG FEDORA_VERSION="44"

FROM scratch AS ctx
COPY build_files /

# Build the unsupported 55a4 driver separately so compilers and source code do
# not enter the final bootc image.
FROM fedora:${FEDORA_VERSION} AS goodix-libfprint-builder

ARG LIBFPRINT_REV="d1ca62a801aa565e67d1a2a47aaa7a33232b7990"

COPY third_party/goodix-27c6-55a4/patches/55a4-driver.patch /tmp/55a4-driver.patch

RUN dnf5 install -y --setopt=install_weak_deps=False \
      git \
      meson \
      ninja-build \
      gcc \
      gcc-c++ \
      cmake \
      libgusb-devel \
      nss-devel \
      openssl-devel \
      cairo-devel \
      glib2-devel \
      opencv-devel \
      gobject-introspection-devel \
      libgudev-devel \
      pixman-devel \
      doctest-devel && \
    git clone --branch 55b4-experimental \
      https://github.com/TheWeirdDev/libfprint.git /tmp/libfprint && \
    git -C /tmp/libfprint checkout -q "$LIBFPRINT_REV" && \
    test "$(git -C /tmp/libfprint rev-parse HEAD)" = "$LIBFPRINT_REV" && \
    git -C /tmp/libfprint apply /tmp/55a4-driver.patch && \
    meson setup /tmp/libfprint/build /tmp/libfprint \
      -Ddrivers=goodixtls55x4 -Dintrospection=false -Ddoc=false && \
    ninja -C /tmp/libfprint/build

# The permanent sensor-key write is deliberately deferred until a user starts
# the provision service on the real hardware. This stage supplies only its
# pinned USB protocol implementation.
FROM fedora:44 AS goodix-provisioner

ARG GOODIX_DUMP_REV="cc43bb3b3154a0bccc0412ae024013c7e1923139"

COPY third_party/goodix-27c6-55a4/scripts/provision_psk.py /tmp/provision_psk.py

RUN dnf5 install -y --setopt=install_weak_deps=False git && \
    git clone https://github.com/goodix-fp-linux-dev/goodix-fp-dump.git /tmp/goodix-fp-dump && \
    git -C /tmp/goodix-fp-dump checkout -q "$GOODIX_DUMP_REV" && \
    test "$(git -C /tmp/goodix-fp-dump rev-parse HEAD)" = "$GOODIX_DUMP_REV" && \
    sed -i '/^import periphery$/d; /^import spidev$/d' /tmp/goodix-fp-dump/protocol.py && \
    cp /tmp/provision_psk.py /tmp/goodix-fp-dump/ && \
    sed -i 's/except ImportError:/except ImportError as error:/' /tmp/goodix-fp-dump/provision_psk.py && \
    sed -i 's/print("provision_psk: run from the goodix-fp-dump directory",/print(f"provision_psk: could not import the bundled driver: {error}",/' /tmp/goodix-fp-dump/provision_psk.py

# Base Image
FROM ghcr.io/ublue-os/bluefin-dx:${FEDORA_VERSION}

ARG FEDORA_VERSION
ENV FEDORA_VERSION=${FEDORA_VERSION}

# Mounting additional files, such as systemd services
COPY system_files /
COPY --from=goodix-libfprint-builder /tmp/libfprint/build/libfprint/libfprint-2.so.2.0.0 /usr/lib64/libfprint-goodix/libfprint-2.so.2.0.0
COPY --from=goodix-provisioner /tmp/goodix-fp-dump/driver_55x4.py /tmp/goodix-fp-dump/goodix.py /tmp/goodix-fp-dump/protocol.py /tmp/goodix-fp-dump/tool.py /tmp/goodix-fp-dump/provision_psk.py /usr/libexec/goodix55a4/

# Building the image
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
  --mount=type=cache,dst=/var/cache \
  --mount=type=cache,dst=/var/log \
  --mount=type=tmpfs,dst=/tmp \
  for script in /ctx/??-*.sh; do bash "$script"; done && \
  ln -sf libfprint-2.so.2.0.0 /usr/lib64/libfprint-goodix/libfprint-2.so.2 && \
  ln -sf libfprint-2.so.2 /usr/lib64/libfprint-goodix/libfprint-2.so && \
  ostree container commit

### LINTING
## Verify final image and contents are correct.
RUN bootc container lint
