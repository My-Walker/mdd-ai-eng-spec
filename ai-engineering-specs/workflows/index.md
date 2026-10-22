---
category: workflow-index
description: 标准作业流程索引地图。
---

# 标准作业流程地图 (Workflows Index)

- id: feature-dev
  name: 新功能开发标准作业流
  priority: 90
  triggers: ["新功能", "模块编写", "需求落地", "实现功能", "新增模块"]
  path: "./feature-dev.md"

- id: bugfix
  name: 缺陷修复标准作业流
  priority: 100
  triggers: ["缺陷", "bug", "报错", "故障", "异常排查", "修复bug"]
  path: "./bugfix.md"

- id: code-refactor
  name: 重构标准作业流
  priority: 85
  triggers: ["重构", "重构优化", "拆分组件", "清理代码"]
  path: "./code-refactor.md"

- id: explore-review
  name: 只读分析与评审标准作业流
  priority: 70
  triggers: ["分析设计", "设计评审", "只读分析", "代码评审", "review", "答疑", "有什么问题", "不完善", "改进的地方"]
  path: "./explore-review.md"

- id: plan-shared
  name: 实现 Plan 共用机制（被其他 workflow 引用，非独立任务入口）
  priority: 0
  triggers: []
  path: "./plan-shared.md"
