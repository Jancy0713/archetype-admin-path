# Final PRD

## Meta

- Title: 素材库管理后台 final_prd
- Flow Id: prd
- Step Id: prd-04
- Artifact Id: prd-04.final_prd
- Source Paths:
  - prd-02.clarification.yaml
  - prd-03.execution_plan.yaml
- Owner: codex
- Updated At: 2026-04-21T11:15:00Z
## Overview

- Product Summary: 面向内部团队的素材库管理后台，支持素材维护、状态流转和按标签搜索。
- Current Goal:
  - 完成后台最小可用闭环。
- Success Criteria:
  - 管理员可创建、编辑、发布、归档并恢复素材。
  - 运营可按标签和状态搜索素材。
- Collaboration Mode: 先完成最小 contract 输入，再补充后续增强项。
## Scope

- Modules In Scope:
  - 素材列表
  - 素材编辑
  - 标签管理
- Modules Out Of Scope:
  - 外部分享
  - 审批流
  - 多语言
- Rollout Boundary:
  - 只覆盖后台 Web 端。
  - 只做平铺标签，不做层级标签。
## Roles

### 管理员
- Client: admin-web
- Main Goal: 维护素材与标签
- Visible Scope:
  - 素材列表
  - 素材编辑页
  - 标签管理页
- Permission Notes:
  - 允许创建、编辑、发布、归档、恢复素材

### 运营
- Client: admin-web
- Main Goal: 搜索和查看素材
- Visible Scope:
  - 素材列表
- Permission Notes:
  - 允许按标签和状态搜索
  - 不允许修改素材
## Tenant Boundary

- 当前按单租户后台处理，不引入跨租户权限模型。
## Resources

### 素材
- Resource Type: content_asset
- Purpose: 后台管理的核心条目
- Owner: 管理员
- Key Attributes:
  - 标题
  - 描述
  - 标签集合
  - 状态
- Known States:
  - draft
  - published
  - archived

### 标签
- Resource Type: asset_tag
- Purpose: 支撑分类和搜索
- Owner: 管理员
- Key Attributes:
  - 名称
  - 唯一标识
- Known States:
  - active
## Experience Modules

### 素材列表
- Objective: 让运营和管理员快速搜索、查看并进入编辑。
- In Scope Pages:
  - 素材列表页
- Key Actions:
  - 按标签搜索
  - 按状态筛选
  - 进入编辑
  - 恢复已归档素材

### 素材编辑
- Objective: 让管理员完成创建、编辑、发布和归档。
- In Scope Pages:
  - 素材编辑页
- Key Actions:
  - 新建素材
  - 保存草稿
  - 发布素材
  - 归档素材

### 标签管理
- Objective: 让管理员维护平铺标签集合。
- In Scope Pages:
  - 标签管理页
- Key Actions:
  - 新增标签
  - 编辑标签
  - 删除未使用标签
## Experience Pages

### 素材列表页
- Client: admin-web
- Module: 素材列表
- Page Type: list
- Goal: 搜索、筛选并查看素材
- Primary Actions:
  - 搜索素材
  - 状态筛选
  - 查看详情

### 素材编辑页
- Client: admin-web
- Module: 素材编辑
- Page Type: form
- Goal: 维护素材详情和状态
- Primary Actions:
  - 创建
  - 编辑
  - 发布
  - 归档

### 标签管理页
- Client: admin-web
- Module: 标签管理
- Page Type: management
- Goal: 维护平铺标签
- Primary Actions:
  - 新增标签
  - 修改标签
## Flows

### 创建并发布素材
- Trigger: 管理员新建素材
- Start: 素材列表页
- End: 素材状态为 published
- Is Async: false
- Key Steps:
  - 进入素材编辑页
  - 填写素材信息并保存草稿
  - 确认后发布

### 归档并恢复素材
- Trigger: 管理员在列表或编辑页发起归档
- Start: 素材列表页
- End: 素材状态为 archived 或 draft
- Is Async: false
- Key Steps:
  - 归档素材
  - 在归档状态下查看素材
  - 必要时恢复到草稿

### 按标签搜索素材
- Trigger: 运营输入标签或切换状态筛选
- Start: 素材列表页
- End: 返回符合条件的素材集合
- Is Async: false
- Key Steps:
  - 输入关键词或选择标签
  - 选择状态
  - 查看搜索结果
## States

### 素材
- Current States:
  - draft
  - published
  - archived

### 标签
- Current States:
  - active
## Constraints

- Non Functional:
  - 优先保证后台可维护性和状态一致性。
- External Dependencies:
  - 无额外外部分享系统接入。
- Contract Constraints:
  - contract 必须显式表达素材状态机和恢复规则。
  - contract 必须覆盖列表搜索参数和标签约束。
## Blocking Questions

- None
## Contract Execution

- Recommended Batch Order:
  - batch-01-core-model
  - batch-02-admin-pages
  - batch-03-tags
- Parallel Batches:
  - batch-02-admin-pages 与 batch-03-tags 只能在 batch-01-core-model 完成后并行进入 contract。
- Selection Guidance:
  - contract 必须一次只消费一个 ready batch，不允许把整份 final_prd 作为单一超大输入。
  - 当共享资源或状态机发生变化时，应优先回到 batch-01-core-model 重新收敛。
## PRD Batches

### 核心资源与状态机
- Batch Id: batch-01-core-model
- Goal: 先固定素材、标签和状态机，给后续页面 batch 提供稳定基础。
- Summary:
  - 这一批只覆盖资源边界、状态定义和恢复规则。
  - 列表搜索、编辑页面和标签维护都依赖这一批的对象约束。
- Grouped Modules:
  - 素材资源与状态机
  - 标签资源模型
- Grouping Reason:
  - 素材与标签是共享对象，必须先定。
  - 状态机一旦漂移，会同时带偏列表、编辑和恢复动作。
- In Scope Pages:
  - 无独立业务页面，主要服务于共享 contract 视图
- Key Resources:
  - 素材
  - 标签
- Key Flows:
  - 归档并恢复素材
- Size Control:
  - Target Contract Size: 控制在共享对象、状态和动作约束这一层，不展开完整页面交互。
  - Keep Together:
    - 素材状态机
    - 标签资源定义
  - Split Triggers:
    - 如果开始写列表交互细节，应拆去 batch-02-admin-pages。
- Contract Constraints:
  - 必须显式表达 draft/published/archived 三态与恢复规则。

### 列表与编辑闭环
- Batch Id: batch-02-admin-pages
- Goal: 在共享对象已稳定的前提下收敛列表搜索、编辑、发布和恢复动作。
- Summary:
  - 这一批承载运营和管理员最常用的页面闭环。
  - 它依赖 batch-01 的状态机和资源定义。
- Grouped Modules:
  - 素材列表
  - 素材编辑
- Dependency Batches:
  - batch-01-core-model
- Grouping Reason:
  - 列表筛选、编辑表单和状态流转动作高度耦合。
  - 如果拆散，contract 很容易在状态和页面动作上漂移。
- In Scope Pages:
  - 素材列表页
  - 素材编辑页
- Key Resources:
  - 素材
- Key Flows:
  - 创建并发布素材
  - 按标签搜索素材
  - 归档并恢复素材
- Size Control:
  - Target Contract Size: 控制在列表查询、详情编辑和状态动作闭环，不吸收标签维护细节。
  - Keep Together:
    - 列表筛选参数
    - 编辑页动作
    - 恢复入口
  - Split Triggers:
    - 如果开始写标签增删改规则，应拆去 batch-03-tags。
- Contract Constraints:
  - 必须覆盖列表搜索参数、状态筛选和编辑动作。

### 标签管理补充
- Batch Id: batch-03-tags
- Goal: 补齐平铺标签的维护边界，并约束对列表搜索的影响面。
- Summary:
  - 这一批只处理平铺标签维护，不回头重定义素材状态机。
- Grouped Modules:
  - 标签管理
- Dependency Batches:
  - batch-01-core-model
- Grouping Reason:
  - 标签管理有独立页面，但仍共享标签对象定义。
- In Scope Pages:
  - 标签管理页
- Key Resources:
  - 标签
- Key Flows:
  - 标签新增与编辑
- Size Control:
  - Target Contract Size: 只覆盖平铺标签维护和引用边界。
  - Keep Together:
    - 标签名称与唯一标识约束
  - Split Triggers:
    - 如果开始写层级标签，应视为新需求重开 PRD。
- Contract Constraints:
  - 只允许平铺标签，不引入层级结构。
## Batch Handoffs

### batch-01-core-model
- Contract Handoff:
  - Contract Scope:
    - 素材资源模型
    - 标签资源模型
    - 状态流转动作
  - Priority Modules:
    - 素材资源与状态机
  - Required Contract Views:
    - 素材详情视图
    - 状态流转动作视图
  - Do Not Assume:
    - 不要引入审批流状态。
    - 不要假设层级标签。
- Decision:
  - Allow Contract Design: true
  - Reason: 共享对象和状态规则已经收敛，可以先进入 contract。

### batch-02-admin-pages
- Contract Handoff:
  - Contract Scope:
    - 素材列表与搜索
    - 素材编辑与状态流转
  - Priority Modules:
    - 素材列表与搜索
    - 素材编辑
  - Required Contract Views:
    - 素材列表查询视图
    - 素材详情视图
    - 状态流转动作视图
  - Do Not Assume:
    - 不要扩展到批量归档。
    - 不要扩展到外部分享或多语言。
- Decision:
  - Allow Contract Design: true
  - Reason: 页面闭环边界已明确，且依赖的共享对象已被前序 batch 收敛。

### batch-03-tags
- Contract Handoff:
  - Contract Scope:
    - 标签管理
    - 标签资源约束
  - Priority Modules:
    - 标签管理
  - Required Contract Views:
    - 标签管理视图
  - Do Not Assume:
    - 不要引入层级标签。
    - 不要把标签管理扩展成复杂分类体系。
- Decision:
  - Allow Contract Design: true
  - Reason: 标签管理边界独立且依赖清楚，可以作为独立 batch 进入 contract。
## Decision

- Allow Contract Design: true
- Ready Batches:
  - batch-01-core-model
  - batch-02-admin-pages
  - batch-03-tags
- Reason: final_prd 已完成批次拆分，且不存在阻塞 contract 的 P0 问题，可按顺序逐批进入 contract。
