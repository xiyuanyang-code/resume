#!/bin/bash

cd ../xiyuanyang-code || exit
git pull
cd - || exit

# clone and update the README.md file
cp ../xiyuanyang-code/README.md ./README.md
git add .
git commit -m "Update README"
git push