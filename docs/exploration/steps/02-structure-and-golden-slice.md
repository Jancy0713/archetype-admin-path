# Step 02 - 结构约束与黄金切片

## 日期

2026-04-16

## 目标

把当前讨论得到的关键结论沉淀成项目文档，明确后续探索不再围绕抽象大架构发散，而是围绕一套可复制的结构和一个黄金切片推进。

## 输入背景

在完成 Step 01 之后，当前项目已经有了一个可运行的 `Refine + Headless + shadcn/ui` 底座。

但下一步出现了两个明显风险：

1. 太早设计宏大系统，容易空转
2. 不先固定结构，AI 每次生成都会改变目录和职责边界

同时，针对 “是否建立统一 `schema.ts`” 的讨论已经有了较明确结论：

- 要统一 schema 规则
- 但不要采用一个持续膨胀的单文件

## 当前结论

本步骤确认以下结构性决定：

1. 目录结构应该尽早固定
2. schema 应按资源拆分，而不是集中到一个全局总文件
3. 仓库内要有独立于 AI 工具的项目规则文档
4. 后续不应直接进入具体业务开发，而应先继续固化完整工作流

## 核心判断

### 为什么现在不继续扩大战略

因为当前阶段最缺的不是更多概念，而是第一套能复用的标准实现。

如果没有标准实现：

- AI 每次都会重新组织代码
- 类型、页面、映射会互相污染
- 后续很难抽象成开源方法论

### 为什么不做单个 `schema.ts`

因为这类文件会随着资源增多快速膨胀，最终既不利于维护，也不利于 AI 做稳定修改。

统一约束应体现在：

- 资源目录格式一致
- schema 文件职责一致
- 变更顺序一致

而不是体现在：

- 全部资源都写进一个文件

## 产出物

本步骤新增以下文档：

- [`docs/exploration/ARCHITECTURE_RULE.md`](/Users/wangwenjie/project/archetype-admin-path/docs/exploration/ARCHITECTURE_RULE.md)
- [`docs/exploration/AI_RULE.md`](/Users/wangwenjie/project/archetype-admin-path/docs/exploration/AI_RULE.md)
- [`docs/exploration/steps/02-structure-and-golden-slice.md`](/Users/wangwenjie/project/archetype-admin-path/docs/exploration/steps/02-structure-and-golden-slice.md)

## 当前推荐目录

```txt
src/
  app/
    providers/
    router/
  shared/
    ui/
    lib/
    types/
  features/
    users/
      schema/
        entity.ts
        form.ts
        query.ts
      api/
        mapper.ts
      components/
      pages/
        list.tsx
        create.tsx
        edit.tsx
```

## 当时的下一步建议

在这次讨论时，当时建议的下一步是直接做 `users` 资源的黄金切片，目标包括：

1. 用推荐目录重构第一批文件
2. 建一个 `users` list 页面样板
3. 建立 resource、schema、mapper、page 的最小闭环
4. 跑一次真实验证

## 后续更新

在 2026-04-16 后续讨论中，当前策略又进一步收敛为：

- 暂不进入具体页面和资源开发
- 先把工作流、contract 和 script-first 原则补完整

因此，这份文档中的“黄金切片优先”结论，当前改为第二优先级。

## 验证

本步骤是文档收敛步骤，没有新增代码执行验证。

验证方式为人工确认：

- 结构结论已经被明确写入仓库
- 后续可以直接基于这些文档继续做 Step 03
