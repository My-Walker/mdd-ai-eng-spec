#!/usr/bin/env bash
# 准备 npm 发布（R1）：升版本 → 检查 → 推 dev → 合 main → 打 tag。
# 不执行 npm publish；结束后停在 main，打印手动发布命令。
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PACKAGE_ROOT"

DRY_RUN=0
BUMP=""
VERSION_ARG=""

usage() {
  cat <<'EOF'
用法（在仓库根目录，且当前分支为 dev）：

  bash scripts/release.sh <版本号>
      # 手动指定完整版本，例如 1.2.0（推荐）

  bash scripts/release.sh --bump patch|minor|major
      # 相对当前 package.json 自动 +1：
      #   patch → x.y.(z+1)  小修
      #   minor → x.(y+1).0  新能力
      #   major → (x+1).0.0  破坏性变更

  bash scripts/release.sh --dry-run <版本号>
  bash scripts/release.sh --dry-run --bump patch
      # 只预览步骤，不改仓库

版本号每次用参数传入，不必改本脚本。
定版本须二选一：显式版本 或 --bump；--dry-run 可与其一组合。
脚本不会执行 npm publish。
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    --bump)
      if [[ $# -lt 2 ]]; then
        echo "[错误] --bump 需要参数 patch|minor|major" >&2
        exit 1
      fi
      BUMP="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    -*)
      echo "[错误] 未知参数: $1" >&2
      usage >&2
      exit 1
      ;;
    *)
      if [[ -n "$VERSION_ARG" ]]; then
        echo "[错误] 只能指定一个版本号" >&2
        exit 1
      fi
      VERSION_ARG="$1"
      shift
      ;;
  esac
done

if [[ -n "$VERSION_ARG" && -n "$BUMP" ]]; then
  echo "[错误] 不要同时指定版本号与 --bump" >&2
  exit 1
fi

if [[ -z "$VERSION_ARG" && -z "$BUMP" ]]; then
  echo "[错误] 必须提供版本号，或使用 --bump patch|minor|major" >&2
  usage >&2
  exit 1
fi

if [[ -n "$BUMP" && ! "$BUMP" =~ ^(patch|minor|major)$ ]]; then
  echo "[错误] --bump 只能是 patch、minor 或 major" >&2
  exit 1
fi

run() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "[dry-run] $*"
  else
    echo "[执行] $*"
    "$@"
  fi
}

CURRENT_VERSION="$(node -p "require('./package.json').version")"
echo "[信息] 当前 package.json 版本: $CURRENT_VERSION"

if [[ -n "$BUMP" ]]; then
  NEW_VERSION="$(node -e "
const [maj, min, pat] = process.argv[1].split('.').map(Number);
const bump = process.argv[2];
if ([maj, min, pat].some((n) => Number.isNaN(n))) {
  console.error('无法解析当前版本: ' + process.argv[1]);
  process.exit(1);
}
let next;
if (bump === 'major') next = [maj + 1, 0, 0];
else if (bump === 'minor') next = [maj, min + 1, 0];
else next = [maj, min, pat + 1];
process.stdout.write(next.join('.'));
" "$CURRENT_VERSION" "$BUMP")"
else
  NEW_VERSION="$VERSION_ARG"
fi

if [[ ! "$NEW_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+([.-][0-9A-Za-z.-]+)?$ ]]; then
  echo "[错误] 版本号格式无效: $NEW_VERSION" >&2
  exit 1
fi

TAG="v${NEW_VERSION}"
echo "[信息] 目标版本: $NEW_VERSION（tag: $TAG）"

BRANCH="$(git branch --show-current)"
if [[ "$BRANCH" != "dev" ]]; then
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "[dry-run][警告] 正式执行须在 dev（当前: $BRANCH）"
  else
    echo "[错误] 请在 dev 分支执行（当前: $BRANCH）" >&2
    exit 1
  fi
fi

if [[ -n "$(git status --porcelain)" ]]; then
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "[dry-run][警告] 正式执行要求工作区干净"
  else
    echo "[错误] 工作区不干净，请先提交或清理后再发布准备" >&2
    git status --short >&2
    exit 1
  fi
fi

if git rev-parse "$TAG" >/dev/null 2>&1; then
  echo "[错误] 本地已存在 tag: $TAG" >&2
  exit 1
fi

run git fetch origin

if git ls-remote --exit-code --tags origin "refs/tags/${TAG}" >/dev/null 2>&1; then
  echo "[错误] 远程已存在 tag: $TAG" >&2
  exit 1
fi

if [[ "$DRY_RUN" -eq 1 ]]; then
  echo "[dry-run] 将写入 package.json version=$NEW_VERSION"
  echo "[dry-run] git commit -m 'chore: 发布 ${NEW_VERSION}'"
  echo "[dry-run] npm test && npm run check"
  echo "[dry-run] git push origin dev"
  echo "[dry-run] git checkout main && git pull && git merge origin/dev && git push origin main"
  echo "[dry-run] git tag -a $TAG -m '$TAG' && git push origin $TAG"
  echo "[dry-run] 结束后停在 main（不自动切回 dev）"
  echo
  echo "=== 手动发布（脚本不会执行）==="
  echo "  npm publish"
  echo "发布完成后："
  echo "  npm view @mdd-ai-eng/specs version"
  echo "  git checkout dev"
  exit 0
fi

node -e "
const fs = require('fs');
const path = 'package.json';
const pkg = JSON.parse(fs.readFileSync(path, 'utf8'));
pkg.version = process.argv[1];
fs.writeFileSync(path, JSON.stringify(pkg, null, 2) + '\n');
" "$NEW_VERSION"

git add package.json
git commit -m "chore: 发布 ${NEW_VERSION}"

npm test
npm run check

git push origin HEAD

git checkout main
git pull origin main
if ! git merge origin/dev -m "merge: 合并 dev 至 main 以发布 ${NEW_VERSION}"; then
  echo "[错误] 合并 main 失败，请手动解决冲突后继续" >&2
  exit 1
fi
git push origin main

git tag -a "$TAG" -m "$TAG"
git push origin "$TAG"

echo
echo "=== 准备完成：已停在 main ==="
echo "包版本: $NEW_VERSION"
echo "Git tag: $TAG"
echo
echo "请手动发布（浏览器 2FA 按 npm 提示完成即可）："
echo "  npm publish"
echo
echo "发布完成后建议："
echo "  npm view @mdd-ai-eng/specs version"
echo "  git checkout dev"
echo
echo "说明：scoped 包若已是 public，一般无需再加 --access public。"
