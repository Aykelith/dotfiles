#!/usr/bin/env bash
# ============================================================
# run-init.sh
#   Runs all Ansible playbooks from scripts/init/ in order to
#   initialize a new machine.
#
# Usage:
#   run-init.sh [OPTIONS]
#
# Options:
#   -h, --help     Show this help
# ============================================================

set -euo pipefail

EXPECTED_PATH="$HOME/dotfiles/scripts/run-init.sh"
SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"

if [[ "$SCRIPT_PATH" != "$EXPECTED_PATH" ]]; then
    echo "Error: script must be run from $EXPECTED_PATH" >&2
    echo "       current path: $SCRIPT_PATH" >&2
    exit 1
fi

if ! command -v ansible-playbook &>/dev/null; then
    echo "Error: ansible is not installed." >&2
    echo "  Install it with: pip install --user ansible" >&2
    echo "  or:              sudo apt install ansible   (Debian)" >&2
    echo "  or:              brew install ansible       (macOS)" >&2
    exit 1
fi

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    sed -n '2,/^# ===/{/^# ===/d; s/^# \{0,3\}//; p}' "$0"
    exit 0
fi

INIT_DIR="$(dirname "$SCRIPT_PATH")/init"

for playbook in "$INIT_DIR"/[0-9]*.yml; do
    echo "==> Running $(basename "$playbook")"
    ansible-playbook "$playbook"
done

echo "Init complete."
