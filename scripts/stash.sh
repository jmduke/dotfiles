#!/bin/bash

DATE=$(date +%Y%m%d)

# Create branch name
BRANCH_NAME="justin/${DATE}-stash"

# Create and checkout new branch
if git show-ref --verify --quiet "refs/heads/$BRANCH_NAME"; then
    git checkout "$BRANCH_NAME"
else
    git checkout -b "$BRANCH_NAME"
fi

git add .
git commit -m "Stash commit for $DATE"

# Print confirmation
echo "Created branch '$BRANCH_NAME' with staged changes"
