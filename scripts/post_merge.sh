#!/bin/bash

function increment_version {
    current_version=$1
    part=$2

    IFS='.' read -r major minor patch <<< "${current_version#v}"

    case $part in
        "major")
            ((major++))
            minor=0
            patch=0
            ;;
        "minor")
            ((minor++))
            patch=0
            ;;
        "patch")
            ((patch++))
            ;;
    esac

    echo "v${major}.${minor}.${patch}"
}

git fetch --tags

merged_branch=$(git log HEAD --oneline --decorate -1)
echo "$merged_branch"

last_version=$(git tag --sort=-v:refname 2>/dev/null || echo "0.0.0")

echo "$last_version"

if [[ $merged_branch == *"major"* ]]; then
    new_version=$(increment_version "$last_version" "major")
elif [[ $merged_branch == *"minor"* ]]; then
    new_version=$(increment_version "$last_version" "minor")
elif [[ $merged_branch == *"patch"* ]]; then
    new_version=$(increment_version "$last_version" "patch")
else
    echo "Branch name does not contain version change info. Defaulting to increment patch version."
    new_version=$(increment_version "$last_version" "patch")
fi

git tag -a -m "Automatic tagging of version $new_version" "$new_version" develop
git push origin "$new_version"
