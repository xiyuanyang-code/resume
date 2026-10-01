#!/bin/bash
#
# 编译简历 PDF
#
# 用法：
#   ./recompile.sh en     # 英文版：tex/main.tex -> cv/cv_en.pdf（并同步 cv/XiyuanYang-Resume.pdf）
#   ./recompile.sh zh     # 中文版：tex/zh.tex   -> cv/cv_zh.pdf
#   ./recompile.sh all    # 两个都编
#   ./recompile.sh        # 不传参数 = en
#
# 与 compile.sh / run.sh 的区别：不会 git add / commit / push / 打 tag
# 注意：本脚本为 macOS 专用（用到 stat -f、md5 -q、/Library/TeX/texbin）

set -euo pipefail
cd "$(dirname "$0")"

OUT_DIR="cv"
MAX_PASSES=4

TARGET="${1:-en}"
case "$TARGET" in
  en|zh|all) ;;
  *) echo "用法: $0 [en|zh|all]（默认 en）" >&2; exit 2 ;;
esac

# ---------- 1. 准备 TeX 工具链 ----------
# BasicTeX / MacTeX 装完不会自动进非登录 shell 的 PATH
if [ -d /Library/TeX/texbin ]; then
  case ":$PATH:" in
    *":/Library/TeX/texbin:"*) ;;
    *) export PATH="/Library/TeX/texbin:$PATH" ;;
  esac
fi

mkdir -p "$OUT_DIR"

# ---------- 2. 编译单个目标 ----------
# build <引擎> <jobname> <源文件> [同步目标名]
build() {
  local engine="$1" job="$2" src="$3" sync="${4:-}"
  local pdf="$OUT_DIR/$job.pdf" log pass prev cur pages overfull unchanged=""

  if [ ! -f "$src" ]; then
    echo "ERROR: 找不到 $src" >&2
    return 1
  fi
  if ! command -v "$engine" >/dev/null 2>&1; then
    echo "ERROR: 找不到 $engine（通常装在 /Library/TeX/texbin）" >&2
    return 1
  fi

  # PDF 每次编译都带新时间戳，没法比字节，只能比 mtime
  if [ -f "$pdf" ] && [ "$(stat -f %m "$src")" -le "$(stat -f %m "$pdf")" ]; then
    unchanged=1
  fi

  log="$(mktemp -t "${job}_compile")"
  rm -f "$OUT_DIR/$job.aux" "$OUT_DIR/$job.out"

  prev=""
  for pass in $(seq 1 "$MAX_PASSES"); do
    echo "[$job] pass $pass/$MAX_PASSES: $engine $src"

    if ! "$engine" -interaction=nonstopmode -halt-on-error \
          -output-directory="$OUT_DIR" -jobname="$job" "$src" > "$log" 2>&1; then
      echo "" >&2
      echo "ERROR: $job 编译失败（第 $pass 趟），日志：$log" >&2
      grep -nE '^! |^!pdfTeX error|^! Font' "$log" | head -20 >&2 || true
      return 1
    fi

    # .aux / .out 不再变化，说明交叉引用与书签已经收敛
    cur="$(md5 -q "$OUT_DIR/$job.aux" 2>/dev/null || echo x)$(md5 -q "$OUT_DIR/$job.out" 2>/dev/null || echo x)"
    if [ -n "$prev" ] && [ "$cur" = "$prev" ]; then
      break
    fi
    prev="$cur"
  done

  if [ ! -f "$pdf" ]; then
    echo "ERROR: 没有生成 $pdf，日志：$log" >&2
    return 1
  fi

  if grep -qE '^! ' "$log"; then
    echo "WARNING: $job 日志里仍有错误："
    grep -nE '^! ' "$log" | head -10 || true
  fi

  if command -v pdfinfo >/dev/null 2>&1; then
    pages="$(pdfinfo "$pdf" 2>/dev/null | awk '/^Pages:/{print $2}' || echo '?')"
  else
    pages="$(grep -oE '\([0-9]+ pages' "$log" | grep -oE '^[0-9]+' || echo '?')"
  fi
  [ -n "$pages" ] || pages='?'
  overfull="$(grep -c 'Overfull' "$log" || true)"

  find "$OUT_DIR" -type f \
    \( -name "$job.aux" -o -name "$job.log" -o -name "$job.out" -o -name "$job.toc" \) -delete

  echo "OK: $pdf  ($pages 页, $(du -h "$pdf" | cut -f1 | tr -d ' '), Overfull: $overfull)"
  if [ -n "$unchanged" ]; then
    echo "NOTE: $src 自上次编译后没有改动过，本次产物应与上一版内容相同"
  fi

  if [ -n "$sync" ]; then
    cp "$pdf" "$OUT_DIR/$sync"
    echo "OK: $OUT_DIR/$sync 已同步"
  fi
}

# ---------- 3. 按参数分发 ----------
case "$TARGET" in
  en)
    build pdflatex cv_en tex/main.tex XiyuanYang-Resume.pdf
    ;;
  zh)
    build xelatex cv_zh tex/zh.tex
    ;;
  all)
    build pdflatex cv_en tex/main.tex XiyuanYang-Resume.pdf
    build xelatex cv_zh tex/zh.tex
    ;;
esac
