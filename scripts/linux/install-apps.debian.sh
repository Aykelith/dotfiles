#!/usr/bin/env bash

ask() {
	read -r -p "$1 [y/N] " reply
	case "$reply" in [yY]*) return 0 ;; *) return 1 ;; esac
}

# A display server is running, or the machine boots into one
has_gui() {
	[ -n "${DISPLAY:-}${WAYLAND_DISPLAY:-}" ] || [ "$(systemctl get-default 2>/dev/null)" = "graphical.target" ]
}

# Ask up front so the rest runs unattended
ask "Install Go?" && INSTALL_GO=1
ask "Install yazi?" && INSTALL_YAZI=1
has_gui && INSTALL_BRAVE=1

# Brave
if [ -n "$INSTALL_BRAVE" ]; then
	sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg

	echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list
fi
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
	file \
	${INSTALL_BRAVE:+brave-browser}

# Go
if [ -n "$INSTALL_GO" ]; then
	sudo rm -f /usr/local/go
	wget -O /tmp/go1.24.2.linux-amd64.tar.gz https://go.dev/dl/go1.24.2.linux-amd64.tar.gz
	sudo tar -C /usr/local -xzf /tmp/go1.24.2.linux-amd64.tar.gz
fi
# End - Go

# Yazi
if [ -n "$INSTALL_YAZI" ]; then
	wget -O /tmp/yazi-x86_64-unknown-linux-gnu.zip https://github.com/sxyazi/yazi/releases/download/v26.9.1/yazi-x86_64-unknown-linux-gnu.zip
	unzip -o /tmp/yazi-x86_64-unknown-linux-gnu.zip -d /tmp
	sudo install -m 755 /tmp/yazi-x86_64-unknown-linux-gnu/yazi /tmp/yazi-x86_64-unknown-linux-gnu/ya /usr/local/bin/
fi
# End - Yazi

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

export PATH=$PATH:/usr/local/go/bin

if [ -n "$INSTALL_GO" ]; then
	go version
fi
