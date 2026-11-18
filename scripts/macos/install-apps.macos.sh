#!/usr/bin/env bash
# macOS counterpart of scripts/linux/install-apps.debian.sh, using Homebrew.

set -euo pipefail

# Xcode Command Line Tools (compilers, make, git)
if ! xcode-select -p &>/dev/null; then
	xcode-select --install
	echo "Finish the Command Line Tools install, then re-run this script."
	exit 1
fi

# Homebrew
if ! command -v brew &>/dev/null; then
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
# End - Homebrew

brew update

brew install \
	curl \
	wget \
	git \
	tmux \
	zsh \
	vim \
	unzip \
	gettext \
	libtool \
	autoconf \
	automake \
	cmake \
	pkg-config \
	jq \
	go \
	neovim \
	yazi

brew install --cask \
	brave-browser \
	docker-desktop \
	font-fira-code-nerd-font

# Docker Desktop: don't start at login. Its data lives on an external SSD, so
# start it with data/scripts/docker-start.macos.sh, which checks the drive first.
DOCKER_SETTINGS="$HOME/Library/Group Containers/group.com.docker/settings-store.json"
mkdir -p "$(dirname "$DOCKER_SETTINGS")"
[[ -f "$DOCKER_SETTINGS" ]] || echo '{}' > "$DOCKER_SETTINGS"
jq '.AutoStart = false' "$DOCKER_SETTINGS" > "$DOCKER_SETTINGS.tmp"
mv "$DOCKER_SETTINGS.tmp" "$DOCKER_SETTINGS"

# Oh-my-zsh
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

go version
nvim --version | head -1
yazi --version | head -1
