# Dotfiles Repository

Personal configuration files for a Linux (Debian-based) development environment.

## Repository Structure

- `.wezterm.lua` - WezTerm terminal emulator configuration
- `.config/nvim/` - Neovim configuration (git submodule: `git@github.com:Aykelith/neovim.dotfiles.git`)
- `.config/zed/` - Zed editor settings and keymap
- `.config/Antigravity/` - Antigravity editor settings and keybindings
- `.config/alacritty/` - Alacritty terminal configuration
- `scripts/linux/install-apps.debian.sh` - Debian app installation script

## Key Tools & Apps Configured

| Tool | Config Location | Notes |
|------|----------------|-------|
| Neovim | `.config/nvim/` | lazy.nvim, LSP, treesitter, git |
| WezTerm | `.wezterm.lua` | FiraCode Nerd Font, Pencil Dark theme |
| Alacritty | `.config/alacritty/` | Catppuccin Mocha theme |
| Zed | `.config/zed/` | Vim mode, Catppuccin Mocha dark theme |
| Antigravity | `.config/Antigravity/` | Settings and keybindings |

## Theme & Font

- Color scheme: **Catppuccin Mocha** (used across Alacritty, Zed, Neovim)
- Font: **FiraCode Nerd Font Mono**

## Neovim Submodule

The Neovim config is a separate git submodule. When cloning this repo, initialize it with:

```bash
git submodule update --init --recursive
```

## Install Script

`scripts/linux/install-apps.debian.sh` installs:
- Core tools: curl, wget, git, tmux, zsh, vim, unzip, cmake, g++
- Brave browser
- Go (v1.24.2)
- Neovim (v0.11.1)
- oh-my-zsh
- NVM (v0.40.3)
- FiraCode Nerd Font

## Shell

zsh with oh-my-zsh.
