#!/bin/bash

CONFIG_FILE="/opt/pullshot/pullshot.json"
PROJECT="$1"

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

fail() {
    echo -e "${RED}[!] $1${NC}"
    exit 1
}

ok() {
    echo -e "${GREEN}[✓] $1${NC}"
}

log() {
    echo -e "[*] $1"
}

[ -z "$PROJECT" ] && fail "Usage: pullshot <project-name>"

for dep in jq git; do
    command -v "$dep" >/dev/null 2>&1 || fail "Missing dependency: $dep"
done

[ ! -f "$CONFIG_FILE" ] && fail "Missing config file: $CONFIG_FILE"
[ ! -r "$CONFIG_FILE" ] && fail "Config file is not readable"
[ ! -w "$(dirname "$CONFIG_FILE")" ] && fail "No write access to config directory"

# Get values from config
REPO=$(jq -r --arg name "$PROJECT" '.[$name].repo' "$CONFIG_FILE")
DEST=$(jq -r --arg name "$PROJECT" '.[$name].path' "$CONFIG_FILE")
POST_INSTALL=$(jq -r --arg name "$PROJECT" '.[$name].post_install[]?' "$CONFIG_FILE")

[ "$REPO" == "null" ] && fail "Project '$PROJECT' not found in config"

log "Using repo: $REPO"
log "Target path: $DEST"

if [ -d "$DEST/.git" ]; then
    log "Directory exists, pulling latest changes..."
    git -C "$DEST" pull || fail "Git pull failed"
else
    log "Cloning repo..."
    git clone "$REPO" "$DEST" || fail "Git clone failed"
fi

cd "$DEST" || fail "Failed to cd into $DEST"

if [ -n "$POST_INSTALL" ]; then
    log "Running post-install commands..."
    while IFS= read -r cmd; do
        echo "[CMD] $cmd"
        eval "$cmd" || fail "Command failed: $cmd"
    done <<< "$POST_INSTALL"
fi

ok "Done."
