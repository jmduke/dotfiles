#! /bin/zsh
xargs brew install < <(grep -v "^#" brewfile.txt)