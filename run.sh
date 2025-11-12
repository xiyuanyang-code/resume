#!/bin/bash

# after you make your modifications
bash scripts/update.sh

git add .
git commit -m "update: update resume"
git push

