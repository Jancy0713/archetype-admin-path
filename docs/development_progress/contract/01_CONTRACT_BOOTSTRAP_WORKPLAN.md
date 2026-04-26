# Contract Bootstrap Workplan

这份文档用于指导下一上下文中的 AI，从当前已经完成的 `contract` 流程文档出发，开始第一批正式骨架实现。

当前目标不是直接做完整功能，而是先把：

- 模板
- prompts
- reviewer checklists
- steps 材料链接
- scripts 骨架

按顺序搭起来。

## 总目标

把当前 `docs/contract/` 中已经定义好的流程、步骤、规则和 reviewer 机制，推进成第一批可落地的正式骨架文件，并保持与现有 `init / prd` 体系一致。

## 统一原则

1. 保持与现有 `init / prd` 的目录结构、命名方式、YAML-first + Markdown-rendered 思路一致。
2. reviewer 必须由独立子 agent 或独立新上下文执行，主 agent 不得自己兼任 reviewer。
3. MVP 当前正式 reviewer gate 放在 `contract_spec`，`scope_intake` 和 `domain_mapping` 先走规则 + 决策门禁。
4. 当前冻结态正式主键统一用 `contract_id`，MVP 先采用 `contract_id = batch_id`。
5. `docs/contract/prompts/` 是 workflow prompts；`runs/<run-id>/contract/handoffs/` 是 batch start handoff，不要混淆。
6. 当前阶段先做骨架和材料补齐，不直接冲向复杂脚本实现。

## 执行顺序

当前状态总览：

- 当前阶段：Phase 6 completed
- 最近更新：2026-04-23
- 执行备注：
  - 本文档对应 `01` 号开发推进记录
  - `Phase 1 -> Phase 6` 已全部完成
  - 下一阶段应转入 `02` 号 hardening workplan

### Phase 1: 模板骨架

status: completed

目标：

- 先补齐 `contract` 结构化主产物的模板占位

应完成：

- `docs/contract/templates/structured/scope_intake.template.yaml`
- `docs/contract/templates/structured/domain_mapping.template.yaml`
- `docs/contract/templates/structured/contract_spec.template.yaml`
- `docs/contract/templates/structured/review.template.yaml`
- `docs/contract/templates/structured/freeze.template.yaml`

完成标准：

- 5 个模板都存在
- 模板区块与 `STRUCTURED_OUTPUT_GUIDE.md` 一致
- 命名与 `STEP_NAMING_GUIDE.md` 一致
- 备注：本 phase 允许只先落区块级 YAML 骨架，不要求 validator 字段一次性定完

### Phase 2: Prompt 骨架

status: completed

目标：

- 补齐 `contract` 的 workflow prompts 结构

应完成：

- `docs/contract/prompts/MASTER_PROMPT.md`
- `docs/contract/prompts/REVIEWER_PROMPT.md`
- `docs/contract/prompts/EXECUTION_CHECKLIST.md`
- `docs/contract/prompts/scope_intake/STEP_PROMPT.md`
- `docs/contract/prompts/domain_mapping/STEP_PROMPT.md`
- `docs/contract/prompts/contract_spec/STEP_PROMPT.md`
- `docs/contract/prompts/review/STEP_PROMPT.md`

完成标准：

- prompt 目录结构完整
- prompt 组织方式与现有 `docs/prd/prompts/` 接近
- 每个步骤文件职责清楚，不互相混写
- 备注：`docs/contract/prompts/` 是 workflow prompts，不承担 batch start handoff 角色

### Phase 3: Reviewer Checklist 补齐

status: completed

目标：

- 让 reviewer 层不只停留在总说明

应完成：

- `docs/contract/reviewer/checklists/scope_intake_ready.md`
- `docs/contract/reviewer/checklists/domain_mapping_ready.md`
- 保持现有 `contract_spec_ready.md` 一致性

完成标准：

- 关键步骤至少都有对应 checklist
- checklist 与对应 rule / step 目标一致

### Phase 4: Step Materials 回链补齐

status: completed

目标：

- 让 `steps/*.md` 真正成为单步入口，而不是占位页

应完成：

- 更新 `docs/contract/steps/scope_intake.md`
- 更新 `docs/contract/steps/domain_mapping.md`
- 更新 `docs/contract/steps/contract_spec.md`
- 更新 `docs/contract/steps/review.md`

完成标准：

- 每一步都能链接到已有 step prompt / rule / template / checklist
- 尽量减少“待补”占位文字

### Phase 5: Scripts 骨架

status: completed

目标：

- 在文档和材料骨架稳定后，再建立 `scripts/contract/` 空壳

应完成：

- `scripts/contract/workflow_manifest.rb`
- `scripts/contract/init_artifact.rb`
- `scripts/contract/validate_artifact.rb`
- `scripts/contract/render_artifact.rb`
- `scripts/contract/init_review_context.rb`
- `scripts/contract/review_complete.rb`
- `scripts/contract/freeze_artifact.rb`

完成标准：

- 文件骨架存在
- 命名、职责和现有 `scripts/prd/` 结构一致
- 不要求一步到位实现全部细节

### Phase 6: 骨架修补

status: completed

目标：

- 修正骨架阶段 review 暴露出的高优先级缺陷和文档冲突

应完成：

- 修正 `freeze_artifact.rb`，强校验 review subject / `contract_id` / `batch_id` 一致性
- 收紧 review 验证，至少要求 `meta.reviewer` 非空
- 强化 `review_complete.rb` 的 run 内 subject 归一化
- 修正 `handoffs` 与 `prompts` 的路径口径冲突
- 清理 contract 文档中“尚未补 prompt/template/checklist”之类已过期表述

完成标准：

- freeze 不能复用不匹配的 review 去冻结其他 subject
- reviewer 身份不再允许留空通过基础校验
- review_complete 至少能把当前 run 的理论 subject 与 review 对齐
- handoff 路径口径统一为 `runs/<run-id>/contract/handoffs/`
- 主要 contract 文档不再保留与当前骨架状态冲突的旧表述

## 执行日志

### 2026-04-23

- `01` 号 bootstrap 记录建立完成
- `Phase 1 -> Phase 6` 已完成
- 第一批 contract 正式流程骨架与骨架修补已落地
- 后续推进入口迁移至 `02_CONTRACT_HARDENING_WORKPLAN.md`

## 计划更新规则

这是强约束，不是建议。

1. 开始执行前，必须先对照当前仓库状态检查这份计划是否仍完整。
2. 如果发现计划缺项、顺序有问题、或出现新的必要工作，必须先更新这份计划，再继续落文件。
3. 每完成一个 phase，都要更新本文件中的进度状态。
4. 每完成一个 phase，都要向用户同步当前进度、已完成内容、下一阶段内容。
5. 如果执行中发现需要新增 phase，也必须先回写本计划，再继续代码或文档修改。

## 当前边界

当前计划已经完成，不再承担后续 hardening 工作的推进管理。
