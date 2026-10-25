#!/usr/bin/env bash
#
# docker-stop.macos.sh
#   Stop Docker Desktop (macOS only): quits the app, which shuts down the
#   engine and its VM, and waits for all of its processes to exit.
#
# Usage:
#   docker-stop.macos.sh [OPTIONS]
#
# Options:
#   -f, --force   Kill Docker Desktop's processes if it doesn't quit in time
#   -h, --help    Show this help
#

set -euo pipefail

DOCKER_APP="/Applications/Docker.app"
WAIT_SECONDS=60

usage() {
  sed -n '3,/^$/s/^# \{0,1\}//p' "$0"
}

FORCE=0

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    -f|--force) FORCE=1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
  shift
done

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This script is for macOS only." >&2
  exit 1
fi

docker_running() {
  pgrep -f "$DOCKER_APP/Contents/" &>/dev/null
}

wait_for_exit() {
  local i
  for ((i = 0; i < WAIT_SECONDS; i += 2)); do
    docker_running || return 0
    sleep 2
  done
  return 1
}

if ! docker_running; then
  echo "Docker Desktop is not running."
  exit 0
fi

echo "Stopping Docker Desktop..."
osascript -e 'quit app "Docker"' &>/dev/null || true

if wait_for_exit; then
  echo "Docker Desktop stopped."
  exit 0
fi

if [[ "$FORCE" -eq 0 ]]; then
  echo "Docker Desktop still running after ${WAIT_SECONDS}s; re-run with --force to kill it." >&2
  exit 1
fi

echo "Killing Docker Desktop processes..."
pkill -f "$DOCKER_APP/Contents/" || true
if wait_for_exit; then
  echo "Docker Desktop stopped."
  exit 0
fi
pkill -9 -f "$DOCKER_APP/Contents/" || true
sleep 2
if docker_running; then
  echo "Docker Desktop processes still running." >&2
  exit 1
fi
echo "Docker Desktop stopped."
