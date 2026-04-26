# Contract Hardening Workplan

这份文档用于指导下一上下文中的 AI，在 `contract` 第一批骨架和 Phase 6 修补完成后，继续推进第二阶段的正式化建设。

当前目标不再是“把骨架搭起来”，而是把现有骨架逐步收紧成可持续接入 run、validator、render 和 freeze 发布的正式工作流。

## 总目标

基于已经存在的 `docs/contract/` 与 `scripts/contract/` 骨架，完成第二阶段 hardening，使 `contract` 更接近现有 `prd` 的可执行程度，同时不打破已经固定下来的目录、命名和 reviewer 独立性约束。

## 统一原则

1. 延续现有 `contract` 文档、模板、脚本和 gate 口径，不重新发明另一套流程。
2. reviewer 仍必须由独立子 agent 或独立新上下文执行，主 agent 不得自己兼任 reviewer。
3. 正式 reviewer gate 仍只放在 `contract_spec`，除非本计划显式新增 phase 调整 gate 设计。
4. 冻结态正式主键继续统一用 `contract_id`，MVP 继续采用 `contract_id = batch_id`。
5. 所有 run 级 batch start handoff 路径统一使用 `runs/<run-id>/contract/handoffs/`。
6. 先把 validator、render、run 集成、freeze 发布桥接补稳，再考虑更重的自动化。

## 执行顺序

当前状态总览：

- 当前阶段：completed
- 最近更新：2026-04-23
- 执行备注：
  - `01` 号 bootstrap 已完成，本计划从 `02` 开始接手
  - `Phase 1 -> Phase 4` 已完成，validator、render、run 入口和 freeze publish bridge 都已补上
  - 当前缺少最小 happy-path / failure-path 回归抓手
  - 当前缺少回归样例与 run 集成材料快照

### Phase 1: Validator Hardening

status: completed

目标：

- 让 `validate_artifact.rb` 从最弱校验提升到具备关键 cross-field 约束的 MVP validator

应完成：

- 为 `scope_intake`、`domain_mapping`、`contract_spec`、`review`、`freeze` 增加关键必填和布尔字段校验
- 为 `review` 增加 subject / `contract_id` / `batch_id` 一致性校验
- 为 `freeze` 增加 review / contract_spec 来源一致性校验
- 把当前关键校验规则写回文档或脚本注释中

完成标准：

- 基础字段缺失和关键一致性错误能被 validator 拦住
- 至少覆盖当前 Phase 6 修过的 review/freeze 关键约束

### Phase 2: Render Hardening

status: completed

目标：

- 让 `render_artifact.rb` 产出的 Markdown 不再只是通用 dump，而是能服务 reviewer 与人工检查

应完成：

- 为五类 artifact 分别定义更稳定的 section 输出
- 让 review / freeze rendered 视图更贴近 gate 使用场景
- 保持 rendered 文件命名与 `STEP_NAMING_GUIDE.md` 一致

完成标准：

- rendered Markdown 至少能清楚展示当前 artifact 的关键区块和 decision 结果
- 不再只依赖通用 hash/array dump

### Phase 3: Run Integration

status: completed

目标：

- 建立与 `scripts/prd/` 接近的 contract run 内路径与材料初始化能力

应完成：

- 补 contract materials / review materials 查询入口
- 让 workflow manifest 能更明确描述 batch 目录和 rendered 路径
- 规划或落最小 `continue_run` / `finalize_step` 接口骨架

完成标准：

- run 内 artifact / review / rendered 路径可统一推导
- 材料入口不再只靠人工手拼路径

### Phase 4: Freeze Publish Bridge

status: completed

目标：

- 把 run 内 `freeze.yaml` 与 `contracts/<contract_id>/` 冻结态目录桥接起来

应完成：

- 定义 `contracts/<contract_id>/current/` 与 `versions/` 的最小落盘规则
- 规划或落地 freeze publish 脚本骨架
- 明确 review pass 后的最小归档动作

完成标准：

- freeze 不再只是 run 内声明文件
- 至少存在通向正式冻结归档目录的最小桥接规则

### Phase 5: Examples And Regression

status: completed

目标：

- 提供 contract happy-path 样例和基本回归脚本，降低后续重构风险

应完成：

- 补最小 contract examples 目录或 smoke 样例集
- 固化至少一条 happy-path 回归链路
- 固化至少一条失败路径回归链路

完成标准：

- validator / review / freeze 的核心链路可被重复验证
- 后续改动有最小回归抓手

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
- 完整 `contract continue_run` / `finalize_step` 实现
- 完整自动发布 `contracts/<contract_id>/versions/*`
- 多 batch 并行策略自动化

这些应在 hardening 主链完成后继续推进。

## 执行日志

### 2026-04-23

- 更新 `DEVELOPMENT_CONTEXT_PRINCIPLES.md`，补入本轮 `contract hardening` 的稳定边界
- 更新 `PENDING_ITEMS.md`，把 schema 全覆盖、完整自动化闭环和多 batch 复杂度继续留在后续轮次
- 完成 `Phase 1: Validator Hardening`
  - 新增 `scripts/contract/artifact_utils.rb`
  - 将 `validate_artifact.rb` 改为调用共享校验逻辑
  - 收紧 `contract_id = batch_id`、review subject 一致性、freeze publish 前置条件等关键约束
- 完成 `Phase 2: Render Hardening`
  - 重写 `scripts/contract/render_artifact.rb`
  - 为五类 contract artifact 定义稳定 section 输出
  - 强化 `review` / `freeze` rendered 视图，便于 gate 检查与人工通读
- 完成 `Phase 3: Run Integration`
  - 扩充 `scripts/contract/workflow_manifest.rb`，统一 batch、rendered、handoff、batch index 和 freeze 路径推导
  - 新增 `scripts/contract/materials.rb`
  - 新增最小 `scripts/contract/continue_run.rb` 与 `scripts/contract/finalize_step.rb`
  - 更新 `docs/contract/README.md` 与 `docs/contract/WORKFLOW_GUIDE.md`，回链新的 run 入口
- 完成 `Phase 4: Freeze Publish Bridge`
  - 更新 `scripts/contract/freeze_artifact.rb`，补全 version label、summary、rendered paths 和 publish 前校验
  - 新增 `scripts/contract/publish_freeze.rb`
  - 更新 `contracts/README.md`，固定 `current / versions` 的最小归档规则
- 完成 `Phase 5: Examples And Regression`
  - 新增 `docs/contract/examples/1.0/` happy-path 与 failure-path 样例
  - 新增 `scripts/contract/smoke_test.rb`
  - 实测覆盖 happy-path validator/render/freeze/publish，以及一条 failure-path validator 拦截
