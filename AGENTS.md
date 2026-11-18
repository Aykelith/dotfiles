# Dotfiles Repository

Personal configuration files for a Linux development environment.

## Install Script

`scripts/linux/install-apps.debian.sh` installs:
- Core tools: curl, wget, git, tmux, zsh, vim, unzip, cmake, g++
- Brave browser, only on machines with a GUI (display server running or `graphical.target` default)
- Go (v1.24.2), if the user answers yes at the prompt
- Yazi (v26.9.1), if the user answers yes at the prompt; config in `data/config/yazi` opens text files in nvim in a new terminal
- oh-my-zsh
- NVM (v0.40.3)
- FiraCode Nerd Font

On Linux, Neovim is installed to `~/local-apps/nvim` by the nvim config repo's
own init script (run from `scripts/init/03-neovim-config.yml`), not here.

`scripts/macos/install-apps.macos.sh` installs the same set on macOS via Homebrew
(Go, Neovim and Yazi are the latest brew versions, not pinned), plus Docker Desktop
with start-at-login turned off.

Scripts must run on macOS's stock bash 3.2 and BSD tools: no `mapfile`,
associative arrays, or GNU-only `cp`/`sed` flags.

## Docker Desktop (macOS)

Docker's data folder (`Docker.raw`) lives on an external SSD, so Docker is
started and stopped by hand instead of at login:
- `data/scripts/docker-start.macos.sh` (alias `xal-docker-start`) checks that the
  data folder is mounted and writable, sets it as Docker's `DataFolder`, and starts
  Docker. Folder: `--data-dir`, else `$DOCKER_DESKTOP_DATA_DIR`, else the saved
  default in `~/.config/docker-desktop/data-dir`, else
  `/Volumes/AlexSSDMacDocker/Docker/DockerDesktop`. If unavailable it asks to stop
  or use another folder, temporarily or permanently.
- `data/scripts/docker-stop.macos.sh` (alias `xal-docker-stop`) quits Docker.

## Shell

zsh with oh-my-zsh.


## Rust builds

Parallel cargo builds across projects ran out of RAM, so:
- `data/dotfiles/scripts.env` defines a `cargo` zsh function that queues
  build/check/clippy/test/bench/doc/install machine-wide with `flock`
  (one at a time). `cargo run` and others are not queued. Bypass: `command cargo`.
- Debug-info level is a per-project choice (agents-tools `xal-new-project`),
  not set globally here. No mold needed: Rust >= 1.90 links with rust-lld.
