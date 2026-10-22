---
category: skill-index
description: 技能与工具箱索引地图。技能是可复用专项手法，不是任务主流程入口。
---

# 技能与工具箱地图 (Skills Index)

## 边界（必读）

- **skills**：短小、可复用的专项能力（例如某类迁移检查清单、某工具调用约定），供 workflow 或用户任务在命中 triggers 时叠加加载。
- **不是 skills**：端到端 SOP（应放 `workflows/`）、跨任务硬底线（应放 `rules/`）。
- **当前状态**：预留索引，**尚未登记任何技能**。无命中时跳过本模块，不报错。
- 重构、新功能、缺陷、只读分析分别走对应 workflow，不要用空 skills 目录猜测流程。

## 登记格式（新增技能时使用）

在本文件正文（非示例）增加与 `rules/index.md` 相同结构的条目：`id`、`name`、`priority`、`triggers`、以及指向本目录下技能文件的相对路径字段。技能文件本身须带含 `id` 的 YAML Frontmatter。
