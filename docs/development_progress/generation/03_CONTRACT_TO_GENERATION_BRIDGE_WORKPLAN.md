# Contract To Generation Bridge Workplan

这份文档用于指导下一上下文中的 AI，在 `Phase 1-2` 已完成后，正式进入 `Phase 3`：定义 `contract => generation` 桥接阶段。

注意：

- 本文记录的是 `03.0` 阶段的 workplan 与完成结果
- `03.0` 中“聚合全部 published contracts 进入一个 generation”的方案已被后续共识修正
- 需要继续修正的内容统一放到 `03.5`

注意：

- 这一阶段仍属于“桥接定义与结构收口”，不是 generation 内部开发
- 当前目标不是实现 backend generator，也不是实现 frontend generator
- 当前必须先把错误入口收干净，再定义新的正式桥接入口

## 总目标

基于当前已确认方向与 Phase 2 审计结论，先收稳下面 4 件事：

- 把 `contract => generation` 从“模糊概念”收敛为一个独立正式步骤
- 把会误导 AI 的旧入口定位收口
- 只保留确实有价值的底层能力，并把它们重新归位到 bridge 语义
- 为后续 `runs/` 统一调整和主链验证提供唯一正式依据

## 当前已确认前提

1. `generation` 仍保留为正式阶段名称。
2. 所有 contract batches 完成并 publish 后，才允许正式进入 generation。
3. generation 第一个正式目标是“后端接口定义生成”。
4. generation 第一正式主产物默认是 `openapi.yaml`。
5. 前端生成必须消费：
   - published contracts
   - published backend API definition
6. 这里原先记录的是“聚合全部 published contracts 的一次 generation run”，该点已在后续共识中废止。
7. 当前 generation 正式方向以本目录文档为准。

## 这一阶段要先做的结构性收口

这是本轮起始动作，不是可选项。

### 1. 收旧文档定位

先处理会误导后续 AI 的文档入口：

- 删除或改写一切会被误读为当前正式 generation 主线的旧入口说明
- 在新的 development progress 目录下，明确唯一正式入口是当前 `generation/03_*`

目标：

- 后续 AI 即使没看到聊天，也不容易把旧骨架误当成正式流程

### 2. 收旧脚本语义

对旧实现按下面原则处理：

- 属于 published contract 底层解析/校验能力的，允许保留
- 不再保留错误 generation 入口
- 如需保留底层能力，应迁到 bridge / contract 语义下，而不是继续挂在 generation 正式流程名义下

目标：

- 仓库里的脚本命名和目录语义，不再暗示错误的正式路径

### 3. 定义新的 bridge 边界

必须明确：

- 这一步是 `contract` 收尾后的独立桥接步骤
- 不把它写成 generation 已开始内部执行
- 不再复用“单 contract kickoff 直接进入 generation”作为正式入口

至少要定义清楚：

- 进入条件
- 输入边界
- 聚合索引
- kickoff 方式
- 第一正式产物的上下游关系

### 4. 为后续步骤预留稳定入口

这一轮结束时，后续只能按下面顺序继续：

1. `03` bridge 定义完成
2. `04` 统一调整现有 `runs/` 产物
3. `05` 主链验证
4. generation 内部开发

## 本轮应完成

### Phase 3A: Structure Cleanup Decision

status: completed

目标：

- 基于审计结果，正式决定旧文档和旧脚本哪些删、哪些迁、哪些改名

应完成：

- 产出保留 / 迁移 / 删除清单
- 明确错误入口的处置方式
- 明确旧 `scripts/generation/*` 哪些不再作为正式入口保留

完成标准：

- 仓库中“当前正式路径”和“历史遗留资产”边界清楚

### Phase 3B: Bridge Definition

status: completed

目标：

- 把 `contract => generation` 作为独立步骤定稿

应完成：

- 明确该步骤在正式主链中的名称与位置
- 明确它和 `contract`、`generation` 的责任边界
- 明确桥接入口的基本责任边界
- 明确 generation 第一正式输入索引
- 明确 `openapi.yaml` 在后续链路中的角色

完成标准：

- 后续可以据此写 bridge 规则文档与开发目录

### Phase 3C: Bridge Entry Materials

status: completed

目标：

- 给下一轮实际开发准备唯一正式入口

应完成：

- 新的 bridge 文档目录入口
- 新的下一轮执行 prompt
- 明确 `runs/` 调整和主链验证下一步该依据什么

完成标准：

- 下一轮不需要再回聊天记录猜方向

本轮已落地：

- [03_STRUCTURE_CLEANUP_DECISION.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/generation/03_STRUCTURE_CLEANUP_DECISION.md)
- [03_CONTRACT_TO_GENERATION_BRIDGE_DEFINITION.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/generation/03_CONTRACT_TO_GENERATION_BRIDGE_DEFINITION.md)
- [04_RUNS_ALIGNMENT_WORKPLAN.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/generation/04_RUNS_ALIGNMENT_WORKPLAN.md)
- [04_RUNS_ALIGNMENT_PROMPT.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/generation/04_RUNS_ALIGNMENT_PROMPT.md)

后续修正入口：

- [03_5_MULTI_GENERATION_ENTRY_WORKPLAN.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/generation/03_5_MULTI_GENERATION_ENTRY_WORKPLAN.md)
- [03_5_MULTI_GENERATION_ENTRY_PROMPT.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/generation/03_5_MULTI_GENERATION_ENTRY_PROMPT.md)

## 当前边界

本轮不应直接展开：

- generation 内部真实后端实现器
- generation 内部前端代码生成器
- generation 多 batch 调度
- generation reviewer / freeze / publish 生命周期
- generation GUI 或长期执行器

## 计划更新规则

1. 如果在执行中发现旧资产比预期更重，先更新本 workplan，再继续清理或改目录。
2. 如果发现某些旧脚本只是底层能力，允许保留，但必须改语义定位，不能继续作为正式 generation 入口。
3. 如果发现新的 bridge 需要拆成多份规则文档，先补目录和 workplan，再继续写实现。
4. 在 `Phase 3` 完成前，不得进入 `Phase 4-5`。
