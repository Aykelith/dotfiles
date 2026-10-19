# Dotfiles Repository

Personal configuration files for a Linux development environment.

## Install Script

`scripts/linux/install-apps.debian.sh` installs:
- Core tools: curl, wget, git, tmux, zsh, vim, unzip, cmake, g++
- Brave browser
- Go (v1.24.2)
- Neovim (v0.11.1)
- oh-my-zsh
- NVM (v0.40.3)
- FiraCode Nerd Font

`scripts/macos/install-apps.macos.sh` installs the same set on macOS via Homebrew
(Go and Neovim are the latest brew versions, not pinned).

Scripts must run on macOS's stock bash 3.2 and BSD tools: no `mapfile`,
associative arrays, or GNU-only `cp`/`sed` flags.

## Shell

zsh with oh-my-zsh.

