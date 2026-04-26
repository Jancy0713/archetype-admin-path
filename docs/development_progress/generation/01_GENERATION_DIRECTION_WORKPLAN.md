# Generation Direction Workplan

这份文档用于指导下一上下文中的 AI，在当前 `contract` 主链已基本稳定后，先把 `generation` 的新方向、现有偏差和后续执行顺序定清楚，而不是立即继续补 generation 内部实现。

注意：

- 当前已完成：
  - 方向初稿落文档
  - 现有 generation 偏差审计
- `contract => generation` 交接定义还没完成
- 现有 `runs/` 产物还没统一适配最新逻辑
- `contract => generation` 主链验证还没开始

因此，本 workplan 当前仍处于“方向冻结与偏差审计前置阶段”，不是 generation 已开始正式开发。

## 总目标

基于当前用户已确认的新方向，先把下面 5 件事收稳：

- 把当前关于 generation 的讨论结果固化为正式文档
- 审计现有 generation 骨架与新方向之间的偏差
- 先把 `contract => generation` 这一段正式交接流程定清楚
- 在主链验证前，先统一调整现有 `runs/` 产物口径以适配最新逻辑
- 在 generation 内部开发开始前，先把 `contract => generation` 主链测通

目标不是立刻补 generation 内部执行器，而是先把方向、边界、交接和开发顺序收紧。

## 当前已确认方向

当前 generation 正式主流程先按下面口径理解：

1. `generation` 仍保留为正式阶段名称，不再临时改名。
2. 单个 contract 完成并 publish 后，即可进入该 contract 对应的 generation 起点准备。
3. generation 首先处理的是“后端接口定义生成”，而不是直接生成后端实现代码。
4. 后端第一正式主产物默认定为 `openapi.yaml`。
5. 前端生成必须消费：
   - published contracts
   - published backend API definition
6. generation 初期默认按“一个 published contract 对应一个 generation 起点”推进，并一次性为用户准备多个可选 generation 起点。
7. generation 内部开发顺序必须晚于 `contract => generation` 主链接定稿、`runs/` 产物统一和主链测通。

## 对现有 generation 的初步判断

当前仓库里已经存在一批 generation 相关脚本与文档，但它们的重心主要是：

- `published contract` 的正式消费边界
- `generation_manifest.yaml` 消费协议
- generation run bootstrap
- generation output/handoff 骨架
- smoke 测试骨架

这些成果的价值在于：

- 已经把 `contract` 发布态与 generation run 过程态区分开
- 已经有 `contract_id -> generation manifest -> generation run` 的可追踪入口
- 已经有一批脚本和 smoke 可以复用

但当前偏差也很明确：

1. 现有 generation 更像“消费者 bootstrap 骨架”，还不是“后端 API definition -> 前端 generation”的正式主流程。
2. 当前 generation 输入默认围绕单个 `contract_id` 展开，但缺少“批量为多个 published contracts 生成正式 generation 起点”的上层入口。
3. 当前 generation 输出更偏 consumption summary / handoff，而不是后续真正要消费的 backend API definition。
4. generation 开发必须严格以当前目录中的正式文档为准。

因此，后续 generation 开发应采用：

- 能复用的复用
- 方向不对的要显式重构
- 不能因为已有脚本就默认继续沿旧设计走

## 统一原则

1. `contract => generation` 的正式交接必须先于 generation 内部实现。
2. generation 默认只消费 published inputs，不回读 contract run 过程态。
3. generation 初期优先收稳“后端接口定义”这一正式真相源，不直接跳到真实后端实现或完整前端代码矩阵。
4. 前端生成必须建立在 backend API definition 已收稳的前提上。
5. 在 generation 正式方向未定稿前，不继续扩写旧的 consumer bootstrap 体系。
6. generation 决策以当前目录为准。
7. `contract => generation` 交接定义属于 `contract` 收尾和 `generation` 入口之间的桥接工作，不等于 generation 内部开发已经开始。

## 执行顺序

当前状态总览：

- 当前阶段：Phase 2 completed, Phase 3 pending
- 最近更新：2026-04-24
- 执行备注：
  - `contract` 01-04 已基本完成主链建设
  - 当前已完成：方向初稿落文档、现有 generation 偏差审计
  - 当前未完成：`contract => generation` 交接定义、`runs/` 产物统一、主链验证
  - 当前 generation 还没有开始内部开发

### Phase 1: Direction Freeze

status: completed

目标：

- 把当前 generation 新方向固化成正式文档

应完成：

- 明确 generation 在正式主链中的位置
- 明确 generation 的两段式目标：
  - backend API definition generation
  - frontend generation
- 明确后端第一主产物为 `openapi.yaml`
- 明确 generation 初期按“一个 contract 一个 generation 起点”推进
- 明确 generation 当前不直接进入后端实现

完成标准：

- generation 新方向不再只存在于聊天记录
- 后续所有开发计划都能引用统一口径

### Phase 2: Existing Generation Audit

status: completed

目标：

- 检查现有 generation 都做了什么、偏差多大、后续怎么调整

应完成：

- 审计现有 generation 相关脚本、文档与样例的现状
- 把现有成果分成：
  - 可直接复用
  - 需要改名或改边界
  - 需要废弃或降级为历史实现
- 明确现有 generation 与新方向之间的主要偏差
- 给出“后续怎么调整”的粗方案，但暂不进入实现

完成标准：

- 对现有 generation 资产的复用策略清楚
- 后续不会因为错误入口而继续偏航

本轮结论：

- 已新增 `docs/development_progress/generation/02_EXISTING_GENERATION_AUDIT.md`
- 已明确现有 generation 相关资产的边界与问题
- 已补出 `runs/` 产物统一前需要先判断的前置条件

### Phase 3: Contract To Generation Handoff Definition

status: pending

目标：

- 先把 `contract => generation` 正式交接阶段定清楚

说明：

- 这一阶段属于 `contract` 收尾和 `generation` 入口之间的桥接定义
- 不应表述为 generation 已进入内部开发

应完成：

- 先做结构性收口，避免错误入口继续被误读为正式流程
- 明确保留 / 迁移 / 删除清单
- 明确 generation 的正式进入条件
- 明确 generation 如何批量创建多个 contract 对应的 generation 起点
- 明确 generation run 的最小输入索引与 kickoff 方式
- 明确 backend API definition 阶段应读取哪些 contract truth sources
- 先补规则文档，再补开发执行目录，不急着写 generation 内部实现

完成标准：

- `contract => generation` 的边界、输入、进入条件、第一正式产物都已明确
- 正式流程入口保持唯一
- 可以基于这套定义去做主链验证

### Phase 4: Existing Runs Alignment

status: pending

目标：

- 在主链验证前，先统一调整现有 `runs/` 产物口径以适配最新逻辑

应完成：

- 明确哪些现有 `runs/` 产物需要回补或重写
- 统一把现有 run 内的 handoff、summary、索引和说明文件更新到最新口径
- 确保这些运行态产物与最新脚本/流程定义一致
- 在这一步完成前，不启动 `contract => generation` 主链验证

完成标准：

- 现有 `runs/` 产物不再沿用旧口径
- 后续主链验证使用的 run 材料与当前正式流程一致

### Phase 5: Contract To Generation Mainline Validation

status: pending

目标：

- 在 generation 内部开发前，先把 `contract => generation` 主链测通

应完成：

- 设计主链验证方式
- 明确 smoke 或回归应覆盖到哪里
- 至少验证：
  - 已 publish contract 可批量生成 generation 起点
  - generation kickoff 可启动
  - 每个 generation 已拿到对应 contract 的正式输入索引
- 在这一步完成前，不继续做 generation 内部执行器或模板体系

完成标准：

- `contract => generation` 已具备可重复验证的主链接点
- generation 内部实现可以在稳定上游之上继续推进

## 当前边界

当前计划不要求本轮直接完成：

- generation 内部真实后端实现器
- generation 内部前端代码生成器
- generation 多 batch 编排
- generation reviewer / freeze / publish 生命周期
- generation GUI 或长期调度器

这些都应在 `contract => generation` 定义和主链验证收稳后再做。

## 计划更新规则

这是强约束，不是建议。

1. 开始执行前，必须先对照当前仓库状态检查这份计划是否仍完整。
2. 如果发现计划缺项、顺序有问题、或出现新的必要工作，必须先更新这份计划，再继续修改代码或文档。
3. 当前阶段的首要目标是“定方向和审偏差”，不是直接补 generation 实现。
4. 在 `Phase 2` 完成前，不得开始 `Phase 3-5`。
5. 在现有 `runs/` 产物未统一适配最新逻辑前，不得开始 `contract => generation` 主链验证。
6. 在 `contract => generation` 主链未测通前，不得把 generation 内部开发当成主任务。
7. 每完成一个 phase，都要更新本文件中的状态和执行日志。

## 执行日志

### 2026-04-24

- 根据用户最新共识，新建 `docs/development_progress/generation/` 目录，把 generation 与 contract 历史开发记录拆开
- 明确 generation 当前正式方向：
  - 先后端接口定义
  - 后端第一正式主产物为 `openapi.yaml`
  - 再前端生成
  - 初期按“一个 contract 一个 generation 起点”推进，并一次性为用户准备多个可选 generation
- 明确当前执行顺序：
  1. 定好讨论结果为文档
  2. 检查现有 generation 做了什么、偏差多大、后续怎么调整
  3. 先把 `contract => generation` 阶段定下并先做规则文档与开发目录
  4. 回头统一调整现有 `runs/` 产物，适配最新逻辑
  5. 先把 `contract => generation` 主链测通，再进入 generation 内部开发
- 标记 `Phase 1: Direction Freeze` 已完成
- 完成 `Phase 2: Existing Generation Audit`
  - 审计 generation 相关脚本、样例与 published contract 输入边界
  - 明确当前正式方向与后续顺序
  - 明确主要偏差：
    1. 入口仍按单个 `contract_id`
    2. 缺少“全部 contract batches 全部 publish 后再进入 generation”的总门禁
    3. 缺少 generation 级聚合输入索引
    4. 首批输出仍是 consumption summary / handoff，而不是 `openapi.yaml`
  - 明确旧 `05/06/07` 的判断：
    - `05` 高复用，适合作为 bridge 底层能力
    - `06` 中度复用，需从单 contract 输入改到聚合输入
    - `07` 暂降级为历史待议计划，不能直接进入执行
  - 明确当前 `runs/` 下没有真实 generation run；现有 generation run 只存在于样例目录
  - 明确当前还不能开始 `Phase 3` 之外的工作，更不能进入 generation 内部实现
