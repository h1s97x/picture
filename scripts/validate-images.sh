#!/usr/bin/env bash
#
# 图片命名规范校验脚本
#
# 作用：校验 images/ 顶层新上传图片是否符合命名规范（NORMALIZING.md 定义）。
#       _legacy/ 为只读历史归档，不参与校验。
#
# 用法：
#   scripts/validate-images.sh [--strict]        # 校验已提交到仓库的图片
#   scripts/validate-images.sh <file>...         # 校验指定图片文件（上传前自检）
#
# 退出码：0=全部通过，1=存在违规
#
# 可选 --strict：图片缺少「语义名」时判定为违规（建议最终规范开启）；
# 默认模式仅检查字符集与结构（日期等），兼容过渡期未补齐语义名的文件。

set -u

IMG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/images"
EXT_RE='\.(png|jpe?g|gif|webp|avif|bmp|svg|ico|tiff?|heic)$'

STRICT=0
FILES=()
for arg in "$@"; do
  case "$arg" in
    --strict) STRICT=1 ;;
    *) FILES+=("$arg") ;;
  esac
done

if [ "${#FILES[@]}" -eq 0 ]; then
  # 默认扫描 images/ 顶层（含子目录，但不含 _legacy）
  while IFS= read -r -d '' f; do
    FILES+=("$f")
  done < <(find "$IMG_DIR" -type f -not -path "*/_legacy/*" -print0)
fi

bad=0

for f in "${FILES[@]}"; do
  name="$(basename "$f")"

  # 1. 必须是支持的图片扩展名
  if ! echo "$name" | grep -qiE "$EXT_RE"; then
    echo "[FAIL] 扩展名不受支持: $name"
    bad=1
    continue
  fi

  # 2. 扩展名前的主文件名
  stem="${name%.*}"
  # 3. 全小写，仅允许小写字母、数字、连字符、下划线
  if ! echo "$stem" | grep -qE '^[a-z0-9_-]+$'; then
    echo "[FAIL] 文件名只能包含小写字母/数字/-/_（不允许中文、空格、大写、URL编码等）: $name"
    bad=1
    continue
  fi

  # 4. 不允许以 - 或 _ 开头/结尾（避免系统/工具自动生成名）
  if echo "$stem" | grep -qE '^[-_]|[-_]$'; then
    echo "[FAIL] 文件名不允许以 - 或 _ 开头/结尾: $name"
    bad=1
    continue
  fi

  # 5. 不允许连续分隔符
  if echo "$stem" | grep -qE '[-_]{2,}'; then
    echo "[FAIL] 文件名不允许出现连续分隔符(-- 或 __): $name"
    bad=1
    continue
  fi

  # 6. 应包含 8 位日期段 YYYYMMDD（未来规范强制，当前警告）
  if ! echo "$stem" | grep -qE '(^|[_-])[0-9]{8}([_-]|$)'; then
    if [ "$STRICT" -eq 1 ]; then
      echo "[FAIL] 缺少 8 位日期段 YYYYMMDD: $name"
      bad=1
    else
      echo "[WARN] 缺少 8 位日期段 YYYYMMDD（建议补充）: $name"
    fi
    continue
  fi

  # 7. 应包含「语义名」（非纯日期）
  sem="$(echo "$stem" | sed -E 's/(^|[_-])[0-9]{8}([_-]|$)//g; s/^[-_]+//; s/[-_]+$//')"
  if [ -z "$sem" ]; then
    if [ "$STRICT" -eq 1 ]; then
      echo "[FAIL] 缺少语义名（不能只有日期）: $name"
      bad=1
    else
      echo "[WARN] 只有日期没有语义名（建议补充）: $name"
    fi
  fi

  echo "[OK] $name"
done

if [ "$bad" -eq 0 ]; then
  echo "校验通过：所有图片符合命名规范。"
else
  echo "校验未通过：请按 NORMALIZING.md 规范重命名后重试。" >&2
fi
exit "$bad"
