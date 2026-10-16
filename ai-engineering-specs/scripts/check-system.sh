#!/usr/bin/env bash
set -e

# 获取脚本所在的实际目录，并自动切换到 ai-engineering-specs 根目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SPEC_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$SPEC_ROOT"

echo "=== 开始静态校验工程化 AI 规范系统 ==="
echo "[信息] 当前校验基准目录: $(pwd)"

# 1. 检查核心入口文件
if [ ! -f "AGENTS.md" ]; then
  echo "[错误] 缺失一级总纲 AGENTS.md (路径: $(pwd)/AGENTS.md)"
  exit 1
fi

# 2. 深度校验索引与 Frontmatter 路径有效性
python3 -c '
import os, sys, re

indexes = ["rules/index.md", "workflows/index.md", "skills/index.md"]
has_error = False

for idx in indexes:
    if not os.path.exists(idx):
        print(f"[错误] 缺失索引文件: {idx}")
        has_error = True
        continue
    
    dirname = os.path.dirname(idx)
    with open(idx, "r", encoding="utf-8") as f:
        content = f.read()
    
    # 匹配 path: "./xxx.md" 格式
    paths = re.findall(r"path:\s*[\"\x27]\.\/([^\"\x27]+)[\"\x27]", content)
    for p in paths:
        target_path = os.path.join(dirname, p)
        if not os.path.exists(target_path):
            print(f"[错误] 索引 {idx} 中声明的路径不存在: {target_path}")
            has_error = True
        else:
            print(f"[正常] 链路校验通过: {idx} -> {p}")

if has_error:
    sys.exit(1)
'

echo "=== 静态结构与 Frontmatter 校验全部通过！ ==="