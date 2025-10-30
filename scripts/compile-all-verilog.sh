#!/usr/bin/env bash
set -euo pipefail

# 用法:
#   compile_all_verilog.sh <root_dir> [output_vvp]
# 例如:
#   ./compile_all_verilog.sh . build.vvp

root="${1:-.}"
out="${2:-${root%/}/build.vvp}"

if [ ! -d "$root" ]; then
  echo "目录不存在: $root" >&2
  exit 1
fi

# 查找所有 .v 文件（递归），以 null 分隔以支持有空格的路径
mapfile -d '' files < <(find "$root" -type f -name "*.v" -print0)

if [ "${#files[@]}" -eq 0 ]; then
  echo "未找到 .v 文件 在: $root" >&2
  exit 1
fi

echo "Found ${#files[@]} .v files. Compiling to: $out"
iverilog -Wall -o "$out" "${files[@]}"
echo "iverilog 结束，运行 vvp $out"
vvp "$out"