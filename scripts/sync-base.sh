#!/usr/bin/env bash
# ============================================================
# sync-base.sh
#   Core sync logic shared by sync-to-repo.sh and sync-to-machine.sh.
#   Reads sync.json and copies entries in one direction.
#
# Usage:
#   sync-base.sh <direction> [OPTIONS]
#
# Arguments:
#   direction   "to-repo"    — copy machine path → repo path
#               "to-machine" — copy repo path → machine path
#
# Options:
#   -s, --silent   Suppress all output (errors still print to stderr)
#   -h, --help     Show this help
# ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SYNC_JSON="$REPO_ROOT/sync.json"

# ── args ────────────────────────────────────────────────────
DIRECTION="${1:-}"
SILENT=false

shift || true
while [[ $# -gt 0 ]]; do
    case "$1" in
        -s|--silent) SILENT=true ;;
        -h|--help)
            sed -n '/^# ====/,/^# ====/p' "$0"
            exit 0
            ;;
        *) echo "Unknown option: $1" >&2; exit 1 ;;
    esac
    shift
done

if [[ "$DIRECTION" != "to-repo" && "$DIRECTION" != "to-machine" ]]; then
    echo "Error: direction must be 'to-repo' or 'to-machine'" >&2
    exit 1
fi

log() { $SILENT || echo "$*"; }

# ── sync ────────────────────────────────────────────────────
while IFS=$'\t' read -r machine_raw repo_raw; do
    # expand env vars in paths
    machine_path=$(eval echo "$machine_raw")
    repo_path="$REPO_ROOT/$repo_raw"

    if [[ "$DIRECTION" == "to-repo" ]]; then
        src="$machine_path"
        dst="$repo_path"
    else
        src="$repo_path"
        dst="$machine_path"
    fi

    if [[ ! -e "$src" ]]; then
        log "SKIP  $src (not found)"
        continue
    fi

    # rsync -u handles "only if newer"; works with GNU rsync and macOS openrsync.
    # Directories get a trailing slash so contents land in $dst, not $dst/<name>.
    if [[ -d "$src" ]]; then
        mkdir -p "$dst"
        src="$src/"
    else
        mkdir -p "$(dirname "$dst")"
    fi

    rsync -rtu "$src" "$dst" && log "SYNC  $src → $dst" \
        || echo "ERROR copying $src → $dst" >&2
done < <(jq -r '.[] | @tsv' "$SYNC_JSON")

# ── homebrew ────────────────────────────────────────────────
# Snapshot installed formulae/casks/taps into a Brewfile. Restoring it installs
# software, so that happens in scripts/init/01-base-packages.yml, not here.
BREWFILE="$REPO_ROOT/data/homebrew/Brewfile"

if [[ "$DIRECTION" == "to-repo" ]] && command -v brew &>/dev/null; then
    mkdir -p "$(dirname "$BREWFILE")"
    brew bundle dump --force --file="$BREWFILE" >/dev/null 2>&1 && log "SYNC  brew bundle → $BREWFILE" \
        || echo "ERROR dumping Brewfile → $BREWFILE" >&2
fi
