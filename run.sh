#!/bin/bash

# after you make your modifications
bash scripts/update.sh

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


git add .
git commit -m "update: update resume"
git push

