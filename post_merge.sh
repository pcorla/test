#!/bin/bash

# Funktion zur Ermittlung der nächsten Versionsnummer
function increment_version {
    current_version=$1
    part=$2

    current_version=${current_version#v}

    #IFS='.' read -r major minor patch <<< "${current_version#v}"

    major=$(echo "$current_version" | cut -d'.' -f1)
    minor=$(echo "$current_version" | cut -d'.' -f2)
    patch=$(echo "$current_version" | cut -d'.' -f3)

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

    # Return new version
    echo "v${major}.${minor}.${patch}"
}

merged_branch=$(git log HEAD --oneline --decorate -1)
echo "$merged_branch"

# Versionsnummer aus dem letzten Tag im develop-Branch holen
last_version=$(git tag --sort=-v:refname 2>/dev/null || echo "0.0.0")

echo "$last_version"

# Überprüfen, ob "major", "minor" oder "patch" im Branch-Namen vorkommt
if [[ $merged_branch == *"major"* ]]; then
    new_version=$(increment_version "$last_version" "major")
elif [[ $merged_branch == *"minor"* ]]; then
    new_version=$(increment_version "$last_version" "minor")
elif [[ $merged_branch == *"patch"* ]]; then
    new_version=$(increment_version "$last_version" "patch")
else
    echo "Branch name does not contain version change info"
    exit 0
fi

# Git-Tag im develop-Branch setzen
git tag -a -m "Automatic tagging of version $new_version" "$new_version" develop
git push origin "$new_version"
