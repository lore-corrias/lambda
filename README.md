# Lambda

Lambda is my personal [Fedora Atomic image](https://fedoraproject.org/atomic-desktops/). It is (currently) based on [Origami Linux](https://origami.wf/), which merges CachyOS's kernel with Fedora for faster performances. My personal twists, then, are:

- The substitution of [Cosmic Desktop](https://fedoraproject.org/it/atomic-desktops/cosmic/) for [Hyprland](https://hypr.land/)
- The installation of my [personal dotfiles](https://github.com/lore-corrias/dotfiles)
- The addition of some custom coprs and distros

You can find the specifics under `build_files` and `system_files`

## Installation

If you already have a fedora atomic desktop, you can rebase on Lambda with the following commands:

```bash
sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/lore-corrias/lambda:latest
systemctl reboot
```

After reboot:

```bash
rpm-ostree rebase ostree-image-signed:docker://ghcr.io/lore-corrias/lambda:latest
systemctl reboot
```

### Note

This distro is heavily customized on my needs, it is constantly changing and is overfit on my architecture (i.e., having no nvidia GPU I don't have nvidia drivers). If you want to try/fork it, feel free to do it :)
