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
