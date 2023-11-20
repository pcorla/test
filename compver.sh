#!/bin/bash


git fetch --tags
current_version=$(git log HEAD --oneline --decorate | grep -Eo '\b[0-9]+\.[0-9]+\.[0-9]+\b' | sort -V | tail -n 1)
develop_version=$(git log origin/develop --oneline --decorate | grep -Eo '\b[0-9]+\.[0-9]+\.[0-9]+\b' | sort -V | tail -n 1)
if dpkg --compare-versions "$current_version" gt "$develop_version"; then
  echo "Version ($current_version) is greater than develop version ($develop_version)."
else
  echo "Version ($current_version) is not greater than develop version ($develop_version)."
  exit 1
fi

