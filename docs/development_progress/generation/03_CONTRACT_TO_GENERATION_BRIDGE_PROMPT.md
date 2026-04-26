# Contract To Generation Bridge Prompt

你现在接手本仓库的 `generation` 正式流程第 3 步：`contract => generation` bridge 定义与结构收口。

注意：

- 本提示词对应的是 `03.0`
- 其中“聚合全部 contracts 进入一个 generation”的方向已被后续用户共识修正
- 新的正式修正入口请改用 `03.5`

开始前先明确：

- `Phase 1` 已完成：generation 新方向已定稿
- `Phase 2` 已完成：现有 generation 偏差审计已完成
- 当前现在要做的是 `Phase 3`
- 当前还不能做 `Phase 4-5`
- 当前绝对不能提前进入 generation 内部开发

## 这次任务的目标

你这次不是实现 generation 执行器，而是先完成两件事：

1. 结构性收口
2. `contract => generation` bridge 定义

## 开始前必须阅读

- [docs/development_progress/DEVELOPMENT_CONTEXT_PRINCIPLES.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/DEVELOPMENT_CONTEXT_PRINCIPLES.md)
- [docs/development_progress/PENDING_ITEMS.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/PENDING_ITEMS.md)
- [docs/development_progress/README.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/README.md)
- [docs/development_progress/generation/README.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/generation/README.md)
- [docs/development_progress/generation/01_GENERATION_DIRECTION_WORKPLAN.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/generation/01_GENERATION_DIRECTION_WORKPLAN.md)
- [docs/development_progress/generation/02_EXISTING_GENERATION_AUDIT.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/generation/02_EXISTING_GENERATION_AUDIT.md)
- [docs/development_progress/generation/03_CONTRACT_TO_GENERATION_BRIDGE_WORKPLAN.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/generation/03_CONTRACT_TO_GENERATION_BRIDGE_WORKPLAN.md)

如需核对历史实现，再按需阅读：

- 已删除的旧入口不再作为任何执行依据，当前只保留 `03.0` 结果文档作为阶段性记录

## 当前已确认方向

- `generation` 仍保留为正式阶段名称
- 所有 contract batches 完成并 publish 后，才允许正式进入 generation
- generation 首先处理“后端接口定义生成”，不是直接生成后端实现代码
- 后端第一正式主产物默认定为 `openapi.yaml`
- 前端生成必须消费：
  - published contracts
  - published backend API definition
- 这一版提示词里关于“聚合全部 contracts 的一次 generation run”的说法已过时，不再作为后续正式方向

## 你必须先做的事

### 1. 先做结构性收口

优先处理下面这些风险：

- 错误入口容易被误当成正式流程
- 旧 `scripts/generation/*` 的命名和入口容易让后续 AI 继续沿旧方向推进

因此，本轮开始时必须先明确：

- 哪些旧文档直接删
- 哪些旧文档改成历史定位
- 哪些旧脚本删除
- 哪些旧脚本迁移到 bridge / contract 语义下保留

如果执行中发现当前 workplan 缺了这部分内容，先更新 workplan，再继续。

### 2. 再定义 bridge 正式边界

至少要明确：

- `contract => generation` 是独立桥接步骤，不是 generation 内部开发
- 进入条件必须是全部 contract batches 已 publish
- generation 入口不再按单个 `contract_id` 直接启动
- 需要新的聚合输入索引 / kickoff 入口
- 后续 backend API definition 阶段与 `openapi.yaml` 的角色

## 本轮应该优先产出

- 结构性收口后的正式目录与入口
- 保留 / 迁移 / 删除清单
- `contract => generation` 独立桥接步骤定义
- 下一轮 `runs/` 产物统一调整的正式依据

## 本轮不应直接展开

- generation 内部真实后端实现器
- generation 内部前端代码生成器
- generation 多 batch 调度
- generation reviewer / freeze / publish 生命周期
- generation GUI 或长期执行器

## 执行顺序

1. 回看现有 workplan 与审计结论
2. 先做结构性收口，防止旧路径继续误导
3. 再写新的 bridge 规则文档与开发目录
4. 更新 progress index 与下一步入口
5. 停在 bridge 定义完成处，不要越过到 `runs/` 主链验证或 generation 内部实现

## 完成后下一轮入口

如果本轮已完成，不要继续复用本提示词直接开做 `runs/` 调整。

下一轮应改用：

- [04_RUNS_ALIGNMENT_WORKPLAN.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/generation/04_RUNS_ALIGNMENT_WORKPLAN.md)
- [04_RUNS_ALIGNMENT_PROMPT.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/generation/04_RUNS_ALIGNMENT_PROMPT.md)

如果你要继续修正 `contract => generation` 的正式方案，而不是进入 `04`，请改用：

- [03_5_MULTI_GENERATION_ENTRY_WORKPLAN.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/generation/03_5_MULTI_GENERATION_ENTRY_WORKPLAN.md)
- [03_5_MULTI_GENERATION_ENTRY_PROMPT.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/generation/03_5_MULTI_GENERATION_ENTRY_PROMPT.md)
