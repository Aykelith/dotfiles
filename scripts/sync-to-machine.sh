#!/usr/bin/env bash
# ============================================================
# sync-to-machine.sh
#   Copies files from the repo onto the machine (repo → machine).
#   Only copies if the source is newer than the destination.
#   Reads paths from sync.json in the repo root.
#
# Usage:
#   sync-to-machine.sh [OPTIONS]
#
# Options:
#   -s, --silent   Suppress all output (errors still print to stderr)
#   -h, --help     Show this help
# ============================================================

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "$SCRIPT_DIR/sync-base.sh" to-machine "$@"
