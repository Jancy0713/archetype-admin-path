# Existing Generation Audit

这份文档用于完成 `Phase 2: Existing Generation Audit`，明确当前仓库里的 generation 相关资产到底已经做到了哪里、和最新正式方向偏差多大、后续应如何复用或调整。

注意：

- 这里审计的是“现有骨架”，不是继续推进 generation 内部实现
- 本文输出的重点是复用判断、边界调整和后续桥接准备材料

## 审计范围

本轮重点核对了下面几类资产：

- `scripts/generation/manifest_utils.rb`
- `scripts/generation/consume_manifest.rb`
- `scripts/generation/bootstrap_run.rb`
- `scripts/generation/emit_consumer_outputs.rb`
- `scripts/generation/*smoke*.rb`
- `scripts/contract/generation_input.rb`
- `scripts/contract/generation_materials.rb`
- `scripts/contract/generation_kickoff.rb`
- `scripts/contract/contract_to_generation_smoke.rb`
- `contracts/*/current/generation_manifest.yaml`
- `docs/contract/examples/1.0/mainline-path-run/generation/`
- `docs/contract/examples/1.0/mainline-path-run/generation-run/`

## 审计结论

一句话结论：

当前仓库里存在的不是 generation 正式主流程，而是一套围绕单 contract 输入边界形成的下游消费骨架。

它已经解决的问题：

- 已把 `contracts/<contract_id>/current/` 作为正式发布态入口固定下来
- 已把 contract 发布态与 generation run 过程态分开
- 已有 `generation_manifest.yaml -> generation run -> output/handoff` 的最小可回放链路
- 已有按 manifest、bootstrap、output/handoff 分层的 smoke 骨架

它还没有解决的问题：

- 没有把“全部 published contracts 聚合后再进入 generation”定义清楚
- 没有 generation 级正式输入索引或聚合 kickoff
- 没有 backend API definition 阶段，更没有 `openapi.yaml`
- 没有“published backend API definition -> frontend generation”这段正式依赖关系
- 没有满足“所有 contract batches 全部 publish 完成后才允许进入 generation”的总门禁

## 与新方向的主要偏差

### 1. 入口粒度不对

当前 generation 入口全部围绕单个 `contract_id`：

- `scripts/contract/generation_kickoff.rb`
- `scripts/contract/generation_materials.rb`
- `scripts/generation/consume_manifest.rb --contract-id <contract_id>`
- `scripts/generation/bootstrap_run.rb --contract-id <contract_id>`

这和当前已确认方向冲突，因为最新要求是：

- generation 初期按“聚合全部 published contracts 的一次 run”推进
- 不是按单 contract 分别启动 generation

### 2. 进入条件不对

当前脚本只要求“某一个 published contract 存在且合法”即可继续。

例如：

- `scripts/contract/generation_kickoff.rb` 直接按单个 `contract_id` 启动
- `scripts/contract/contract_to_generation_smoke.rb` 只验证 `batch-foundation-access` 这一条单 contract 路径

但最新门禁要求是：

- 所有 contract batches 完成并 publish 后，才允许正式进入 generation

也就是说，当前骨架缺少 generation 级总门禁检查。

### 3. 正式输入模型不对

当前 `generation_manifest.yaml` 是每个 published contract 自带一份单体 consumer manifest，字段中心也是：

- `contract_id`
- `batch_id`
- `published_contract_dir`
- 单 contract 的 `materials`

这对“单 contract 消费”是够的，但对“聚合全部 contracts 后进入 backend API definition generation”是不够的。

当前缺的不是再多一个 per-contract manifest，而是 generation 级聚合输入定义，例如：

- 本次 generation 应纳入哪些 published contracts
- contract 之间的依赖与读取顺序
- generation 总入口选择键
- backend API definition 阶段的 truth-source 组合规则

### 4. 输出目标不对

当前 generation run 输出的是：

- `generation-consumption-summary.yaml`
- `generation-output-manifest.yaml`
- `generation-consumer-handoff.md`

这些产物的角色本质上是：

- 证明“我消费了什么”
- 证明“我落了一个 run 骨架”
- 告诉后续人工或脚本从哪里继续

这和最新正式目标之间还差一层关键桥接：

- generation 第一正式主产物应是 `openapi.yaml`

因此，现有 output/handoff 不能被当成 generation 第一正式真相源，只能算 bootstrap 阶段过程产物。

### 5. 文档定位偏前

### 6. 错误入口不在当前关键路径上

任何把 generation 直接写成单一旧入口的旧叙事，都不在当前关键路径上。

## 复用 / 调整 / 降级判断

### 可直接复用

- `scripts/contract/published_contract.rb`
  - 单个 published contract 的解析、校验和正式入口边界仍然有价值
- `scripts/contract/generation_input.rb`
  - 可继续作为“单 contract 正式输入边界”底层能力存在
- `scripts/contract/generation_materials.rb`
  - 可继续作为“单 contract materials 提取器”底层能力存在
- `scripts/generation/manifest_utils.rb` 里的目录初始化与 YAML 校验模式
  - 其中“run 内过程态与 published 输入分离”的思路应保留
- `scripts/generation/*smoke*.rb` 的分层回归结构
  - 分层思想可保留，但断言目标需要在 Phase 3-5 重写
- `docs/contract/examples/1.0/mainline-path-run/` 里的 published contract 样例
  - 仍可作为单 contract 已发布态样例素材复用

### 需要改名或改边界

- `scripts/contract/generation_kickoff.rb`
- `scripts/generation/consume_manifest.rb`
- `scripts/generation/bootstrap_run.rb`
- `scripts/generation/emit_consumer_outputs.rb`
- `docs/contract/examples/1.0/mainline-path-run/generation/`
- `docs/contract/examples/1.0/mainline-path-run/generation-run/`

这些资产不必立即删除，但后续必须改成下面两类中的一种：

- 改写为当前正式语义或从正式入口移除
- 被重构为新的 `contract => generation` 聚合桥接资产

当前不能继续把它们当作 generation 正式 workflow 继续扩写。

### 需要降级为历史实现记录

这类旧叙事不再进入当前正式判断。

## runs 产物统一调整的前置判断

当前仓库状态说明，主链还不具备进入 generation 的条件：

1. `contracts/` 下当前只有：
   - `batch-account-access`
   - `batch-capability-components`
2. 还没有 `contracts/batch-foundation-access/current/`
3. `runs/2026-04-24-contract-foundation-access/contract/contract-progress.md` 仍显示：
   - `current_batch_id: batch-account-access`
   - `overall_status: doing`
4. `runs/` 下没有真实的 generation 运行目录；现有 generation run 只存在于样例目录 `docs/contract/examples/1.0/mainline-path-run/generation-run/`

因此，进入 Phase 4 前至少要先回答下面几个问题：

- 哪些 run 文档需要改写成当前正式 generation 入口
- 哪些样例需要保留为历史 consumer/bootstrap 样例，哪些需要升级为新桥接样例
- 现有 smoke 使用的样例目录是否要拆成：
  - 不再作为正式入口的旧样例
  - 新的 contract => generation 聚合桥接样例

## 对 Phase 3 的准备材料

基于本轮审计，下一阶段至少要先定义清楚下面几件事：

1. generation 正式进入条件
   - 如何判断“全部 contract batches 已 publish”
2. generation 聚合输入索引
   - 是否需要新的 generation-level kickoff / manifest / index
3. generation 第一正式产物边界
   - backend API definition 阶段到底输出哪些真相源
   - `openapi.yaml` 放在哪里，谁负责写出
4. frontend generation 的依赖关系
   - 如何显式依赖 published contracts 与 published backend API definition
5. 旧 consumer/bootstrap 资产的保留方式
   - 是归档为 legacy 样例，还是改造成桥接层底座

## 本轮结论

当前 Phase 2 可以视为完成，因为已经明确：

- 现有 generation 相关资产与当前正式方向并不一致
- 它与最新正式方向的主要偏差在哪里
- 05/06/07 各自还能复用什么、应该怎么调整、哪些要先降级
- Phase 3 应先定义什么，Phase 4 前要先做哪些 runs 判断

下一步不应继续补 generation 内部执行器，而应进入 `contract => generation` 正式交接定义。
