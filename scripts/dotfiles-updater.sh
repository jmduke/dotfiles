#!/bin/bash

# Dotfiles Auto-Updater
# Checks https://github.com/jmduke/dotfiles for updates and applies them

set -euo pipefail

DOTFILES_REPO="https://github.com/jmduke/dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"
LOG_FILE="$HOME/.dotfiles-updater.log"
LOCK_FILE="/tmp/dotfiles-updater.lock"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

cleanup() {
    rm -f "$LOCK_FILE"
}

trap cleanup EXIT

# Check if another instance is running
if [ -f "$LOCK_FILE" ]; then
    log "Another instance is already running. Exiting."
    exit 0
fi

touch "$LOCK_FILE"

log "Starting dotfiles update check..."

# Clone repo if it doesn't exist
if [ ! -d "$DOTFILES_DIR" ]; then
    log "Dotfiles directory not found. Cloning repository..."
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
    cd "$DOTFILES_DIR"
    
    # Run initial setup if install script exists
    if [ -f "./install.sh" ]; then
        log "Running initial installation..."
        bash ./install.sh
    fi
else
    cd "$DOTFILES_DIR"
    
    # Fetch latest changes
    log "Fetching latest changes..."
    git fetch origin
    
    # Check if there are updates
    LOCAL=$(git rev-parse HEAD)
    REMOTE=$(git rev-parse origin/main)
    
    if [ "$LOCAL" = "$REMOTE" ]; then
        log "Already up to date."
        exit 0
    fi
    
    log "Updates available. Pulling changes..."
    
    # Stash any local changes
    if ! git diff --quiet || ! git diff --staged --quiet; then
        log "Stashing local changes..."
        git stash push -m "Auto-stash before dotfiles update $(date '+%Y-%m-%d %H:%M:%S')"
    fi
    
    # Pull latest changes
    git pull origin main
    
    # Run update/install script if it exists
    if [ -f "./install.sh" ]; then
        log "Running installation script..."
        bash ./install.sh
    elif [ -f "./update.sh" ]; then
        log "Running update script..."
        bash ./update.sh
    elif [ -f "./Makefile" ]; then
        log "Running make install..."
        make install
    else
        log "No installation script found. You may need to manually apply changes."
    fi
    
    # Check if there were stashed changes
    if git stash list | grep -q "Auto-stash before dotfiles update"; then
        log "Attempting to restore stashed changes..."
        git stash pop || log "Failed to restore stashed changes. Please check manually."
    fi
    
    log "Update completed successfully!"
fi