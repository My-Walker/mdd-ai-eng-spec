---
id: rule-typescript-strict
schema: strict
---
# TypeScript 严格治理规范

1. **类型严谨性**：
   - 严禁在生产代码中使用 `any`。若类型确实动态未知，必须使用 `unknown` 并配合类型守卫（Type Guard）。
   - 所有公开函数、组件 Props 及返回值必须显式声明类型。
2. **命名与结构**：
   - 对象结构和组件属性统一使用 `interface`。
   - 联合类型、交叉类型及基本类型别名统一使用 `type`。