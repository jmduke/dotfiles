#!/bin/bash

# Script to stage all changes and create a git commit with auto-generated message from cursor-agent

# Stage all changes (added, modified, deleted)
git add -A

# Get a description of the changes using cursor-agent
echo "Describing changes..."
GIT_DIFF=$(git diff --cached --stat)
GIT_STATUS=$(git status --short)

if [ -z "$GIT_DIFF" ] && [ -z "$GIT_STATUS" ]; then
  echo "No changes to commit."
  exit 0
fi

CURSOR_OUTPUT=$(cursor-agent --print "Generate a single-line git commit message (50-72 characters) describing the following staged changes.

Git status:
$GIT_STATUS

Git diff stats:
$GIT_DIFF" 2>&1)

# Extract the commit message from quotes in git commit command
COMMIT_MSG=$(echo "$CURSOR_OUTPUT" | sed -n 's/.*git commit -m "\([^"]*\)".*/\1/p' | head -n 1)

# If no quoted message found, try extracting from code blocks or plain text
if [ -z "$COMMIT_MSG" ]; then
  # Try to extract text between code block markers (using awk to avoid backtick issues)
  CODE_MARKER='```'
  COMMIT_MSG=$(echo "$CURSOR_OUTPUT" | awk -v marker="$CODE_MARKER" '$0 ~ marker {flag=!flag;next} flag' | head -n 1 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
fi

# If still empty, try to get first non-empty, non-header line
if [ -z "$COMMIT_MSG" ]; then
  COMMIT_MSG=$(echo "$CURSOR_OUTPUT" | grep -v "^$" | grep -v "^Commit" | grep -v "^Command" | grep -v '^\`\`\`' | grep -v "^---" | grep -v "^The command" | grep -v "^Aborting" | head -n 1 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
fi

# Commit the changes
if [ -z "$COMMIT_MSG" ]; then
  echo "Aborting: Failed to generate commit message."
  echo "Debug: cursor-agent output:"
  echo "$CURSOR_OUTPUT"
  exit 1
fi

echo ""
echo "Committing with message:"
echo "$COMMIT_MSG"
echo ""

git commit -m "$COMMIT_MSG"

# Show latest commit summary
git --no-pager log -1 --oneline --decorate
