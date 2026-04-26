# Contract Bootstrap Prompt

你现在接手本仓库的 `contract` 正式流程建设，目标不是继续讨论方案，而是基于现有文档开始第一批骨架实现。

## 先读取这些文件

- /Users/wangwenjie/project/archetype-admin-path/docs/development_progress/README.md
- /Users/wangwenjie/project/archetype-admin-path/docs/development_progress/DEVELOPMENT_CONTEXT_PRINCIPLES.md
- /Users/wangwenjie/project/archetype-admin-path/docs/development_progress/PENDING_ITEMS.md
- /Users/wangwenjie/project/archetype-admin-path/docs/development_progress/contract/01_CONTRACT_BOOTSTRAP_WORKPLAN.md
- /Users/wangwenjie/project/archetype-admin-path/docs/contract/README.md
- /Users/wangwenjie/project/archetype-admin-path/docs/contract/WORKFLOW_GUIDE.md
- /Users/wangwenjie/project/archetype-admin-path/docs/contract/STRUCTURED_OUTPUT_GUIDE.md
- /Users/wangwenjie/project/archetype-admin-path/docs/contract/STEP_NAMING_GUIDE.md
- /Users/wangwenjie/project/archetype-admin-path/docs/contract/steps/README.md
- /Users/wangwenjie/project/archetype-admin-path/docs/contract/reviewer/README.md
- /Users/wangwenjie/project/archetype-admin-path/docs/contract/reviewer/common/REVIEWER_WORKFLOW.md
- /Users/wangwenjie/project/archetype-admin-path/docs/contract/reviewer/checklists/contract_spec_ready.md
- /Users/wangwenjie/project/archetype-admin-path/docs/contract/prompts/README.md
- /Users/wangwenjie/project/archetype-admin-path/docs/contract/rules/CONTRACT_SCOPE_INTAKE_RULE.md
- /Users/wangwenjie/project/archetype-admin-path/docs/contract/rules/CONTRACT_DOMAIN_MAPPING_RULE.md
- /Users/wangwenjie/project/archetype-admin-path/docs/contract/rules/CONTRACT_SPEC_RULE.md
- /Users/wangwenjie/project/archetype-admin-path/docs/contract/rules/CONTRACT_REFERENCE_RULE.md
- /Users/wangwenjie/project/archetype-admin-path/contracts/README.md
- /Users/wangwenjie/project/archetype-admin-path/docs/prd/README.md
- /Users/wangwenjie/project/archetype-admin-path/docs/prd/WORKFLOW_GUIDE.md
- /Users/wangwenjie/project/archetype-admin-path/docs/prd/STRUCTURED_OUTPUT_GUIDE.md
- /Users/wangwenjie/project/archetype-admin-path/docs/prd/STEP_NAMING_GUIDE.md
- /Users/wangwenjie/project/archetype-admin-path/docs/prd/prompts/README.md
- /Users/wangwenjie/project/archetype-admin-path/docs/prd/steps/README.md

## 工作原则

1. 保持与现有 `init / prd` 的目录结构、命名方式、YAML-first + Markdown-rendered 思路一致。
2. reviewer 必须由独立子 agent 或独立新上下文执行，主 agent 不得自己兼任 reviewer。
3. MVP 当前正式 reviewer gate 放在 `contract_spec`，`scope_intake` 和 `domain_mapping` 先走规则 + 决策门禁。
4. 当前冻结态正式主键统一用 `contract_id`，MVP 先采用 `contract_id = batch_id`。
5. `docs/contract/prompts/` 是 workflow prompts；`runs/<run-id>/contract/handoffs/` 是 batch start handoff，不要混淆。
6. 先做骨架和材料补齐，不直接冲向复杂脚本实现。

## 强制执行规则

下面这些是强制要求，不是建议：

1. 开始动手前，先检查 `/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/contract/01_CONTRACT_BOOTSTRAP_WORKPLAN.md` 是否足够完整。
2. 开始动手前，先阅读 `/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/README.md` 的循环规则。
3. 如果你发现计划不完善、顺序需要调整、或执行中发现必须新增工作项，必须先更新工作计划文件，再继续修改代码或文档。
4. 每完成一个 phase，都必须更新工作计划中的最新状态。
5. 每完成一个 phase，都必须向用户同步：
   - 当前计划做到哪里了
   - 这一阶段具体完成了什么
   - 下一阶段准备做什么
6. 如果发现当前文档之间仍有冲突，先修文档/计划冲突，再继续骨架实现。

## 执行顺序

严格按工作计划中的 phase 顺序推进：

1. Phase 1: 模板骨架
2. Phase 2: Prompt 骨架
3. Phase 3: Reviewer Checklist 补齐
4. Phase 4: Step Materials 回链补齐
5. Phase 5: Scripts 骨架
6. Phase 6: 骨架修补

不要跳步骤。

## 本轮目标

本轮目标是把第一批 `contract` 流程骨架文件真正落下来，而不是做完整功能。

优先追求：

- 结构正确
- 目录一致
- 命名一致
- 材料可串联

不要优先追求：

- 一次性把脚本做完
- 一次性把 validator 做全
- 一次性把自动化全打通

## 编辑要求

1. 先检查现有文件和目录，不要凭空假设。
2. 用 `apply_patch` 做文件编辑。
3. 修改时尽量保持与现有 `prd` 结构一致。
4. 本轮结束时，明确说明工作计划当前状态。
