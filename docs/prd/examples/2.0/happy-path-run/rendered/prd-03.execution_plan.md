# Execution Plan

## Meta

- Title: 素材库管理后台 execution_plan
- Flow Id: prd
- Step Id: prd-03
- Artifact Id: prd-03.execution_plan
- Source Paths:
  - prd-02.clarification.yaml
- Owner: codex
- Updated At: 2026-04-21T11:00:00Z
## Planning Basis

- Scope Summary:
  - 先完成素材列表、编辑和标签管理的最小后台闭环。
- Confirmed Constraints:
  - 只做后台 Web 端。
  - 不做审批流和多语言。
- Contract Assumptions:
  - contract 阶段需要明确素材状态机和搜索参数。
## Delivery Strategy

- Sequencing Principles:
  - 先确定核心资源与状态，再展开页面和交互。
  - 优先支撑素材列表与编辑闭环。
- Phase Boundaries:
  - Phase 1: 资源模型和状态机
  - Phase 2: 列表与编辑页面
  - Phase 3: 标签管理和补充约束
## Workstreams

### 核心资源与状态
- Workstream Id: ws-core-model
- Objective: 明确素材、标签和状态流转边界。
- Can Run In Parallel: false
- Outputs:
  - 素材 contract 视图
  - 状态流转约束

### 后台页面闭环
- Workstream Id: ws-admin-pages
- Objective: 明确列表、编辑、归档恢复等页面能力。
- Can Run In Parallel: false
- Depends On:
  - ws-core-model
- Outputs:
  - 页面 contract 视图
  - 关键页面动作

### 标签管理
- Workstream Id: ws-tag-management
- Objective: 明确平铺标签的维护能力。
- Can Run In Parallel: true
- Depends On:
  - ws-core-model
- Outputs:
  - 标签维护 contract 视图
## Plan Steps

### 定义素材和标签核心模型
- Step Order: 1
- Goal: 固定 contract 设计的资源边界和状态约束。
- Handoff To: contract
- Inputs:
  - 已确认的 clarification
- Outputs:
  - 素材资源定义
  - 标签资源定义
  - 状态机约束

### 定义素材列表与筛选
- Step Order: 2
- Goal: 固定列表页搜索、状态筛选和恢复入口。
- Handoff To: contract
- Inputs:
  - 素材资源定义
  - 标签资源定义
- Outputs:
  - 列表 contract 视图
  - 筛选参数约束
- Dependencies:
  - 定义素材和标签核心模型

### 定义素材编辑与发布流程
- Step Order: 3
- Goal: 固定创建、编辑、发布、归档、恢复动作。
- Handoff To: contract
- Inputs:
  - 状态机约束
  - 页面动作清单
- Outputs:
  - 编辑 contract 视图
  - 状态流转动作
- Dependencies:
  - 定义素材和标签核心模型

### 定义标签管理补充能力
- Step Order: 4
- Goal: 固定平铺标签的增删改和引用边界。
- Handoff To: contract
- Inputs:
  - 标签资源定义
- Outputs:
  - 标签管理 contract 视图
- Dependencies:
  - 定义素材和标签核心模型
## Contract Priorities

### 素材资源与状态机
- Priority: P0
- Reason: 是列表、编辑、归档恢复等能力的共同前置。
- Required Inputs:
  - 归档恢复规则
  - 素材状态定义
- Not In Scope For Now:
  - 复杂审批状态

### 素材列表与搜索
- Priority: P0
- Reason: 是运营使用闭环的关键入口。
- Required Inputs:
  - 标签模型
  - 状态筛选规则
- Not In Scope For Now:
  - 高级搜索语法

### 标签管理
- Priority: P1
- Reason: 对最小闭环重要，但可在核心资源后补充。
- Required Inputs:
  - 平铺标签定义
- Not In Scope For Now:
  - 层级标签
## Batching Principles

- 先拆共享资源与状态机，再拆依赖这些约束的页面。
- 列表搜索与标签管理共享筛选对象，但编辑流和状态流转必须与资源模型保持同批或紧邻批次。
- 单个 batch 只承载一个清晰的 contract 目标，避免把整个后台一次性推进到 contract。
## Planned Batches

### 核心资源与状态机
- Batch Id: batch-01-core-model
- Goal: 固定素材、标签与状态流转的共同边界。
- Handoff To: final_prd
- Included Modules:
  - 素材资源与状态机
- Contract Views:
  - 素材 contract 视图
  - 状态流转动作视图

### 列表与编辑闭环
- Batch Id: batch-02-admin-pages
- Goal: 在共享状态机前提下收敛列表搜索、编辑与恢复动作。
- Handoff To: final_prd
- Included Modules:
  - 素材列表与搜索
  - 素材编辑
- Depends On Batches:
  - batch-01-core-model
- Contract Views:
  - 素材列表查询视图
  - 素材详情视图

### 标签管理补充
- Batch Id: batch-03-tags
- Goal: 补齐平铺标签维护与引用边界。
- Handoff To: final_prd
- Included Modules:
  - 标签管理
- Depends On Batches:
  - batch-01-core-model
- Contract Views:
  - 标签管理视图
## Batch Order

- batch-01-core-model
- batch-02-admin-pages
- batch-03-tags
## Risks And Watchpoints

- Coordination Notes:
  - 状态机和页面动作必须保持一致。
  - 标签模型升级为层级结构时需重新评估搜索 contract。
- Followup Watchpoints:
  - 如果后续新增批量归档，需要重新评估列表页批量动作与状态机约束。
## Decision

- Allow Final Prd: true
- Reason: 当前计划已明确先后顺序、依赖和 contract 优先级，可进入 final_prd。
