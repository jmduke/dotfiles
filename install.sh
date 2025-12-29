#!/usr/bin/env bash
set -e

DOTFILES="$(cd "$(dirname "$0")" && pwd)"

mkdir -p ~/downloads ~/.config/ghostty ~/.local/bin ~/.ipython/profile_default ~/bin

ln -sf "$DOTFILES/config/zshrc" ~/.zshrc
ln -sf "$DOTFILES/config/starship.toml" ~/.config/starship.toml
ln -sf "$DOTFILES/config/gitconfig.ini" ~/.gitconfig
ln -sf "$DOTFILES/config/ghostty.config" ~/.config/ghostty/config
ln -sf "$DOTFILES/config/ipython_config.py" ~/.ipython/profile_default/ipython_config.py
ln -sf "$DOTFILES/scripts/commit-changes.sh" ~/bin/commit-changes.sh
ln -sf "$DOTFILES/scripts/launch-cursor.sh" ~/bin/launch-cursor.sh

brew install atuin bat difftastic eza fd gh mdcat pgcli tree zoxide yt-dlp
