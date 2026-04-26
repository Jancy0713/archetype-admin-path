# Contract Hardening Prompt

你现在接手本仓库的 `contract` 正式流程第二阶段建设，目标不是重做第一批骨架，而是在现有骨架基础上继续 hardening。

## 先读取这些文件

- /Users/wangwenjie/project/archetype-admin-path/docs/development_progress/README.md
- /Users/wangwenjie/project/archetype-admin-path/docs/development_progress/DEVELOPMENT_CONTEXT_PRINCIPLES.md
- /Users/wangwenjie/project/archetype-admin-path/docs/development_progress/PENDING_ITEMS.md
- /Users/wangwenjie/project/archetype-admin-path/docs/development_progress/contract/README.md
- /Users/wangwenjie/project/archetype-admin-path/docs/development_progress/contract/01_CONTRACT_BOOTSTRAP_WORKPLAN.md
- /Users/wangwenjie/project/archetype-admin-path/docs/development_progress/contract/02_CONTRACT_HARDENING_WORKPLAN.md
- /Users/wangwenjie/project/archetype-admin-path/docs/contract/README.md
- /Users/wangwenjie/project/archetype-admin-path/docs/contract/WORKFLOW_GUIDE.md
- /Users/wangwenjie/project/archetype-admin-path/docs/contract/STRUCTURED_OUTPUT_GUIDE.md
- /Users/wangwenjie/project/archetype-admin-path/docs/contract/STEP_NAMING_GUIDE.md
- /Users/wangwenjie/project/archetype-admin-path/docs/contract/prompts/README.md
- /Users/wangwenjie/project/archetype-admin-path/docs/contract/steps/README.md
- /Users/wangwenjie/project/archetype-admin-path/docs/contract/reviewer/README.md
- /Users/wangwenjie/project/archetype-admin-path/docs/contract/reviewer/common/REVIEWER_WORKFLOW.md
- /Users/wangwenjie/project/archetype-admin-path/docs/contract/reviewer/checklists/contract_spec_ready.md
- /Users/wangwenjie/project/archetype-admin-path/docs/contract/rules/CONTRACT_SCOPE_INTAKE_RULE.md
- /Users/wangwenjie/project/archetype-admin-path/docs/contract/rules/CONTRACT_DOMAIN_MAPPING_RULE.md
- /Users/wangwenjie/project/archetype-admin-path/docs/contract/rules/CONTRACT_SPEC_RULE.md
- /Users/wangwenjie/project/archetype-admin-path/docs/contract/rules/CONTRACT_REFERENCE_RULE.md
- /Users/wangwenjie/project/archetype-admin-path/docs/contract/templates/structured/
- /Users/wangwenjie/project/archetype-admin-path/scripts/contract/
- /Users/wangwenjie/project/archetype-admin-path/contracts/README.md
- /Users/wangwenjie/project/archetype-admin-path/docs/prd/README.md
- /Users/wangwenjie/project/archetype-admin-path/docs/prd/WORKFLOW_GUIDE.md
- /Users/wangwenjie/project/archetype-admin-path/scripts/prd/

## 工作原则

1. 保持与现有 `init / prd` 的目录结构、命名方式、YAML-first + Markdown-rendered 思路一致。
2. 不推翻已经落地的 `contract` 骨架，只做 hardening 和集成补强。
3. reviewer 必须由独立子 agent 或独立新上下文执行，主 agent 不得自己兼任 reviewer。
4. 正式 reviewer gate 仍放在 `contract_spec`，除非工作计划先更新。
5. 当前冻结态正式主键继续统一用 `contract_id`，MVP 继续采用 `contract_id = batch_id`。
6. run 级 batch start handoff 路径统一是 `runs/<run-id>/contract/handoffs/`，不要混淆成 workflow prompts。

## 强制执行规则

下面这些是强制要求，不是建议：

1. 开始动手前，先检查 `/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/contract/02_CONTRACT_HARDENING_WORKPLAN.md` 是否足够完整。
2. 开始动手前，先更新 `/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/DEVELOPMENT_CONTEXT_PRINCIPLES.md` 与 `/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/PENDING_ITEMS.md` 中当前轮次可沉淀的内容。
3. 如果你发现计划不完善、顺序需要调整、或执行中发现必须新增工作项，必须先更新工作计划文件，再继续修改代码或文档。
4. 每完成一个 phase，都必须更新工作计划中的最新状态。
5. 每完成一个 phase，都必须向用户同步：
   - 当前计划做到哪里了
   - 这一阶段具体完成了什么
   - 下一阶段准备做什么
6. 如果发现当前文档之间仍有冲突，先修文档/计划冲突，再继续 hardening。

## 执行顺序

严格按工作计划中的 phase 顺序推进：

1. Phase 1: Validator Hardening
2. Phase 2: Render Hardening
3. Phase 3: Run Integration
4. Phase 4: Freeze Publish Bridge
5. Phase 5: Examples And Regression

不要跳步骤。

## 本轮目标

本轮目标是继续把 `contract` 流程推向可执行化，而不是回头重写 bootstrap。

优先追求：

- validator 关键约束到位
- rendered 视图可检查
- run 路径和材料入口可推导
- freeze 与正式归档之间有桥接
- 有最小回归抓手

不要优先追求：

- 一次性做全量 schema
- 一次性把全部自动化打通
- 一次性解决所有并行 batch 复杂度

## 编辑要求

1. 先检查现有文件和目录，不要凭空假设。
2. 用 `apply_patch` 做文件编辑。
3. 修改时尽量保持与现有 `prd` 结构一致。
4. 本轮结束时，明确说明 `02` 号 workplan 当前状态。
