#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SPEC_ROOT="$(cd "$SCRIPT_DIR/../ai-engineering-specs" && pwd)"
cd "$SPEC_ROOT"

echo "=== 开始静态校验工程化 AI 规范系统 ==="
echo "[信息] 当前校验基准目录: $(pwd)"

if python3 -c "import sys" >/dev/null 2>&1; then
  PYTHON_BIN="python3"
elif python -c "import sys" >/dev/null 2>&1; then
  PYTHON_BIN="python"
else
  echo "[错误] 未找到可用的 Python 解释器"
  exit 1
fi

if [ ! -f "AGENTS.md" ]; then
  echo "[错误] 缺失一级总纲 AGENTS.md (路径: $(pwd)/AGENTS.md)"
  exit 1
fi

"$PYTHON_BIN" -c '
import os, sys, re

indexes = ["rules/index.md", "workflows/index.md", "skills/index.md"]
has_error = False
frontmatter_re = re.compile(r"\A---\s*\n(.*?)\n---\s*\n", re.S)
id_re = re.compile(r"(?m)^id:\s*\S+")
category_re = re.compile(r"(?m)^category:\s*\S+")

def check_frontmatter(path, require_id=False, require_category=False):
    global has_error
    with open(path, "r", encoding="utf-8") as f:
        content = f.read()
    m = frontmatter_re.match(content)
    if not m:
        print(f"[错误] 缺少 YAML Frontmatter: {path}")
        has_error = True
        return
    body = m.group(1)
    if require_id and not id_re.search(body):
        print(f"[错误] Frontmatter 缺少 id 字段: {path}")
        has_error = True
    elif require_id:
        print(f"[正常] Frontmatter id 校验通过: {path}")
    if require_category and not category_re.search(body):
        print(f"[错误] Frontmatter 缺少 category 字段: {path}")
        has_error = True
    elif require_category:
        print(f"[正常] Frontmatter category 校验通过: {path}")

for idx in indexes:
    if not os.path.exists(idx):
        print(f"[错误] 缺失索引文件: {idx}")
        has_error = True
        continue

    check_frontmatter(idx, require_category=True)

    dirname = os.path.dirname(idx)
    with open(idx, "r", encoding="utf-8") as f:
        content = f.read()

    # 忽略 Markdown 代码块内的示例 path，避免误报
    content_for_paths = re.sub(r"```.*?```", "", content, flags=re.S)
    paths = re.findall(r"path:\s*[\"\x27]\.\/([^\"\x27]+)[\"\x27]", content_for_paths)
    if idx == "skills/index.md" and not paths:
        print(f"[正常] skills 索引为空预留（无 path 条目）: {idx}")
    for p in paths:
        target_path = os.path.join(dirname, p)
        if not os.path.exists(target_path):
            print(f"[错误] 索引 {idx} 中声明的路径不存在: {target_path}")
            has_error = True
        else:
            print(f"[正常] 链路校验通过: {idx} -> {p}")
            check_frontmatter(target_path, require_id=True)

if has_error:
    sys.exit(1)
'

echo "=== 静态结构与 Frontmatter 校验全部通过！ ==="
