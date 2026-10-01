#!/bin/bash

# 只清理英文产物以强制重编；cv/cv_zh.pdf 是本地文件（已 gitignore），不删除
rm -f cv/cv_en.pdf cv/XiyuanYang-Resume.pdf

# compile
make silent

# 检查英文版 PDF
if [ ! -f "./cv/cv_en.pdf" ]; then
  echo "ERROR: Source file ./cv/cv_en.pdf not found!"
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
