#!/bin/bash
# !this is file is only for local settings.

cp README.md ../xiyuanyang-code/
cd ../xiyuanyang-code || exit
git add .
git commit -m "update resume"
git push
cd - || exit
