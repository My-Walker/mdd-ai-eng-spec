# scripts

本目录是维护脚本。只有 `install-anchors.js` 随 npm 包发布，其余脚本和本说明留在 Git 仓库。

命令都在仓库根目录执行。

## install-anchors.js

在项目最外层写入或刷新锚点，让 Agent 加载规范总纲。锚点只包含加载指令，不复制规范正文。

- 包位于 `node_modules` 时，写到执行 `npm install` 的业务项目根目录。路径指向 `node_modules/@mdd-ai-eng/specs/ai-engineering-specs/AGENTS.md`。
- 在本仓库直接运行时，写到仓库根目录。路径是 `./ai-engineering-specs/AGENTS.md`。
- `.cursor/rules/mdd-ai-eng.mdc` 每次按当前路径整份覆盖。内容未变则跳过。
- `.kilocoderrules` 只替换 `<!-- mdd-ai-eng:start -->` 与 `<!-- mdd-ai-eng:end -->` 之间的内容。没有标记时插在文件最前面。标记外的项目说明保持不动。

```bash
node scripts/install-anchors.js
```

业务项目安装本包时，`package.json` 的 `postinstall` 会执行它。若环境关闭了安装脚本，在业务项目根目录执行 `npx mdd-ai-eng`。

## check-system.sh

检查 `ai-engineering-specs` 的三个索引是否都能找到所声明的文件。它不检查 Agent 是否遵守规范。

```bash
npm run check
```

索引中的 `path` 指向的文件不存在时，命令失败。

## run-evals.py

读取 `evals/responses/<用例id>.txt` 中的真实 Agent 回复，按 `evals/test-suite.json` 判断是否符合规范。它不调用模型，也不生成回复。

采样和文件名规则见 `evals/README.md`。

```bash
python scripts/run-evals.py
```

缺少回复文件，或回复不满足断言时，命令失败。

## release.sh

按 R1 准备正式发布：在 `dev` 上升版本并提交 → `npm test` / `npm run check` → 推 `dev` → 合并并推 `main` → 打 `vX.Y.Z` tag。  
**不执行** `npm publish`；结束后停在 `main`，打印手动发布命令（支持浏览器 2FA，命令中不含 `--otp`）。

版本号每次用参数传入，不必改脚本：

```bash
# 手动指定完整版本号（推荐）。例：写成 1.2.0，即发布为 1.2.0 / tag v1.2.0
bash scripts/release.sh 1.2.0
# 等价写法（把参数传给 npm script）
npm run release -- 1.2.0

# --bump：不手写版本号，相对当前 package.json 按 SemVer 自动 +1
# （假设当前是 1.1.0）
bash scripts/release.sh --bump patch   # → 1.1.1，小修 / 文案澄清
bash scripts/release.sh --bump minor   # → 1.2.0，向后兼容的新能力
bash scripts/release.sh --bump major   # → 2.0.0，破坏性变更

# --dry-run：只打印将执行的步骤，不改文件、不提交、不推送、不打 tag
# 可与显式版本或 --bump 组合，例如：
bash scripts/release.sh --dry-run 1.2.0
bash scripts/release.sh --dry-run --bump patch
```

必须二选一：显式版本号，或 `--bump`（二者不要同时用于定版本；`--dry-run` 可与其中之一组合）。工作区必须干净，且当前分支为 `dev`。本脚本不进入 npm 发布包。
