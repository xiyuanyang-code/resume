#!/bin/bash

rm -rf cv

# compile
make silent

# 检查英文版 PDF
if [ ! -f "./cv/cv_en.pdf" ]; then
  echo "ERROR: Source file ./cv/cv_en.pdf not found!"
  echo "Available files in cv/:"
  ls -la ./cv/ || true
  exit 1
fi

# 检查中文版 PDF
if [ ! -f "./cv/cv_zh.pdf" ]; then
  echo "ERROR: Source file ./cv/cv_zh.pdf not found!"
  echo "Available files in cv/:"
  ls -la ./cv/ || true
  exit 1
fi

# 复制英文版 PDF
if cp "./cv/cv_en.pdf" "./cv/XiyuanYang-Resume.pdf"; then
  echo "SUCCESS: Copied cv_en.pdf → XiyuanYang-Resume.pdf"
else
  echo "ERROR: Failed to copy English PDF file (cp command failed)."
  exit 1
fi
