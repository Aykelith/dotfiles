#!/usr/bin/env bash
#
# git-push-all-remotes.sh
#   Push the current branch to all configured git remotes.
#
# Usage:
#   git-push-all-remotes.sh [OPTIONS]
#
# Options:
#   -s, --silent    Suppress all output except errors
#

SILENT=0

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    -s|--silent) SILENT=1 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
  shift
done

BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
if [[ -z "$BRANCH" ]]; then
  echo "Not a git repository." >&2
  exit 1
fi

REMOTES=$(git remote)
if [[ -z "$REMOTES" ]]; then
  echo "No remotes configured." >&2
  exit 1
fi

FAILED=0

while IFS= read -r REMOTE; do
  [[ "$SILENT" -eq 0 ]] && echo "Pushing $BRANCH → $REMOTE..."
  if [[ "$SILENT" -eq 1 ]]; then
    git push "$REMOTE" "$BRANCH" --quiet
  else
    git push "$REMOTE" "$BRANCH"
  fi
  if [[ $? -ne 0 ]]; then
    echo "Failed: $REMOTE" >&2
    FAILED=1
  elif [[ "$SILENT" -eq 0 ]]; then
    echo "Done: $REMOTE"
  fi
done <<< "$REMOTES"

exit $FAILED
