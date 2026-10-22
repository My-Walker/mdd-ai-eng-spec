# 开发本仓库

这份说明只给维护 `@mdd-ai-eng/specs` 的人。它不进入 npm 发布包。安装后的使用方式见 `README.md`。

## 发布内容

`package.json` 的 `files` 决定额外打进包里的路径。当前为：

- `README.md`
- `ai-engineering-specs/`
- `scripts/install-anchors.js`

`package.json` 本身会被 npm 一并发布。`DEVELOPMENT.md`、`test/`、`evals/`、`ai-engineering-sandbox/`、`.cursor/`、`.kilocoderrules` 不在 `files` 中，不会发布。

版本只记录在根目录 `package.json`。发布源由根目录 `.npmrc` 固定为官方源。正式发布主干为远程 `main`；日常开发在 `dev`。

## 目录

```text
package.json                  包名、版本、发布清单、安装脚本入口
README.md                     安装方说明，随包发布
DEVELOPMENT.md                本文件，不发布
scripts/                     维护脚本。作用与用法见 scripts/README.md
  install-anchors.js          写入或刷新锚点，随包发布
  check-system.sh             校验规范索引路径
  run-evals.py                检查已保存的真实 Agent 回复
  release.sh                  发布准备（升版本/合 main/打 tag，不执行 publish）
test/                         锚点安装单元测试
evals/                        行为评测。用法见 evals/README.md
  test-suite.json             题目与通过条件
  responses/                  人工保存的真实 Agent 回复，文件名为 <用例id>.txt
ai-engineering-specs/         规范正文
  AGENTS.md                   总纲：优先级、门禁、路由、overlay、发布约定
  rules/                      技术底线
  workflows/                  标准作业流程（含 explore-review、plan-shared）
  skills/                     技能（可为预留空索引）
ai-engineering-overlay/       可选；业务/本仓加严层，不进入发布包
ai-engineering-sandbox/       试写代码目录，不发布
.cursor/rules/mdd-ai-eng.mdc  本仓库的 Cursor 锚点
.kilocoderrules               本仓库的 Kilo 锚点
```

`ai-engineering-sandbox/` 只用来让 AI 试写代码，目录内不放锚点。约束来自仓库根目录的 `.cursor`、`.kilocoderrules` 和 `ai-engineering-specs/`。

## 本地命令

在仓库根目录执行：

```bash
npm test
npm run check
node scripts/install-anchors.js
python scripts/run-evals.py
npm run release -- 1.2.0
```

- `npm test`：验证锚点写入、路径刷新和标记替换。
- `npm run check`：验证三个索引里的文件路径都存在。
- `node scripts/install-anchors.js`：在本仓库最外层刷新锚点。内容未变时跳过。路径是 `./ai-engineering-specs/AGENTS.md`。
- `python scripts/run-evals.py`：按 `evals/README.md` 检查 `evals/responses/<用例id>.txt`。没有真实回复时评测失败。
- `npm run release -- <版本>`：发布准备流程，详见 `scripts/README.md`。结束后在 `main` 上手动执行 `npm publish`（浏览器 2FA），再 `git checkout dev`。

作为 npm 依赖安装时，锚点写到执行安装命令的业务项目根目录，路径指向 `node_modules` 中的总纲。
