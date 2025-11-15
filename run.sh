#!/bin/bash

# compile
make silent
make clean

if [ ! -f "./build/XiyuanYang-Resume.pdf" ]; then
  echo "ERROR: Source file ./build/XiyuanYang-Resume.pdf not found!"
  echo "Available files in build/:"
  ls -la ./build/ || true
  exit 1
fi

if cp "./build/XiyuanYang-Resume.pdf" "./build/cv_en.pdf"; then
  echo "SUCCESS: Copied XiyuanYang-Resume.pdf → cv_en.pdf"
else
  echo "ERROR: Failed to copy file (cp command failed)."
  exit 1
fi

# generate new tags
LATEST_TAG=$(git tag -l 'v*' --sort=-v:refname | head -1)
LATEST_TAG=${LATEST_TAG:-v0.0.0}
VERSION_NO_V=$(echo "$LATEST_TAG" | sed 's/^v//')
IFS='.' read -r -a VERSION_ARRAY <<< "$VERSION_NO_V"
echo "Latest Tag: $LATEST_TAG"

MAJOR=${VERSION_ARRAY[0]}
MINOR=${VERSION_ARRAY[1]}
PATCH=${VERSION_ARRAY[2]}
NEXT_PATCH=$((PATCH + 1))
NEW_TAG="v$MAJOR.$MINOR.$NEXT_PATCH"
echo "New tag: $NEW_TAG"

git add .
git commit -m "update: update resume for release $NEW_TAG"
git push

# pushing new tags
git tag "$NEW_TAG"
git push origin "$NEW_TAG"
