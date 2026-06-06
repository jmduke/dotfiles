#!/usr/bin/env bash
set -e

DOTFILES="$(cd "$(dirname "$0")" && pwd)"

# Create the directories that the symlinks and tools below expect to exist.
mkdir -p ~/downloads ~/.config/ghostty ~/.local/bin ~/.ipython/profile_default ~/bin

# Symlink config files and scripts from this repo into their expected locations
# so edits here take effect immediately without copying.
ln -sf "$DOTFILES/config/zshrc" ~/.zshrc
ln -sf "$DOTFILES/config/starship.toml" ~/.config/starship.toml
ln -sf "$DOTFILES/config/gitconfig.ini" ~/.gitconfig
ln -sf "$DOTFILES/config/ghostty.config" ~/.config/ghostty/config
ln -sf "$DOTFILES/config/ipython_config.py" ~/.ipython/profile_default/ipython_config.py
# Symlink workflow scripts into ~/bin so their bare-name aliases resolve.
for script in commit-changes.sh stash.sh work-on-branch.sh work-on-worktree.sh; do
    ln -sf "$DOTFILES/scripts/$script" ~/bin/"$script"
done

# Bootstrap Homebrew on a fresh machine and wire it into the login shell.
if ! command -v brew >/dev/null 2>&1; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo >> ~/.zprofile
    echo 'eval "$(/opt/homebrew/bin/brew shellenv zsh)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv zsh)"
fi

# CLI tools and GUI apps installed via Homebrew.
brew install atuin bat difftastic eza fd gh llm mdcat neovim pgcli starship tree vim zoxide yt-dlp
brew install --cask zed conductor aqua

# Start atuin's sync daemon so shell history is captured across sessions.
brew services start atuin

# Install mise (runtime/version manager) via its official installer.
if ! command -v mise >/dev/null 2>&1; then
    curl https://mise.run | sh
fi
