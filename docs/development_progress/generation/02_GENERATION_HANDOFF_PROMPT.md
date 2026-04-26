# Generation Handoff Prompt

注意：

- 本提示词属于较早的历史交接材料
- 其中“聚合全部 contracts 的一次 generation run”的说法已被后续共识修正
- 当前正式入口请改看 [README.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/generation/README.md) 与 `03.5` 文档

你现在接手本仓库的 `generation` 正式流程后续规划与交接阶段开发。

你的任务不是立即实现 generation 内部执行器，而是严格按照当前已确认顺序推进。

先看当前状态：

- 已完成：第 1 步，方向初稿已落文档
- 当前正在进入：第 2 步，审计现有 generation 偏差
- 尚未开始：第 3-6 步

必须按下面顺序继续：

1. 定好讨论结果为文档
2. 检查现有 generation 做了什么、偏差多大、后续怎么调整
3. 先把 `contract => generation` 阶段定下并先做规则文档与开发目录
4. 回头统一调整现有 `runs/` 产物，适配最新逻辑
5. 先把 `contract => generation` 主链测通
6. 主链测通后，才进入 generation 内部开发

开始前必须先阅读：

- [docs/development_progress/DEVELOPMENT_CONTEXT_PRINCIPLES.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/DEVELOPMENT_CONTEXT_PRINCIPLES.md)
- [docs/development_progress/PENDING_ITEMS.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/PENDING_ITEMS.md)
- [docs/development_progress/README.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/README.md)
- [docs/development_progress/generation/README.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/generation/README.md)
- [docs/development_progress/generation/01_GENERATION_DIRECTION_WORKPLAN.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/generation/01_GENERATION_DIRECTION_WORKPLAN.md)
- [docs/development_progress/generation/01_GENERATION_DIRECTION_PROMPT.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/generation/01_GENERATION_DIRECTION_PROMPT.md)
- 已删除的旧入口不再作为阅读材料

当前已确认的 generation 方向：

- `generation` 仍保留为正式阶段名称
- 所有 contract batches 完成并 publish 后，才允许正式进入 generation
- generation 首先处理“后端接口定义生成”，不是直接生成后端实现代码
- 后端第一正式主产物默认定为 `openapi.yaml`
- 前端生成必须消费：
  - published contracts
  - published backend API definition
- 这里原先记录的是“聚合全部 contracts 的一次 generation run”，该点已不再作为当前正式方向

你必须遵守以下约束：

1. 不要再按已删除的旧入口推导 generation 最终方向。
2. 现有 generation 相关资产需要先审计偏差，再决定复用或重构。
3. 第 3 步 `contract => generation` 交接定义，属于 `contract` 收尾和 `generation` 入口之间的桥接工作，不等于 generation 已开始内部开发。
4. 在 `contract => generation` 正式交接未定稿前，不要展开 generation 内部实现。
5. 在现有 `runs/` 产物未统一适配最新逻辑前，不要开始 `contract => generation` 主链验证。
6. 在 `contract => generation` 主链未测通前，不要展开 generation 内部实现。
7. 如果发现计划缺项、顺序不对、或需要新增工作，先更新 workplan，再继续开发。

本轮应该优先产出：

- 现有 generation 骨架的偏差审计
- 对现有 generation 相关资产的复用/调整判断
- `contract => generation` 正式交接定义的准备材料
- 后续 `runs/` 产物统一调整的前置判断

如果当前上下文只够做一件事，优先做：

- `Phase 2: Existing Generation Audit`

本轮不应直接展开：

- generation 内部真实后端实现器
- generation 内部前端代码生成器
- generation 多 batch 调度
- generation reviewer / freeze / publish 生命周期
- generation GUI 或长期执行器
