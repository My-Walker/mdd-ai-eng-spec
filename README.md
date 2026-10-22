# @mdd-ai-eng/specs

> **本仓库已停止作为开发入口，请归档。**  
> 源码已迁入：`https://github.com/My-Walker/ai-engineering` → `03-spec-orchestration/packages/mdd-ai-eng-spec`  
> npm 包名不变：`@mdd-ai-eng/specs`（已发布版本保留）。  
> 本地旧路径见同目录 `MOVED.md`。

用 Markdown 规范约束 AI Agent 的作业方式。业务项目安装本包后，会在项目最外层写入薄激活锚点。规范正文留在依赖包内，安装哪个包版本，Agent 就读哪一包正文。

包标识是 `mdd-ai-eng`，避免和其他规范包的锚点文件、标记块重名。

## 作用

Agent 每次任务先读总纲，再按索引只加载命中的规则、流程或技能；并探测业务仓库 `ai-engineering-overlay/`（若存在则按总纲协议加载加严条款）。总纲里的**不可覆盖门禁**不能被具体流程放行：

- 会影响行为的细节未确定时，列出可选项和推荐项，确认后再实现。
- 修复缺陷前必须有复现结果或日志。无法自行复现时，先加日志，由人工复现并回传，再分析后修复。
- 任务对不上任何索引时，先问任务类型（总纲任务类型菜单），不默认套用最相近流程。

另外，缺陷流程（`bugfix`）在原因确认后要求先选定「最小修复 / 长期维护修复」再改代码；大范围长期维护修复还须走实现 Plan 共用机制。这是 workflow 阶段门禁，详见包内 `workflows/bugfix.md`。

## 安装

```bash
npm install @mdd-ai-eng/specs
```

安装后，`postinstall` 在业务项目根目录写入：

- `.cursor/rules/mdd-ai-eng.mdc`：整份由本包生成，每次安装按当前依赖位置覆盖。
- `.kilocoderrules`：用 `<!-- mdd-ai-eng:start -->` 与 `<!-- mdd-ai-eng:end -->` 包住锚点。已有标记时只替换标记内的路径；没有标记时插在文件最前面。标记外的项目说明保持不动。

锚点只负责让 Agent 加载总纲。规范正文位于：

```text
node_modules/@mdd-ai-eng/specs/ai-engineering-specs/AGENTS.md
```

安装哪个版本，Agent 就读哪一包正文。升级依赖后再次安装，会把锚点路径刷新到新的安装位置。

若环境关闭了安装脚本，在业务项目根目录补跑：

```bash
npx mdd-ai-eng
```

## 业务覆盖层

在业务仓库根目录放置 `ai-engineering-overlay/`，只能追加更严的规则、流程和检查命令，不能削弱总纲门禁。约定布局与强制加载步骤见包内 `ai-engineering-specs/AGENTS.md` 的「业务覆盖层」一节。
