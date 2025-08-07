#!/bin/bash

# compile this project via pdflatex
output_dir="build"
file_name="XiyuanYang-Resume"

pdflatex -output-directory=$output_dir -jobname="$file_name" "tex/main.tex"