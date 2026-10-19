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

## 当前用例文件

- `evals/responses/test_001_typescript_governance.txt`
- `evals/responses/test_002_sop_workflow.txt`
- `evals/responses/test_003_bugfix_human_evidence.txt`
- `evals/responses/test_004_bugfix_scope_choice.txt`

这些 txt 尚未提供。目录中的 `.gitkeep` 只为让 Git 记住空的 `responses/`。
