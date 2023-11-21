#!/bin/bash

# Funktion zur Ermittlung der nächsten Versionsnummer
function increment_version {
    current_version=$1
    part=$2

    current_version=${current_version#v}
    IFS='.' read -r -a version_parts <<< "$current_version"

    case $part in
        "major")
            ((version_parts[0]++))
            version_parts[1]=0
            version_parts[2]=0
            ;;
        "minor")
            ((version_parts[1]++))
            version_parts[2]=0
            ;;
        "patch")
            ((version_parts[2]++))
            ;;
    esac

    # Gib die neue Versionsnummer zurück
    echo "v${version_parts[0]}.${version_parts[1]}.${version_parts[2]}"
}

merged_branch=$(git log HEAD --oneline --decorate -1)
echo "$merged_branch"

# Versionsnummer aus dem letzten Tag im develop-Branch holen
last_version=$(git tag --sort=-v:refname 2>/dev/null || echo "0.0.0")

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
git tag -a -m "Automatic tagging of version $new_version" "v$new_version" develop
git push origin "v$new_version"
