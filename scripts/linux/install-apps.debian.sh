#!/usr/bin/env bash

# Brave
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list
# End - Brave

sudo apt update

sudo apt install --yes \
	curl \
	wget \
       	git \
	tmux \
	zsh \
	vim \
	unzip \
	gettext \
	libtool \
	libtool-bin \
	autoconf \
	automake \
	cmake \
	g++ \
	pkg-config \
	brave-browser

# Go
sudo rm -f /usr/local/go
wget -O /tmp/go1.24.2.linux-amd64.tar.gz https://go.dev/dl/go1.24.2.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf /tmp/go1.24.2.linux-amd64.tar.gz
# End - Go

# Nvim
sudo rm -f /usr/local/nvim
wget -O /tmp/nvim-linux-x86_64.tar.gz https://github.com/neovim/neovim/releases/download/v0.11.1/nvim-linux-x86_64.tar.gz
sudo tar -C /usr/local -xzf /tmp/nvim-linux-x86_64.tar.gz
sudo mv /usr/local/nvim-linux-x86_64 /usr/local/nvim
# End - Nvim

# Oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

# FiraCode font
wget -O /tmp/FiraCode.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/FiraCode.zip
unzip /tmp/FiraCode.zip -d FiraCode
sudo cp /tmp/FiraCode/* /usr/local/share/fonts/
fc-cache -fv
# End - FiraCode font

export PATH=$PATH:/usr/local/nvim/bin:/usr/local/go/bin

go version
