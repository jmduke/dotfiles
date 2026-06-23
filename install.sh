#!/usr/bin/env bash
set -e

DOTFILES="$(cd "$(dirname "$0")" && pwd)"

# (Re)create every symlink this repo owns, pointing at the repo's current location.
# Idempotent and path-aware, so `install.sh --link-only` repairs ~/.zshrc,
# ~/.gitconfig, ~/bin/* etc. after moving this repo — without the slow brew section.
link_dotfiles() {
    # Create the directories that the symlinks and tools below expect to exist.
    mkdir -p ~/downloads ~/.config/ghostty ~/.local/bin ~/.ipython/profile_default ~/bin ~/Library/LaunchAgents

    # Symlink config files and scripts from this repo into their expected locations
    # so edits here take effect immediately without copying.
    ln -sf "$DOTFILES/config/zshrc" ~/.zshrc
    ln -sf "$DOTFILES/config/zshenv" ~/.zshenv
    ln -sf "$DOTFILES/config/zprofile" ~/.zprofile
    ln -sf "$DOTFILES/config/psqlrc" ~/.psqlrc
    ln -sf "$DOTFILES/config/starship.toml" ~/.config/starship.toml
    ln -sf "$DOTFILES/config/gitconfig.ini" ~/.gitconfig
    ln -sf "$DOTFILES/config/ghostty.config" ~/.config/ghostty/config
    ln -sf "$DOTFILES/config/ipython_config.py" ~/.ipython/profile_default/ipython_config.py
    # Symlink workflow scripts into ~/bin so their bare-name aliases resolve.
    for script in commit-changes.sh stash.sh work-on-branch.sh work-on-worktree.sh; do
        ln -sf "$DOTFILES/scripts/$script" ~/bin/"$script"
    done
    # Symlink machine-health commands onto PATH (taxing = on-demand, taxing-watch = launchd worker).
    ln -sf "$DOTFILES/scripts/taxing" ~/.local/bin/taxing
    ln -sf "$DOTFILES/scripts/taxing-watch" ~/.local/bin/taxing-watch
    # Background CPU-hog watcher (launchd agent, checks every 60s).
    ln -sf "$DOTFILES/LaunchAgents/com.jmduke.taxing-watch.plist" ~/Library/LaunchAgents/com.jmduke.taxing-watch.plist
}

link_dotfiles
# Fast path: just refresh symlinks (e.g. after moving this repo) and stop here.
[ "$1" = "--link-only" ] && { echo "Symlinks refreshed from $DOTFILES"; exit 0; }

# Bootstrap Homebrew on a fresh machine and wire it into the login shell.
if ! command -v brew >/dev/null 2>&1; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo >> ~/.zprofile
    echo 'eval "$(/opt/homebrew/bin/brew shellenv zsh)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv zsh)"
fi

# Install/sync all CLI tools and GUI apps declared in the Brewfile.
# (atuin's history daemon is started here too, via restart_service in the Brewfile.)
brew bundle --file="$DOTFILES/Brewfile"

# Install gh extensions (gh dash = cross-repo PR/issue dashboard).
command -v gh >/dev/null 2>&1 && gh extension install dlvhdr/gh-dash 2>/dev/null || true

# Normalize ghq repo folders so each is named after its actual repo.
"$DOTFILES/scripts/ghq-normalize.sh"

# Keep AWDL (AirDrop/Handoff radio) disabled — it causes Wi-Fi latency spikes.
"$DOTFILES/scripts/disable-awdl.sh"

# Install mise (runtime/version manager) via its official installer.
if ! command -v mise >/dev/null 2>&1; then
    curl https://mise.run | sh
fi
