#!/bin/bash
#
# 一键重编英文简历：tex/main.tex -> cv/cv_en.pdf，并同步 cv/XiyuanYang-Resume.pdf
#
# 与 compile.sh / run.sh 的区别：
#   - 不重编中文版 cv_zh.pdf
#   - 不会 git add / commit / push / 打 tag
#
# 用法：./recompile.sh

set -euo pipefail
cd "$(dirname "$0")"

TEX_SRC="tex/main.tex"
OUT_DIR="cv"
JOB="cv_en"
FINAL_PDF="XiyuanYang-Resume.pdf"
MAX_PASSES=4

# ---------- 1. 准备 pdflatex ----------
if ! command -v pdflatex >/dev/null 2>&1; then
  # BasicTeX / MacTeX 装完不会自动进非登录 shell 的 PATH
  if [ -x /Library/TeX/texbin/pdflatex ]; then
    export PATH="/Library/TeX/texbin:$PATH"
  else
    echo "ERROR: 找不到 pdflatex（BasicTeX/MacTeX 一般装在 /Library/TeX/texbin）" >&2
    exit 1
  fi
fi

if [ ! -f "$TEX_SRC" ]; then
  echo "ERROR: 找不到 $TEX_SRC" >&2
  exit 1
fi

mkdir -p "$OUT_DIR"
LOG="$(mktemp -t cv_en_compile)"
PDF="$OUT_DIR/$JOB.pdf"

# 源码是否比现有产物还旧（PDF 每次编译都带新的时间戳，不能比字节）
UNCHANGED=""
if [ -f "$PDF" ] && [ "$(stat -f %m "$TEX_SRC")" -le "$(stat -f %m "$PDF")" ]; then
  UNCHANGED=1
fi

# ---------- 2. 多趟编译，直到 aux/out 稳定 ----------
rm -f "$OUT_DIR/$JOB.aux" "$OUT_DIR/$JOB.out"
prev=""
for pass in $(seq 1 "$MAX_PASSES"); do
  echo "[pass $pass/$MAX_PASSES] pdflatex $TEX_SRC"

  if ! pdflatex -interaction=nonstopmode -halt-on-error \
        -output-directory="$OUT_DIR" -jobname="$JOB" "$TEX_SRC" > "$LOG" 2>&1; then
    echo "" >&2
    echo "ERROR: 编译失败（第 $pass 趟），日志：$LOG" >&2
    grep -nE '^! |^!pdfTeX error' "$LOG" | head -20 >&2 || true
    exit 1
  fi

  # .aux / .out 不再变化，说明交叉引用与书签已经收敛
  cur="$(md5 -q "$OUT_DIR/$JOB.aux" 2>/dev/null || echo no-aux)$(md5 -q "$OUT_DIR/$JOB.out" 2>/dev/null || echo no-out)"
  if [ -n "$prev" ] && [ "$cur" = "$prev" ]; then
    break
  fi
  prev="$cur"
done

# ---------- 3. 校验产物 ----------
if [ ! -f "$PDF" ]; then
  echo "ERROR: 没有生成 $PDF，日志：$LOG" >&2
  exit 1
fi

if grep -qE '^! ' "$LOG"; then
  echo "WARNING: 日志中仍有错误："
  grep -nE '^! ' "$LOG" | head -10
fi

if command -v pdfinfo >/dev/null 2>&1; then
  PAGES="$(pdfinfo "$PDF" | awk '/^Pages:/{print $2}')"
else
  PAGES="$(grep -oE 'Output written on .*' "$LOG" | grep -oE '\([0-9]+ pages' | grep -oE '[0-9]+' || echo '?')"
fi

OVERFULL="$(grep -c 'Overfull' "$LOG" 2>/dev/null || true)"

# ---------- 4. 同步最终产物并清理 ----------
cp "$PDF" "$OUT_DIR/$FINAL_PDF"
find "$OUT_DIR" -type f \( -name "$JOB.aux" -o -name "$JOB.log" -o -name "$JOB.out" -o -name "$JOB.toc" \) -delete

echo ""
echo "OK: $PDF  ($PAGES 页, $(du -h "$PDF" | cut -f1 | tr -d ' '), Overfull: $OVERFULL)"
echo "OK: $OUT_DIR/$FINAL_PDF 已同步"
if [ -n "$UNCHANGED" ]; then
  echo "NOTE: $TEX_SRC 自上次编译后没有改动过，本次产物应与上一版内容相同"
fi
