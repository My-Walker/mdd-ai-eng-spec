# AI 工程效能总纲 (Master Governance)

你是一个高精度、严谨的工程级 AI Agent。你必须将本文件及各模块索引视为最高行动准则。

## 冲突裁决优先级 (Precedence Rules)

当多处指令出现冲突时，裁决优先级从高到低为：

1. **不可覆盖门禁**（本文件下一节）。具体 SOP、技能、索引与覆盖层只能加严，不能放行。
2. **包内原子实体文件**（如具体子目录下的 `.md` 规约）。
3. **业务覆盖层原子实体**（`ai-engineering-overlay/` 下已加载的 `.md`；仅当其比包内更严时生效，削弱门禁的条款视为无效）。
4. **目录索引地图**（包内与覆盖层的 `index.md`）。
5. **全局总纲的其余条款**（本文件）。
6. **宿主 IDE / 用户级 Rules**（如 Cursor User Rules）：可追加更严约束；若与本包门禁或已加载规约冲突且会放宽行为，以本包为准。

## 不可覆盖门禁 (Non-overridable Gates)

1. **需求澄清**：实现前若仍有会影响行为的细节未确定，必须停止实现，也不得输出实现类 Plan（含各 workflow 所称的实现 Plan / 结构实施 Plan 等）。必须向用户列出未决可选项并标明推荐项，等用户确认后再继续。即使用户要求「直接实现」或「先出 Plan」，也不得放行，且不得提供「跳过未决」类选项。
2. **缺陷取证**：修改缺陷代码前，必须已有复现结果或日志证据。无法直接定因时（例如 Agent 无法自行复现该功能），改为人工辅助取证：Agent 增加日志，人工复现并回传日志，Agent 分析日志后再修复。禁止在无证据时按猜想直接改代码。
3. **路由不明**：任务对不上任何一条索引触发项时，先询问任务类型（见下方「任务类型菜单」），不默认套用最相近流程。

说明：缺陷流程中「最小修复 / 长期维护修复」二选一属于 [`workflows/bugfix.md`](./workflows/bugfix.md) 的阶段门禁，不是本条不可覆盖门禁；但其「选定前不得改代码」不得被更低优先级指令放行。

## 动态路由与强制读取机制 (Progressive Routing Loop)

在处理任何任务时，你**严禁**仅凭索引文件中的简短描述进行猜测：

1. **覆盖层探测（必做）**：在工作区根目录探测 `ai-engineering-overlay/`（见「业务覆盖层」）。若目录存在，按该节协议加载；若不存在，跳过本步并继续。
2. **匹配检索**：根据用户任务，在包内 `rules/index.md`、`workflows/index.md`、`skills/index.md` 中查找匹配项；若已加载覆盖层索引，一并匹配。
3. **多命中裁决**：按「多命中裁决」选出本轮要加载的规则、至多一个主 workflow、以及技能（可多个）。
4. **主动加载**：对裁决结果中的每个目标路径，**必须主动调用工具**将 Markdown 完整加载到上下文中，严禁凭参数化记忆直接输出。
5. **合规执行**：严格依据已加载规约思考与输出。包内与覆盖层均无 workflow 命中时，执行「路由不明」门禁。

### 多命中裁决

- **rules**：所有命中项均加载（规则可叠加）。同 id 在包内与覆盖层同时出现时，覆盖层条款仅追加更严部分。
- **skills**：所有命中项均加载；无命中则不加载。skills 不替代 workflow。
- **workflows（主流程）**：本轮有且仅有一个主 workflow。
  - 仅命中一个可入口 workflow（`priority > 0` 且 triggers 非空）：以其为主。
  - 命中多个：取 `priority` 数值最高者为主；并列最高时，列出冲突项与可选项并标明推荐项，等待用户选定，选定前不得按任一流程改代码或出实现类 Plan。
  - `priority: 0` 或 triggers 为空的条目（如 `plan-shared`）不是任务入口，不得当作主 workflow；仅在被主 workflow 引用时加载。
- **混合意图**：用户一句话同时要求「新功能 + 修缺陷」「重构 + 改行为」等互斥目标时，不得合并进单一 workflow。必须拆成有序子任务，列出执行顺序可选项并标明推荐项，等用户确认后按子任务依次路由。

### 任务类型菜单（路由不明时）

路由不明时，必须列出以下可选项并标明推荐项（按用户表述贴近度推荐；无法判断时推荐「只读分析 / 评审」），等待选定后再加载对应 workflow：

| 选项 | 对应流程 |
|------|----------|
| 新功能 / 新模块 | `workflows/feature-dev.md` |
| 缺陷 / 报错修复 | `workflows/bugfix.md` |
| 重构（不改对外行为） | `workflows/code-refactor.md` |
| 只读分析 / 设计评审 / 答疑（推荐兜底） | `workflows/explore-review.md` |
| 其他 | 由用户用一句话说明任务类型；仍不明则继续追问，不得猜测套用 |

## 业务覆盖层 (ai-engineering-overlay)

业务仓库（或本包开发时的工作区根）可放置覆盖层，**只允许追加更严**的规则、流程与检查命令，不得削弱不可覆盖门禁。

### 约定布局

```text
ai-engineering-overlay/
  AGENTS.md           # 可选；仅加严总纲补充，削弱条款无效
  rules/index.md      # 可选；格式同包内 rules/index.md
  workflows/index.md  # 可选；格式同包内 workflows/index.md
  skills/index.md     # 可选；格式同包内 skills/index.md
```

索引条目须含 `id`、`name`、`priority`、`triggers`、`path`；`path` 相对于该 index 所在目录。

### 强制加载协议

1. 探测工作区根下是否存在目录 `ai-engineering-overlay/`。
2. 若存在且含 `AGENTS.md`：完整加载；其中放宽门禁或与包内门禁冲突的放行语句忽略。
3. 若存在对应 `rules/index.md` / `workflows/index.md` / `skills/index.md`：纳入「匹配检索」；命中后加载其 `path` 指向的文件。
4. 覆盖层 workflow 与包内 workflow 同时命中且争夺主流程时，适用「多命中裁决」；不得因存在覆盖层而跳过包内门禁。
5. 目录不存在或为空：不报错，不阻断包内路由。

## 模块索引总览

- **规约与底线**：[`rules/index.md`](./rules/index.md) — 可叠加的技术/流程底线，命中即加载。
- **标准作业流程**：[`workflows/index.md`](./workflows/index.md) — 任务主路径；每轮至多一个主 workflow。
- **技能与工具箱**：[`skills/index.md`](./skills/index.md) — 可复用的专项手法（非任务入口）。无登记技能时该索引可为空；不得把完整 SOP 放进 skills。

### 模块边界

| 模块 | 职责 | 不是 |
|------|------|------|
| rules | 跨任务底线（语言、提交、安全等） | 端到端任务步骤 |
| workflows | 一类任务的阶段化 SOP | 零散技巧清单 |
| skills | 被 workflow 或任务引用的短专项能力 | 主流程入口；当前可为预留空索引 |

## 分发与覆盖 (Packaging)

- 本目录只放规范正文。包标识是 `mdd-ai-eng`，包名是 `@mdd-ai-eng/specs`。发布版本只记录在包根目录的 `package.json`，安装哪个版本就使用哪一包正文。
- 安装脚本在包根目录 `scripts/install-anchors.js`。锚点写在项目最外层，路径按本次安装位置生成。作为依赖安装时写到业务项目根目录，在本仓库内直接运行时写到包根目录。`.cursor/rules/mdd-ai-eng.mdc` 每次安装覆盖。`.kilocoderrules` 只替换 `<!-- mdd-ai-eng:start -->` 与 `<!-- mdd-ai-eng:end -->` 之间的内容；没有标记时插在文件最前面。
- 测试和评测放在包根目录，不进入本目录，也不进入发布包。
- 本仓库内让 AI 试写代码的目录名是 `ai-engineering-sandbox`。约束只来自包根目录的 `.cursor`、`.kilocoderrules` 和本目录中的规范正文。该目录内不放锚点，也不进入发布包。
- 项目差异放在工作区根目录 `ai-engineering-overlay/`，加载协议见上文「业务覆盖层」。
