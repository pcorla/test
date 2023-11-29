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

if [[ "${GITHUB_SERVER_URL}" == "https://github.com" ]]; then
  API_URL="https://api.github.com/repos"
else
  API_URL="${GITHUB_SERVER_URL}/api/v3"
fi

# Get the Pull Request number
PR_NUMBER=$(curl -s -H "Authorization: Bearer $GITHUB_TOKEN" \
  "${API_URL}/${GITHUB_REPOSITORY}/pulls?base=develop&state=closed" \
  | grep -m 1 -oP '"number": \K[0-9]+')

echo "PR_NUMBER: ${PR_NUMBER}"

# Get the Pull Request labels using GitHub API
LABELS=$(curl -s -H "Authorization: Bearer $GITHUB_TOKEN" \
  "${API_URL}/${GITHUB_REPOSITORY}/issues/${PR_NUMBER}/labels" \
  | grep -oP '"name": "\K[^"]+' | tr '\n' ' ')

echo "GitHub API URL: ${API_URL}/${GITHUB_REPOSITORY}"

# Print the labels
echo "Labels: $LABELS"

#merged_branch=$(git log HEAD --oneline --decorate -1)
#echo "$merged_branch"

last_version=$(git tag --sort=-v:refname 2>/dev/null || echo "0.0.0")
echo "$last_version"

if [[ $LABELS == *"major"* ]]; then
    new_version=$(increment_version "$last_version" "major")
elif [[ $LABELS == *"minor"* ]]; then
    new_version=$(increment_version "$last_version" "minor")
elif [[ $LABELS == *"patch"* ]]; then
    new_version=$(increment_version "$last_version" "patch")
else
    echo "Branch name does not contain version change info. Defaulting to increment patch version."
    new_version=$(increment_version "$last_version" "patch")
fi

git tag -a -m "Automatic tagging of version $new_version" "$new_version" develop
git push origin "$new_version"
