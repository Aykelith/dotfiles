#!/usr/bin/env bash
# ============================================================
# sync-to-repo.sh
#   Copies files from the machine into the repo (machine → repo).
#   Only copies if the source is newer than the destination.
#   Reads paths from sync.json in the repo root.
#
# Usage:
#   sync-to-repo.sh [OPTIONS]
#
# Options:
#   -s, --silent   Suppress all output (errors still print to stderr)
#   -h, --help     Show this help
# ============================================================

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "$SCRIPT_DIR/sync-base.sh" to-repo "$@"
