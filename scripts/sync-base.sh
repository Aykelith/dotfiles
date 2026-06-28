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
mapfile -t ENTRIES < <(jq -r '.[] | @tsv' "$SYNC_JSON")

for entry in "${ENTRIES[@]}"; do
    machine_raw=$(cut -f1 <<<"$entry")
    repo_raw=$(cut -f2 <<<"$entry")

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

    # cp -u handles "only if newer"; -r for directories
    cp -ru --preserve=timestamps "$src" "$dst" && log "SYNC  $src → $dst" \
        || echo "ERROR copying $src → $dst" >&2
done
