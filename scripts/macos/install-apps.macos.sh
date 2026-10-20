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
	font-fira-code-nerd-font

# Oh-my-zsh
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

go version
nvim --version | head -1
yazi --version | head -1
