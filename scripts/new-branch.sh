#!/bin/bash

set -e

git checkout main

DATE=$(date +%Y-%m-%d)
BASE="justin/$DATE"
BRANCH="$BASE"
SUFFIX=2

while git show-ref --verify --quiet "refs/heads/$BRANCH"; do
  BRANCH="$BASE-$SUFFIX"
  SUFFIX=$((SUFFIX + 1))
done

git checkout -b "$BRANCH"
