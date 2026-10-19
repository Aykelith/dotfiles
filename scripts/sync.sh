#!/usr/bin/env bash

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# ─── FILES AND DIRECTORIES TO TRACK ──────────────────────────────────────────
# Add paths relative to $HOME that you want to keep in sync with this repo.
TRACKED=(
    ".wezterm.lua"
    ".zshrc"
    ".config/zed/settings.json"
    ".config/zed/keymap.json"
    ".config/Antigravity/User/settings.json"
    ".config/Antigravity/User/keybindings.json"
    ".config/alacritty/alacritty.toml"
    ".config/alacritty/catppuccin-mocha.toml"
    ".config/Code/User/settings.json"
    ".config/Cursor/User/settings.json"
    ".config/Cursor/User/keybindings.json"
)
# ─────────────────────────────────────────────────────────────────────────────

# ─── PER-FILE VARIABLE FILTERS ────────────────────────────────────────────────
# List variable names to strip from a file before copying it to the repo.
# Matches both "VAR=..." and "export VAR=..." forms.
# Add a case per file: ".path/to/file") echo "VAR1 VAR2" ;;
# (a function instead of an associative array so it runs on macOS's bash 3.2)
strip_vars_for() {
    case "$1" in
        ".zshrc") echo "GITLAB_AUTH_TOKEN" ;;
    esac
}
# ─────────────────────────────────────────────────────────────────────────────

ERRORS=0
COPIED=0
UP_TO_DATE=0

for path in "${TRACKED[@]}"; do
    local_path="$HOME/$path"
    repo_path="$REPO_DIR/$path"

    if [ ! -e "$local_path" ]; then
        echo "ERROR  $path (not found on local)"
        ERRORS=$((ERRORS + 1))
        continue
    fi

    if [ -d "$local_path" ]; then
        if [ ! -d "$repo_path" ] || ! diff -rq "$local_path" "$repo_path" >/dev/null 2>&1; then
            echo "COPY   $path"
            mkdir -p "$repo_path"
            rsync -a --delete "$local_path/" "$repo_path/"
            COPIED=$((COPIED + 1))
        else
            echo "OK     $path"
            UP_TO_DATE=$((UP_TO_DATE + 1))
        fi
    else
        # Build a filtered version of the file if STRIP_VARS are defined for it
        source_path="$local_path"
        tmp_file=""
        strip_vars="$(strip_vars_for "$path")"
        if [ -n "$strip_vars" ]; then
            tmp_file="$(mktemp)"
            sed_args=()
            for var in $strip_vars; do
                # -E (ERE) works with both GNU and BSD sed; \+ and \? are GNU-only
                sed_args+=(-e "/^[[:space:]]*(export[[:space:]]+)?${var}[[:space:]]*=/d")
            done
            sed -E "${sed_args[@]}" "$local_path" > "$tmp_file"
            source_path="$tmp_file"
        fi

        if [ ! -f "$repo_path" ] || ! diff -q "$source_path" "$repo_path" >/dev/null 2>&1; then
            echo "COPY   $path"
            mkdir -p "$(dirname "$repo_path")"
            cp "$source_path" "$repo_path"
            COPIED=$((COPIED + 1))
        else
            echo "OK     $path"
            UP_TO_DATE=$((UP_TO_DATE + 1))
        fi

        [ -n "$tmp_file" ] && rm -f "$tmp_file"
    fi
done

echo ""
echo "Copied: $COPIED  Up-to-date: $UP_TO_DATE  Errors: $ERRORS"

[ "$ERRORS" -gt 0 ] && exit 1 || exit 0
