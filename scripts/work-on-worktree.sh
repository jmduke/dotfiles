#!/bin/zsh

if [ $# -eq 0 ]; then
    echo "Usage: wg <branch-name>"
    exit 1
fi

branch_name="$1"
# Escape slashes in branch name for directory creation
escaped_branch_name="${branch_name//\//-}"

# Create a new worktree for the branch
worktree_path="../monorepo-$escaped_branch_name"
echo "Creating worktree at: $worktree_path"
git worktree add -b "$branch_name" "$worktree_path"

# Switch to the new worktree
echo "Switching to: $worktree_path"
cd "$worktree_path" || { echo "Failed to cd to $worktree_path"; exit 1; }
echo "Now in: $(pwd)"
