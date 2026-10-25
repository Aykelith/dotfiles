#!/usr/bin/env bash
#
# docker-start.macos.sh
#   Start Docker Desktop (macOS only) after checking that its data folder
#   (where Docker.raw lives) is available, so a missing external SSD never
#   makes Docker silently create a fresh disk image somewhere else.
#
# Usage:
#   docker-start.macos.sh [OPTIONS]
#
# Options:
#   -d, --data-dir DIR   Start with DIR as the data folder (this start only)
#   -p, --permanent      With --data-dir, also save DIR as the default
#   -n, --no-wait        Don't wait for the Docker engine to be ready
#   -h, --help           Show this help
#
# The data folder is the first one set of:
#   --data-dir DIR
#   $DOCKER_DESKTOP_DATA_DIR
#   the saved default in ~/.config/docker-desktop/data-dir
#   /Volumes/AlexSSDMacDocker/Docker/DockerDesktop
#
# If the folder isn't available, asks whether to stop or to use another
# folder, and whether that change is temporary or permanent.
#

set -euo pipefail

DEFAULT_DATA_DIR="/Volumes/AlexSSDMacDocker/Docker/DockerDesktop"
SAVED_DATA_DIR_FILE="$HOME/.config/docker-desktop/data-dir"
SETTINGS="$HOME/Library/Group Containers/group.com.docker/settings-store.json"
DOCKER_APP="/Applications/Docker.app"
WAIT_SECONDS=120

usage() {
  sed -n '3,/^$/s/^# \{0,1\}//p' "$0"
}

DATA_DIR=""
PERMANENT=0
WAIT=1

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    -d|--data-dir)
      [[ "$#" -ge 2 ]] || { echo "Missing value for $1" >&2; exit 1; }
      DATA_DIR="$2"
      shift
      ;;
    -p|--permanent) PERMANENT=1 ;;
    -n|--no-wait) WAIT=0 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
  shift
done

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This script is for macOS only." >&2
  exit 1
fi

if [[ ! -d "$DOCKER_APP" ]]; then
  echo "Docker Desktop not found at $DOCKER_APP." >&2
  exit 1
fi

if ! command -v jq &>/dev/null; then
  echo "jq is required (brew install jq)." >&2
  exit 1
fi

if [[ "$PERMANENT" -eq 1 && -z "$DATA_DIR" ]]; then
  echo "--permanent needs --data-dir." >&2
  exit 1
fi

docker_running() {
  pgrep -f "$DOCKER_APP/Contents/" &>/dev/null
}

current_data_dir() {
  [[ -f "$SETTINGS" ]] && jq -r '.DataFolder // empty' "$SETTINGS"
}

expand_path() {
  local path="${1/#\~/$HOME}"
  # Drop a trailing slash so paths compare equal to the stored DataFolder
  [[ "$path" != "/" ]] && path="${path%/}"
  echo "$path"
}

# Prints why DIR can't be used and returns 1, or returns 0 if it can.
check_data_dir() {
  local dir="$1" volume

  if [[ "$dir" != /* ]]; then
    echo "not an absolute path"
    return 1
  fi

  if [[ "$dir" == /Volumes/* ]]; then
    volume="/Volumes/$(echo "${dir#/Volumes/}" | cut -d/ -f1)"
    if ! mount | grep -qF " on $volume ("; then
      echo "volume $volume is not mounted"
      return 1
    fi
  fi

  if [[ ! -d "$dir" ]]; then
    echo "directory does not exist"
    return 1
  fi

  if [[ ! -w "$dir" ]]; then
    echo "directory is not writable"
    return 1
  fi
}

save_default() {
  mkdir -p "$(dirname "$SAVED_DATA_DIR_FILE")"
  echo "$1" > "$SAVED_DATA_DIR_FILE"
  echo "Saved $1 as the default data folder ($SAVED_DATA_DIR_FILE)."
  if [[ -n "${DOCKER_DESKTOP_DATA_DIR:-}" ]]; then
    echo "Note: \$DOCKER_DESKTOP_DATA_DIR is set and still takes precedence over it."
  fi
}

# Asks for a new data folder until one is usable; sets DATA_DIR.
ask_new_data_dir() {
  local dir reason answer

  while true; do
    read -r -p "New data folder: " dir
    dir="$(expand_path "$dir")"
    [[ -n "$dir" ]] || continue

    if [[ "$dir" == /* && ! -e "$dir" ]]; then
      read -r -p "$dir does not exist. Create it? [y/N] " answer
      case "$answer" in
        y|Y) mkdir -p "$dir" || continue ;;
        *) continue ;;
      esac
    fi

    if reason="$(check_data_dir "$dir")"; then
      DATA_DIR="$dir"
      return
    fi
    echo "Can't use $dir: $reason"
  done
}

# Resolve the data folder
if [[ -n "$DATA_DIR" ]]; then
  DATA_DIR="$(expand_path "$DATA_DIR")"
elif [[ -n "${DOCKER_DESKTOP_DATA_DIR:-}" ]]; then
  DATA_DIR="$(expand_path "$DOCKER_DESKTOP_DATA_DIR")"
elif [[ -s "$SAVED_DATA_DIR_FILE" ]]; then
  DATA_DIR="$(expand_path "$(head -n 1 "$SAVED_DATA_DIR_FILE")")"
else
  DATA_DIR="$DEFAULT_DATA_DIR"
fi

if docker_running; then
  CURRENT="$(current_data_dir || true)"
  if [[ "$CURRENT" == "$DATA_DIR" ]]; then
    echo "Docker Desktop is already running with data folder $DATA_DIR."
    exit 0
  fi
  echo "Docker Desktop is already running with data folder ${CURRENT:-unknown}." >&2
  echo "Stop it first (docker-stop.macos.sh) to start it with $DATA_DIR." >&2
  exit 1
fi

# Check the data folder, asking what to do if it's unavailable
if ! REASON="$(check_data_dir "$DATA_DIR")"; then
  echo "Docker data folder unavailable: $DATA_DIR ($REASON)"

  if [[ ! -t 0 ]]; then
    echo "Not starting Docker Desktop." >&2
    exit 1
  fi

  while true; do
    read -r -p "[s]top (don't start Docker) or [c]hange the data folder? [s/c] " ANSWER
    case "$ANSWER" in
      s|S|"") echo "Not starting Docker Desktop."; exit 1 ;;
      c|C) break ;;
    esac
  done

  ask_new_data_dir

  while true; do
    read -r -p "Is this change [t]emporary (this start only) or [p]ermanent? [t/p] " ANSWER
    case "$ANSWER" in
      t|T) PERMANENT=0; break ;;
      p|P) PERMANENT=1; break ;;
    esac
  done
fi

if [[ "$PERMANENT" -eq 1 ]]; then
  save_default "$DATA_DIR"
fi

if [[ ! -f "$DATA_DIR/Docker.raw" ]]; then
  echo "Note: no Docker.raw in $DATA_DIR; Docker will start with an empty disk image."
fi

# Point Docker Desktop at the data folder and keep it from starting at login
mkdir -p "$(dirname "$SETTINGS")"
[[ -f "$SETTINGS" ]] || echo '{}' > "$SETTINGS"
jq --arg dir "$DATA_DIR" '.DataFolder = $dir | .AutoStart = false' "$SETTINGS" > "$SETTINGS.tmp"
mv "$SETTINGS.tmp" "$SETTINGS"

echo "Starting Docker Desktop with data folder $DATA_DIR..."
open -g -a "$DOCKER_APP"

[[ "$WAIT" -eq 1 ]] || exit 0

DOCKER="$(command -v docker || echo "$HOME/.docker/bin/docker")"
for ((i = 0; i < WAIT_SECONDS; i += 2)); do
  if "$DOCKER" info &>/dev/null; then
    echo "Docker is ready."
    exit 0
  fi
  sleep 2
done

echo "Docker engine not ready after ${WAIT_SECONDS}s." >&2
exit 1
