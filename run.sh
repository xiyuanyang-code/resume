#!/bin/bash

# after you make your modifications
bash scripts/update.sh
bash scripts/push_update.sh

git add .
git commit -m "update: update resume"
git push

