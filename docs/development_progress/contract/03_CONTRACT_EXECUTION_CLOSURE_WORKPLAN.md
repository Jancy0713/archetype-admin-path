# Contract Execution Closure Workplan

这份文档用于指导下一上下文中的 AI，在 `02` 号 hardening 已完成后，继续推进第三阶段的执行闭环建设。

当前目标不再是补第一批 hardening，而是把已经落下的 validator、render、run integration、freeze publish bridge 和样例，进一步收紧成更稳定、可连续执行的 `contract` 工作流。

## 总目标

基于当前已完成的 `contract` hardening 结果，继续补齐执行闭环中仍然偏弱的部分：

- review 完成后的 run 收口
- batch handoff / batch index 生成
- freeze publish 后的当前版本切换纪律
- 样例与 smoke 回归覆盖面

目标是让 `contract` 从“已有最小脚本入口”进一步演进到“更容易连续跑通且不易串批次”的状态。

## 统一原则

1. 延续现有 `contract` 文档、模板、脚本和 gate 口径，不另起一套流程。
2. reviewer 仍必须由独立子 agent 或独立新上下文执行，主 agent 不得自己兼任 reviewer。
3. 正式 reviewer gate 仍只放在 `contract_spec`，除非本计划显式新增 phase 调整 gate 设计。
4. 冻结态正式主键继续统一用 `contract_id`，MVP 继续采用 `contract_id = batch_id`。
5. 所有 run 级 batch start handoff 路径统一使用 `runs/<run-id>/contract/handoffs/`。
6. 当前阶段优先补执行闭环与路径纪律，不追求一次性完成全量 schema 或多 batch 自动并行。

## 执行顺序

当前状态总览：

- 当前阶段：completed
- 最近更新：2026-04-23
- 执行备注：
  - `02` 号 hardening 已完成
  - 当前已有最小 `continue_run / finalize_step / freeze / publish / smoke_test`
  - `Phase 1 -> Phase 4` 已完成，review 收口、batch handoff 生成、publish 生命周期与样例扩展都已有最小入口
  - 当前回归仍主要依赖单条 smoke test，尚未按层拆开

### Phase 1: Review Closure Hardening

status: completed

目标：

- 把 `review_complete.rb` 从基础判定器推进成更接近 `prd` 的 run 收口入口

应完成：

- 校验 review subject 是否属于当前 batch run
- 明确 review pass / block 后的下一步输出与终端提示
- 规划或落最小 progress / state snapshot 规则

完成标准：

- review 完成后，当前 batch 的下一步动作可稳定推导
- review 结果不会轻易串到其他 run 或其他 batch

### Phase 2: Batch Handoff Generation

status: completed

目标：

- 把 `final_prd -> contract` 的 handoff/index 从文档约定推进到最小脚本化入口

应完成：

- 规划或落 `contract-batch-index.yaml` 初始化脚本
- 规划或落 `runs/<run-id>/contract/handoffs/*.contract-start.md` 生成脚本
- 统一 handoff 文案中对当前轮次、后续轮次和解锁条件的口径

完成标准：

- contract batch index 与 handoff 文件不再只靠人工手写
- run 内 batch 入口路径可稳定生成与回放

### Phase 3: Publish Lifecycle Hardening

status: completed

目标：

- 收紧 freeze publish 后的 `current / versions` 生命周期纪律

应完成：

- 明确 publish manifest 中最小必填信息
- 补 current 覆盖、版本已存在、重复发布等场景的规则
- 规划或落 publish 后的基本校验/核对脚本

完成标准：

- publish 的覆盖与版本落盘行为更可预期
- `contracts/` 中的冻结态更容易复查和复用

### Phase 4: Examples Expansion

status: completed

目标：

- 在已有最小样例基础上补一组更贴近真实 batch handoff 的链路样例

应完成：

- 补至少一条带 batch index / handoff 的 happy-path 样例
- 补至少一条 publish lifecycle 失败样例
- 让 README 明确每条样例在测什么

完成标准：

- 样例不只覆盖单点 validator，还覆盖 run / handoff / publish 关键环节
- 后续修改时更容易定位回归范围

### Phase 5: Regression Layering

status: completed

目标：

- 把当前单条 smoke test 扩展成更清晰的分层回归抓手

应完成：

- 区分 validator smoke、run smoke、publish smoke
- 让失败输出更容易定位是哪一层坏了
- 文档化推荐执行顺序

完成标准：

- 回归不再只有单条大脚本
- 后续迭代能更快发现是 schema、run 还是 publish 层回归

## 计划更新规则

这是强约束，不是建议。

1. 开始执行前，必须先对照当前仓库状态检查这份计划是否仍完整。
2. 如果发现计划缺项、顺序有问题、或出现新的必要工作，必须先更新这份计划，再继续修改代码或文档。
3. 每完成一个 phase，都要更新本文件中的最新状态。
4. 每完成一个 phase，都要向用户同步：
   - 当前计划做到哪里了
   - 这一阶段具体完成了什么
   - 下一阶段准备做什么
5. 如果执行中发现文档口径冲突，先修计划或文档冲突，再继续实现。

## 当前边界

当前计划不要求本轮直接完成：

- 全量 schema 级 validator
- 多 batch 并行调度自动化
- 完整进度板系统接入
- 完整版本升级/迁移机制

这些应在执行闭环主链稳定后继续推进。

## 执行日志

### 2026-04-23

- 更新 `DEVELOPMENT_CONTEXT_PRINCIPLES.md`，补入第三阶段 execution closure 与分层回归原则
- 更新 `PENDING_ITEMS.md`，把进度板系统与多 batch 并行调度继续留在后续轮次
- 完成 `Phase 1: Review Closure Hardening`
  - 更新 `scripts/contract/review_complete.rb`
  - 更新 `scripts/contract/workflow_manifest.rb`
  - 增加 `state/contract-04.review-result.yaml` 的最小 run 收口快照
  - 收紧 review path / subject path 与当前 batch run 的一致性校验
- 完成 `Phase 2: Batch Handoff Generation`
  - 新增 `scripts/contract/generate_batch_handoffs.rb`
  - 可从 `final_prd` 生成 `contract-batch-index.yaml`、`contract-handoff.md` 与 `handoffs/*.contract-start.md`
  - 实测兼容现有 `prd` happy-path `final_prd` 样例中的 `recommended_batch_order / prd_batches / decision.ready_batches`
- 完成 `Phase 3: Publish Lifecycle Hardening`
  - 更新 `scripts/contract/publish_freeze.rb`
  - 新增 `scripts/contract/verify_published_contract.rb`
  - 收紧 `current / versions` 覆盖规则，并补充 publish manifest 最小字段
  - 实测通过 publish + verify 的最小链路
- 完成 `Phase 4: Examples Expansion`
  - 补充 `docs/contract/examples/1.0/handoff-path-run/` 多 batch handoff 样例
  - 更新 `docs/contract/examples/1.0/README.md`，明确各组样例的覆盖目标
  - 新增 `failure-path/publish-version-collision.md` 说明 publish lifecycle 的典型失败样例
- 完成 `Phase 5: Regression Layering`
  - 新增 `scripts/contract/validator_smoke.rb`
  - 新增 `scripts/contract/handoff_smoke.rb`
  - 新增 `scripts/contract/publish_smoke.rb`
  - 重写 `scripts/contract/smoke_test.rb` 为分层总入口
  - 实测通过 `validator_smoke / handoff_smoke / publish_smoke / smoke_test`
