if [ ! -z "$(git ls-files -m)" ]; then
    git status
    echo
    echo '\033[1;93m!!! "generate-files" resulted in changes. Please run locally and commit the changes.'
    echo
    git diff --compact-summary
    echo
    exit 1
fi
exit 0
