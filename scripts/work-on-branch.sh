#!/bin/zsh

if [ $# -eq 0 ]; then
    echo "Usage: w <branch-name>"
    exit 1
fi

branch_name="$1"

if git show-ref --verify --quiet refs/heads/"$branch_name"; then
    git checkout "$branch_name"
else
    git checkout -b "$branch_name"
fi

# Check if the branch exists on origin and pull if so
if git ls-remote --exit-code --heads origin "$branch_name" > /dev/null 2>&1; then
    git pull origin "$branch_name"
fi
