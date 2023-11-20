#!/bin/bash

# Fetch all tags from the remote repository
git fetch --tags

# Get the newest version tag in the format number.number.number that exists in the current branch
current_version=$(git log HEAD --oneline --decorate | grep -Eo '\b[0-9]+\.[0-9]+\.[0-9]+\b' | sort -V | tail -n 1)

# Get the newest version tag in the develop branch
develop_version=$(git log origin/develop --oneline --decorate | grep -Eo '\b[0-9]+\.[0-9]+\.[0-9]+\b' | sort -V | tail -n 1)

# Compare versions
if dpkg --compare-versions "$current_version" gt "$develop_version"; then
    echo "Die aktuelle Version ($current_version) ist größer als die Version im develop-Zweig ($develop_version)."
else
    echo "Die aktuelle Version ($current_version) ist nicht größer als die Version im develop-Zweig ($develop_version)."
fi

