# Clarification

## Meta

- Title: 素材库管理后台 clarification
- Flow Id: prd
- Step Id: prd-02
- Artifact Id: prd-02.clarification
- Source Paths:
  - prd-01.analysis.yaml
- Owner: codex
- Updated At: 2026-04-21T10:45:00Z
## Context

- Scope Summary:
  - 本轮只做后台 Web 管理端的素材管理闭环。
  - 管理员负责创建、编辑、发布、归档；运营负责搜索与查看。
- Inherited Constraints:
  - 不做外部分享、审批流和多语言。
- Fixed Assumptions:
  - 标签本轮默认采用平铺模型。
- Excluded Topics:
  - 复杂媒体处理
  - 外部协作能力
## Confirmation Items

### 归档后的素材是否允许恢复到草稿或已发布状态？
- Item Id: prd-02-01
- Level: required
- Answer Mode: single_choice
- Recommended: restorable
- Options:
  - 允许恢复 (restorable) - 便于纠错和重新启用素材。
  - 不可恢复 (terminal) - 归档后视为终态。
- Reason: 会直接影响状态流转规则和编辑入口。
- Allow Custom Answer: false
- Default If No Answer: restorable
## Applied Defaults

### 标签模型
- Adopted Value: 平铺标签
- Rationale: 当前需求只要求按标签搜索，不需要层级分类。
- Upgrade Condition: 如果后续出现复杂分类导航需求，再升级为层级标签。
## Clarified Decisions

### 归档恢复
- Item Id: prd-02-01
- Decision: 归档素材允许恢复到草稿状态，再由管理员重新发布。
- Source: 人工确认
- Impact:
  - 状态机需要支持 archived -> draft。
  - 列表页需要提供恢复操作。

### 标签模型
- Decision: 本轮只做平铺标签，不做层级标签。
- Source: 默认采用并获认可
- Impact:
  - 标签管理只需支持简单增删改。
  - 搜索筛选按单层标签集合实现。
## Human Confirmation

- Required: true
- Confirmed: true
- Summary: 已确认归档可恢复，标签采用平铺模型。
- Confirmed By: product-owner
- Confirmed At: 2026-04-21T10:44:00Z
## Decision

- Allow Execution Plan: true
- Reason: 人工确认已完成，且所有 required 级确认项都已收口。
