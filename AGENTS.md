# AGENTS.md

## What this repo is

A custom bootc (bootable container) Linux image extending `registry.gitlab.com/origami-linux/images/origami:latest` (Fedora-based), targeting Hyprland desktop. Builds both a container image and bootable disk images (qcow2, raw, iso).

## Commands

```bash
# Build the container image (unprivileged podman)
just build [$image] [$tag]

# Build container + convert to bootable disk image (needs root podman)
just build-qcow2    # or build-raw, build-iso
just rebuild-qcow2  # skips separate build step, does container build + BIB in one

# Run built disk image in QEMU
just run-vm-qcow2   # or run-vm-raw, run-vm-iso

# Lint & format
just lint            # shellcheck on all .sh files
just format          # shfmt --write on all .sh files
just check           # just --fmt --check on all *.just files
just fix             # just --fmt on all *.just files

# Cleanup
just clean           # removes _build*, output/, previous.manifest.json,
                     # changelog.md, output.env
```

## Build pipeline order

1. Container image build (`Containerfile`) via `podman build`
2. Bootable disk conversion via `bootc-image-builder` (BIB) — requires root/sudo podman, see `_rootful_load_image` in Justfile

## Key architecture

| Directory | Purpose |
|---|---|
| `build_files/` | Scripts executed during `podman build` (not local dev scripts). Mounted via `FROM scratch AS ctx` bind-mount, not copied into the final image. |
| `system_files/` | Overlaid into the image root at build time (systemd units, yum repos, sysctl configs). |
| `disk_config/` | BIB disk image partitioning configs. |

## CI quirks

- **Pushes only on push to default branch**, never on PR. The CI workflow (`build.yml`) guards `push-to-registry` and `cosign sign` behind `github.event_name != 'pull_request'`.
- `build-disk.yml` triggers only on `workflow_dispatch` or PRs touching `disk_config/**`, the workflow itself, or the Containerfile.
- **Commented-out sections** in CI (rechunker, maximize-build-space) are intentionally disabled — do not uncomment unless asked.
- Image signing via cosign is optional; requires `SIGNING_SECRET` repo secret.

## Gotchas

- BIB commands (`build-qcow2`, `_build-bib`, etc.) need root podman. The Justfile helper `sudoif` handles privilege escalation. If you're not root and don't have sudo, these will fail.
- `IMAGE_NAME` defaults to the GitHub repo name (set in CI via `${{ github.event.repository.name }}`).
- The Containerfile uses `bootc container lint` as its final `RUN` — this validates the image at build time.
- `build-disk.yml` uses a forked BIB image (`ghcr.io/lorbuschris/bootc-image-builder`) pinned to a specific date, not the upstream `quay.io/centos-bootc/bootc-image-builder:latest`.
- Devcontainer runs as root with Podman socket forwarding — it's a podman-in-podman setup.
