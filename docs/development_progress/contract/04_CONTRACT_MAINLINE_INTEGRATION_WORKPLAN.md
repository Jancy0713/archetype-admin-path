# Contract Mainline Integration Workplan

这份文档用于指导下一上下文中的 AI，在 `03` 号 execution closure 已完成后，继续推进第四阶段的主链集成建设。

当前目标不再是单点 hardening 或 execution closure，而是把已经存在的 `contract` 脚本入口、handoff 生成、review 收口、freeze publish 和回归，真正接进更完整的主流程。

## 总目标

基于当前已完成的 `contract` execution closure 结果，继续补齐真正进入主链前仍然偏弱的部分：

- `final_prd -> contract` 主链接入
- contract run 自己的 progress / state 可视化
- step closure 的标准操作面
- 更贴近真实 run 的端到端样例
- 主链级 end-to-end regression

目标是让 `contract` 从“可单独执行的一组脚本”进一步演进到“能稳定接在 PRD 主链后面”的正式阶段。

## 统一原则

1. 延续现有 `contract` 文档、模板、脚本和 gate 口径，不另起一套流程。
2. reviewer 仍必须由独立子 agent 或独立新上下文执行，主 agent 不得自己兼任 reviewer。
3. 正式 reviewer gate 仍只放在 `contract_spec`，除非本计划显式新增 phase 调整 gate 设计。
4. 冻结态正式主键继续统一用 `contract_id`，MVP 继续采用 `contract_id = batch_id`。
5. 所有 run 级 batch start handoff 路径统一使用 `runs/<run-id>/contract/handoffs/`。
6. 当前阶段优先做主链接入与标准收口，不追求一次性做多 batch 并行自动调度。

## 执行顺序

当前状态总览：

- 当前阶段：completed
- 最近更新：2026-04-23
- 执行备注：
  - `03` 号 execution closure 已完成
  - 当前已有最小 `generate_batch_handoffs / review_complete / verify_published_contract / layered smoke`
  - 当前 `scripts/prd/review_complete.rb` 在 `final_prd` 通过后只更新了进度文案，还没有正式触发 `contract` handoff/index 生成
  - 当前 `contract` 仍缺少自己的 progress board，以及 batch 解锁后的 `current_exposed_batch` 推进规则
  - 当前 `contract` 已有 `state/contract-04.review-result.yaml`，但还没有把 `review -> freeze -> publish` 收口与 batch 暴露顺序统一起来
  - 当前 `contract` 样例与 smoke 已覆盖 handoff / publish 分层，但还缺少贴近真实 run 的主链接续样例

### Phase 1: PRD To Contract Hookup

status: completed

目标：

- 把 `final_prd` 通过后的 `contract` handoff 生成正式接入主链

应完成：

- 明确 `final_prd` 完成后如何触发 `generate_batch_handoffs.rb`
- 补最小主链脚本或接入点，优先复用 `scripts/prd/review_complete.rb`
- 统一主链对“当前 batch / 后续 batch / 用户提示”的口径

完成标准：

- `final_prd` 收口后，contract handoff/index 可稳定生成
- 主链不再依赖人工补生成命令
- `prd` progress 或主链输出能明确指向当前 contract handoff 入口，而不是只停留在抽象的 `contract` 文案

### Phase 2: Contract Progress Board

status: completed

目标：

- 给 `contract` 自己补最小 progress / state 可视化入口

应完成：

- 规划或落 contract progress board 模板
- 把当前 batch 的 step、review、freeze、publish 状态接进统一板面
- 明确当前 batch 与后续 batch 的展示关系
- 明确 board 与 `contract-batch-index.yaml`、`state/*.yaml` 的最小职责分层

完成标准：

- contract run 当前走到哪一步可稳定查看
- 多 batch 时不容易串状态
- 用户能从 run 内同一入口同时看到当前 batch、当前步骤和后续 batch 是否已解锁

### Phase 3: Contract Step Closure

status: completed

目标：

- 把 `continue_run / finalize_step / review_complete / freeze / publish` 串成更统一的标准操作面

应完成：

- 收紧 step closure 的推荐调用顺序
- 补必要的辅助脚本或文档回链
- 明确每一步完成后下一步是什么
- 把 `review_complete / freeze / publish` 后的 state 推进与 batch index 解锁动作统一起来

完成标准：

- 当前 batch 从启动到 freeze/publish 的操作路径更顺滑
- 脚本之间的边界更清楚
- 当前 batch 完成后，下一批的暴露状态能被稳定推进而不是只靠人工脑补

### Phase 4: Real Run Example

status: completed

目标：

- 提供一条更贴近真实主链接入的 contract run 样例

应完成：

- 补一组从 `final_prd` handoff 进入 contract 的 run 样例
- 让样例包含 progress / state / handoff / freeze / publish 的关键节点
- README 明确样例是在模拟哪条主链
- 样例尽量复用真实 `runs/<run-id>/` 布局，而不是只保留片段化静态文件

完成标准：

- 新样例可帮助后续直接回放“真实主链接入”场景

### Phase 5: End-To-End Regression

status: completed

目标：

- 补一条接近主链的端到端回归链路

应完成：

- 从 `final_prd` 开始，跑到 contract handoff、当前 batch step closure、freeze、publish
- 失败输出能指出是 PRD hookup、contract closure 还是 publish 层出了问题
- 文档化推荐执行方式
- 尽量复用现有 `docs/prd/examples/2.0/happy-path-run/` 与 `scripts/contract/*smoke.rb`，避免另造平行 harness

完成标准：

- 合并后的主链至少有一条可重复验证的 end-to-end regression

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

- 多 batch 并行自动调度
- 完整 contract GUI/前端入口
- 完整版本迁移机制
- 全量 schema 覆盖

这些应在主链接入稳定后继续推进。

## 执行日志

### 2026-04-23

- 更新 `DEVELOPMENT_CONTEXT_PRINCIPLES.md`，补入第四阶段 mainline integration 的主链接点、contract progress/state 形态与 batch 解锁原则
- 更新 `PENDING_ITEMS.md`，继续把 contract GUI/重型 orchestration 留在后续轮次
- 完成 `Phase 1: PRD To Contract Hookup`
  - 新增 `scripts/contract/handoff_generation.rb`
  - 更新 `scripts/contract/generate_batch_handoffs.rb`，改为复用共享 handoff 生成逻辑
  - 更新 `scripts/prd/review_complete.rb`，让 `prd-04 final_prd` review 通过后自动生成 `contract-batch-index.yaml`、`contract-handoff.md` 与当前 batch handoff
  - 更新 `docs/prd/WORKFLOW_GUIDE.md` 与 `docs/contract/WORKFLOW_GUIDE.md`，把正式主链接点回写到流程文档
  - 新增 `scripts/contract/mainline_smoke.rb`
  - 实测通过 `mainline_smoke.rb` 与 `handoff_smoke.rb`
- 完成 `Phase 2: Contract Progress Board`
  - 新增 `docs/templates/contract-progress.template.md`
  - 新增 `scripts/contract/progress_board.rb`
  - 更新 `scripts/contract/handoff_generation.rb`，生成 handoff 时同步初始化 `contract/contract-progress.md`
  - 更新 `scripts/contract/continue_run.rb` 与 `scripts/contract/finalize_step.rb`，把当前 batch 的 step/review 状态写进 contract progress board
  - 更新 `docs/contract/WORKFLOW_GUIDE.md` 与 `docs/contract/examples/1.0/README.md`，补入 progress board 入口与回归命令
  - 新增 `scripts/contract/progress_board_smoke.rb`
  - 实测通过 `progress_board_smoke.rb` 与 `mainline_smoke.rb`
- 完成 `Phase 3: Contract Step Closure`
  - 新增 `scripts/contract/batch_index.rb`
  - 新增 `scripts/contract/expose_next_batch.rb`
  - 更新 `scripts/contract/review_complete.rb`，把 reviewer 收口结果同步回 contract progress board
  - 更新 `scripts/contract/freeze_artifact.rb`，修正相对 `subject_path` 解析并把 freeze 状态同步回 contract progress board
  - 更新 `scripts/contract/publish_freeze.rb`，把 publish 结果同步回 batch index 与 contract progress board
  - 更新 `docs/contract/WORKFLOW_GUIDE.md`，补入标准 step closure 顺序与“用户确认后再 expose next batch”的显式操作面
  - 新增 `scripts/contract/step_closure_smoke.rb`
  - 实测通过 `step_closure_smoke.rb`，并回归通过 `publish_smoke.rb`、`mainline_smoke.rb`、`progress_board_smoke.rb` 与 `handoff_smoke.rb`
- 完成 `Phase 4: Real Run Example`
  - 新增 `docs/contract/examples/1.0/mainline-path-run/README.md`
  - 新增 `mainline-path-run/contract/contract-batch-index.yaml`
  - 新增 `mainline-path-run/contract/contract-handoff.md`
  - 新增 `mainline-path-run/contract/contract-progress.md`
  - 新增 `mainline-path-run/contract/batch-foundation-access/state/contract-04.review-result.yaml`
  - 新增 `mainline-path-run/contract/batch-foundation-access/freeze.yaml`
  - 新增 `mainline-path-run/published/batch-foundation-access/current/publish_manifest.yaml`
  - 新增 `mainline-path-run/contract/handoffs/02.batch-account-access.contract-start.md`
  - 更新 `docs/contract/examples/1.0/README.md`，把 mainline-path-run 收入 examples 索引
- 完成 `Phase 5: End-To-End Regression`
  - 新增 `scripts/contract/mainline_e2e_smoke.rb`
  - 更新 `scripts/contract/smoke_test.rb`，把主链级 e2e smoke 纳入总 smoke 入口
  - 更新 `docs/contract/examples/1.0/README.md`，补入 `mainline_e2e_smoke.rb`
  - 串行实测通过 `mainline_e2e_smoke.rb`
  - 串行实测通过 `smoke_test.rb`
