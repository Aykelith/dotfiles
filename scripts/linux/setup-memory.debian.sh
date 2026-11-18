#!/usr/bin/env bash
# Keep the machine usable when builds run out of RAM.
#   zram:     compressed swap in RAM (zstd, half of RAM), used before the swap file.
#   earlyoom: kills a process before the system freezes, compilers first.
# Safe to re-run.
set -euo pipefail

sudo apt install --yes zram-tools earlyoom

printf 'ALGO=zstd\nPERCENT=50\nPRIORITY=100\n' | sudo tee /etc/default/zramswap >/dev/null
sudo systemctl restart zramswap

# Swapping to zram is cheap, so let the kernel use it (Debian default is 60).
echo 'vm.swappiness=100' | sudo tee /etc/sysctl.d/99-zram.conf >/dev/null
sudo sysctl -q -p /etc/sysctl.d/99-zram.conf

# Kill at 5% free RAM and swap; prefer compilers/linkers, never the session.
# systemd splits $EARLYOOM_ARGS on spaces without removing quotes, so the
# regexes carry no quotes and no spaces.
sudo tee /etc/default/earlyoom >/dev/null <<'EOF'
EARLYOOM_ARGS="-m 5 -s 5 -r 3600 --prefer (^|/)(rustc|cc1|cc1plus|ld|ld\.lld|rust-lld|mold)$ --avoid (^|/)(init|systemd|sshd|Xorg|Xwayland|gnome-shell|kwin_wayland|plasmashell)$"
EOF
sudo systemctl enable --now earlyoom
sudo systemctl restart earlyoom

swapon --show
systemctl is-active earlyoom
