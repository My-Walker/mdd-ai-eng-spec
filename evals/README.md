# 行为评测用法

`evals/test-suite.json` 记录题目和通过条件。`evals/responses/` 存放对应的真实 Agent 回复。脚本不调用模型，也不会自己生成回复。

在本仓库根目录、已有锚点约束的前提下采样。回复要来自一次真实作答，不要为了通过检查而手写关键词。

## 步骤

1. 从 `evals/test-suite.json` 取出一条用例的 `id` 和 `prompt`。
2. 把 `prompt` 交给受本仓库锚点约束的 Agent，请它按规范完成该任务。
3. 把 Agent 的完整回复保存为 `evals/responses/<id>.txt`。文件名必须与用例 `id` 一致。
4. 在仓库根目录运行：

```bash
python scripts/run-evals.py
```

缺少任何一个回复文件，或回复不满足该用例的断言，命令以失败结束。

规范改动后，用新的 Agent 回复覆盖对应 txt，再重新运行。旧回复不能代表新规范已经生效。

## 用例与回复文件状态

| 用例 id | 断言要点 | 回复文件 |
|---------|----------|----------|
| `test_001_typescript_governance` | 使用 `unknown`、无 `any` 类型用法 | 已提供 |
| `test_002_sop_workflow` | 含「未决问题」「静态检查」 | **缺失** |
| `test_003_bugfix_human_evidence` | 含「日志」「人工」 | 已提供 |
| `test_004_bugfix_scope_choice` | 含「最小修复」「长期维护修复」 | **缺失** |
| `test_005_explore_review_readonly` | 含「不完善」「改进」（只读分析） | **缺失** |
| `test_006_route_conflict_ask` | 含「子任务」「推荐」（混合意图拆分） | **缺失** |

`evals/responses/.gitkeep` 仅用于保留空目录。断言目前以短语包含为主，属于弱护栏；新增用例优先覆盖路由、只读评审与门禁，而不是堆砌关键词。

## 采样注意

- `test_005`：应走 `explore-review`，回复中分析即可，不要在同轮直接改规范/业务代码。
- `test_006`：应体现总纲「混合意图」拆分，列出子任务顺序与推荐，等待确认。
