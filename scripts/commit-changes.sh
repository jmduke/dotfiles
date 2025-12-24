#!/bin/bash

# Script to stage all changes and create a git commit with "WIP" message

# Stage all changes (added, modified, deleted)
git add -A

# Check if there are any changes
GIT_DIFF=$(git diff --cached --stat)
GIT_STATUS=$(git status --short)

if [ -z "$GIT_DIFF" ] && [ -z "$GIT_STATUS" ]; then
  echo "No changes to commit."
  exit 0
fi

# Commit with "WIP" message
echo ""
echo "Committing with message: WIP"
echo ""

git commit -m "WIP"

# Show latest commit summary
git --no-pager log -1 --oneline --decorate

