# Contract To Generation Bridge Definition

这份文档用于完成 `Phase 3B`，把 `contract => generation` 明确定义成一个独立正式步骤。

注意：

- 本文对应的是 `03.0` 阶段的桥接定义结果
- 其中“聚合全部 published contracts 后进入一个 generation”的说法，已被后续用户共识修正
- 相关遗留问题统一转入 `03.5`

## 3.0 定位说明

`03.0` 已完成的部分是：

- 把 `contract => generation` 明确成独立步骤
- 明确 generation 不应从错误入口直接开始
- 补出第一批 bridge 级脚本与验证抓手

但 `03.0` 中“聚合全部 published contracts 后进入一个 generation”的方案，不再作为后续正式方向。

当前正式修正入口请转看：

- [03_5_MULTI_GENERATION_ENTRY_WORKPLAN.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/generation/03_5_MULTI_GENERATION_ENTRY_WORKPLAN.md)
- [03_5_MULTI_GENERATION_ENTRY_DEFINITION.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/generation/03_5_MULTI_GENERATION_ENTRY_DEFINITION.md)
- [03_5_MULTI_GENERATION_ENTRY_PROMPT.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/generation/03_5_MULTI_GENERATION_ENTRY_PROMPT.md)

## 正式定位

`03.0` 的正式价值仍成立：

- `contract => generation` 必须被明确成独立桥接步骤
- generation 不应绕过 published contract 边界直接从 run 过程态起步
- bridge 级脚本抓手与历史收口成果继续保留

但当前口径已经不是本文最初定义的“聚合全部 published contracts 后进入一个 generation”。

当前正式方案请以 [03_5_MULTI_GENERATION_ENTRY_DEFINITION.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/generation/03_5_MULTI_GENERATION_ENTRY_DEFINITION.md) 为准。

本文以下内容只保留为 `03.0` 阶段性结果说明，供理解历史桥接设计时参考。

### 3.0 阶段性方案摘要

`03.0` 当时定义的主链为：

```text
init -> prd -> contract -> bridge -> generation
```

其中：

- `contract` 负责把每个 ready batch 收敛为已 review、已 freeze、已 publish 的正式协议
- `bridge` 负责确认“全部 published contracts 是否已经齐备”，并把它们聚合成 generation 可启动的唯一正式输入索引
- `generation` 负责在 bridge 完成后，开始后端接口定义生成，并产出第一正式主产物 `openapi.yaml`

关键约束：

- `bridge` 不是 generation 内部开发
- `bridge` 是 `contract` 结束后的独立收口步骤
- `generation` 不得绕过 `bridge` 从单个 published contract 直接启动

## 进入条件

只有在下面条件全部满足时，才允许进入 `bridge`：

1. 当前 scope 下所有 contract batches 都已完成 `publish`
2. 不存在仍处于 review blocked、freeze pending、publish pending 的 batch
3. 当前 generation run 需要消费的 published contracts 范围已确定
4. 本轮没有跳过 batch 或只完成局部 batch 的例外说明

只要有一个 batch 未 publish，就不能正式进入 generation，也不能生成 generation 正式 kickoff。

## 输入边界

`bridge` 的输入不是单份 contract artifact，而是一组“已发布 contract 输入单元”。

每个单元的底层来源仍然是单个 published contract：

1. `generation_manifest.yaml`
2. `publish_manifest.yaml`
3. `freeze.yaml`
4. `contract-03.contract_spec.yaml`
5. `contract-04.review.yaml`
6. `rendered/*.md`

但正式 bridge 输入必须是“全部 published contracts 的聚合视图”，而不是单个 `contract_id`。

## 聚合索引

bridge 必须产出一个 generation 第一正式输入索引。

当前推荐名称：

- `generation-bridge-index.yaml`

当前最小脚本骨架：

- [scripts/contract/generation_bridge.rb](/Users/wangwenjie/project/archetype-admin-path/scripts/contract/generation_bridge.rb)
- [scripts/contract/generation_bridge_index.rb](/Users/wangwenjie/project/archetype-admin-path/scripts/contract/generation_bridge_index.rb)

它的责任不是替代 `openapi.yaml`，而是回答 generation 开始前必须先回答清楚的五个问题：

1. 本次 generation 纳入哪些 published contracts
2. 每个 contract 的正式发布入口在哪里
3. contract 之间的依赖和推荐读取顺序是什么
4. generation 第一阶段的目标是什么
5. generation 第一正式产物应落到哪里

最低应包含的字段语义：

1. `bridge_version`
2. `bridge_status`
3. `scope_id` 或等效的本次聚合范围标识
4. `published_contracts[]`
5. `input_read_order`
6. `generation_target`
7. `first_output`
8. `upstream_requirements`
9. `downstream_consumers`

## Kickoff 方式

正式 kickoff 不再允许是：

- `generation_kickoff.rb <contract_id>`
- `consume_manifest.rb --contract-id <contract_id>`

这两个旧命令已经从仓库移除，只保留为历史反例名称。

正式 kickoff 应改为：

1. 先确认全部 published contracts 已齐备
2. 生成 bridge 聚合索引
3. 再由 generation 读取 bridge 聚合索引启动

换句话说：

- 单 contract kickoff 只属于历史路径
- 新正式 kickoff 必须是聚合 kickoff

当前推荐名称：

- `generation-bridge-kickoff.yaml`

当前最小脚本骨架：

- [scripts/contract/generation_bridge_kickoff.rb](/Users/wangwenjie/project/archetype-admin-path/scripts/contract/generation_bridge_kickoff.rb)

它应显式引用：

1. `generation-bridge-index.yaml`
2. 本次纳入的 published contract 列表
3. generation 第一阶段目标
4. 第一正式主产物路径约定

## 与 generation 的责任边界

### bridge 负责

1. 做总门禁检查
2. 聚合全部 published contracts
3. 固化 generation 第一正式输入索引
4. 固化 kickoff 方式
5. 固化第一正式产物的上下游关系

### generation 负责

1. 消费 bridge 聚合索引
2. 进入“后端接口定义生成”阶段
3. 产出 `openapi.yaml`
4. 为后续前端生成提供已发布 backend API definition

### bridge 不负责

1. 真实后端代码生成
2. 真实前端代码生成
3. generation reviewer / freeze / publish 生命周期
4. generation 多 batch 调度

## `openapi.yaml` 的角色

`openapi.yaml` 不是 bridge 产物。

它是 generation 第一正式主产物，并且承担下面角色：

1. 作为“后端接口定义生成”阶段的正式真相源
2. 作为前端生成的必需上游输入之一
3. 与 published contracts 一起构成后续前端生成的正式依赖面

因此，下游依赖关系固定为：

```text
published contracts
  + published backend API definition (openapi.yaml)
  -> frontend generation
```

## 当前稳定入口

如果下一轮要继续当前正式方案，不应再把本文当成唯一入口，而应直接依据：

1. [03_5_MULTI_GENERATION_ENTRY_DEFINITION.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/generation/03_5_MULTI_GENERATION_ENTRY_DEFINITION.md)
2. [03_5_MULTI_GENERATION_ENTRY_WORKPLAN.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/generation/03_5_MULTI_GENERATION_ENTRY_WORKPLAN.md)
3. [03_5_MULTI_GENERATION_ENTRY_PROMPT.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/generation/03_5_MULTI_GENERATION_ENTRY_PROMPT.md)
4. [03_STRUCTURE_CLEANUP_DECISION.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/generation/03_STRUCTURE_CLEANUP_DECISION.md)

本文保留价值主要是：

- 说明 `03.0` 为什么要先把 bridge 单独定义出来
- 说明哪些 bridge 脚本抓手和历史收口成果仍可保留
- 作为理解旧聚合方案来源的阶段性记录

## 下一步边界

本文完成后，后续只能进入：

1. `Phase 4`：统一调整现有 `runs/` 产物，让它们符合新的 bridge 入口
2. `Phase 5`：验证 `contract => bridge => generation` 主链

在 `Phase 4-5` 完成前，不进入 generation 内部开发。

## 当前最小验证入口

- [scripts/contract/generation_bridge_smoke.rb](/Users/wangwenjie/project/archetype-admin-path/scripts/contract/generation_bridge_smoke.rb)

它当前覆盖：

1. bridge index 可在“全部 expected contracts 已 publish”时生成
2. bridge kickoff 可消费 bridge index
3. 缺少 expected published contract 时，bridge index 必须失败
