# 执行清单

## Step 1：analysis

输入：

- 原始需求 / PRD / 原型 / init 交接输入
- [analysis step prompt](/Users/wangwenjie/project/archetype-admin-path/docs/prd/prompts/analysis/STEP_PROMPT.md)
- [ANALYSIS_RULE.md](/Users/wangwenjie/project/archetype-admin-path/docs/prd/rules/ANALYSIS_RULE.md)
- [analysis.template.yaml](/Users/wangwenjie/project/archetype-admin-path/docs/prd/templates/structured/analysis.template.yaml)

检查点：

- 是否完成范围和模块拆分
- 是否列出风险和阻塞缺口
- 是否形成待澄清候选项

## Step 2：analysis review

检查点：

- 是否允许进入 clarification
- 是否遗漏关键缺口
- `meta.subject_path` 是否指向当前 analysis YAML
- 是否由独立 reviewer 子 agent 或独立上下文完成，而不是主 agent 自审
- 是否满足 [prd_analysis reviewer checklist](/Users/wangwenjie/project/archetype-admin-path/docs/prd/reviewer/checklists/prd_analysis.md)

## Step 3：clarification

输入：

- 已通过 review 的 analysis
- [clarification step prompt](/Users/wangwenjie/project/archetype-admin-path/docs/prd/prompts/clarification/STEP_PROMPT.md)
- [REQUIREMENT_CLARIFICATION_RULE.md](/Users/wangwenjie/project/archetype-admin-path/docs/prd/rules/REQUIREMENT_CLARIFICATION_RULE.md)
- [clarification.template.yaml](/Users/wangwenjie/project/archetype-admin-path/docs/prd/templates/structured/clarification.template.yaml)

检查点：

- 是否统一使用 `confirmation_items`
- `confirmation_items.item_id` 是否使用稳定编号，便于 Human Gate 按编号回复
- 是否只保留真正需要确认的问题
- 是否准备好 Human Confirmation Gate

## Step 4：clarification review + human confirm

检查点：

- reviewer 是否允许进入下一步
- human confirmation 是否已完成
- 所有 `required` 级确认项是否都已在 `clarified_decisions.item_id` 中收口
- `decision.allow_execution_plan` 是否真实成立
- reviewer 是否由独立 reviewer 子 agent 或独立上下文执行
- 是否满足 [prd_clarification reviewer checklist](/Users/wangwenjie/project/archetype-admin-path/docs/prd/reviewer/checklists/prd_clarification.md)

## Step 5：execution_plan

输入：

- 已确认的 clarification
- [execution_plan step prompt](/Users/wangwenjie/project/archetype-admin-path/docs/prd/prompts/execution_plan/STEP_PROMPT.md)
- [EXECUTION_PLAN_RULE.md](/Users/wangwenjie/project/archetype-admin-path/docs/prd/rules/EXECUTION_PLAN_RULE.md)
- [execution_plan.template.yaml](/Users/wangwenjie/project/archetype-admin-path/docs/prd/templates/structured/execution_plan.template.yaml)

检查点：

- 是否明确先后顺序
- 是否明确 contract 优先级
- 是否识别关键依赖

## Step 6：final_prd

输入：

- 已通过 review 的 execution_plan
- 已确认的 clarification
- [final_prd step prompt](/Users/wangwenjie/project/archetype-admin-path/docs/prd/prompts/final_prd/STEP_PROMPT.md)
- [FINAL_PRD_RULE.md](/Users/wangwenjie/project/archetype-admin-path/docs/prd/rules/FINAL_PRD_RULE.md)
- [final_prd.template.yaml](/Users/wangwenjie/project/archetype-admin-path/docs/prd/templates/structured/final_prd.template.yaml)

检查点：

- 是否足够支撑 contract
- 是否还有 P0 未解问题
- ready batch 的 `contract_handoff` 是否完整
- `prd_batches` 是否合理拆分

## Step 7：final_prd review

检查点：

- 是否允许进入 contract
- 是否仍有 blocking issue
- `meta.subject_path` 是否指向当前 final_prd YAML
- reviewer 是否由独立 reviewer 子 agent 或独立上下文执行
- 是否满足 [final_prd_ready reviewer checklist](/Users/wangwenjie/project/archetype-admin-path/docs/prd/reviewer/checklists/final_prd_ready.md)
