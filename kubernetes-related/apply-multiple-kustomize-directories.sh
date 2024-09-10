#!/bin/bash

# List all directories with changes in the current root directory

# Get the file paths with changes
DIRECTORIES_WITH_CHANGES=$(git diff --name-only|sed 's/\/[^/]*$//'|sort -u)

for folders in $DIRECTORIES_WITH_CHANGES; do
    echo "building directory $folders"
    kustomize build $folders
    echo "------------------------"

    read -p "Do you want to continue with the apply? Type in (yes/no) " answer
    if [ "$answer" == "yes" ]; then
        kustomize build $folders|kubectl apply -f -
    else
        echo "Skipping kubectl apply"
    fi
done