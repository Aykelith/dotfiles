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
(Go, Neovim and Yazi are the latest brew versions, not pinned).

Scripts must run on macOS's stock bash 3.2 and BSD tools: no `mapfile`,
associative arrays, or GNU-only `cp`/`sed` flags.

## Shell

zsh with oh-my-zsh.

