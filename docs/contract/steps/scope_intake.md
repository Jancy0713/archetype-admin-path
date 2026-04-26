# Step: scope_intake

## 材料

1. [step prompt](/Users/wangwenjie/project/archetype-admin-path/docs/contract/prompts/scope_intake/STEP_PROMPT.md)
2. [rule](/Users/wangwenjie/project/archetype-admin-path/docs/contract/rules/CONTRACT_SCOPE_INTAKE_RULE.md)
3. [template](/Users/wangwenjie/project/archetype-admin-path/docs/contract/templates/structured/scope_intake.template.yaml)
4. [decision checklist](/Users/wangwenjie/project/archetype-admin-path/docs/contract/reviewer/checklists/scope_intake_ready.md)

## 目标

稳定产出可直接供 `domain_mapping` 使用的 batch 边界输入。

## 输入

1. 当前目标 batch 的 `final_prd` handoff
2. 必要的 `final_prd` 主 YAML / rendered 视图
3. 如有依赖，前序已冻结 contract

## 输出

1. `contract-01.scope_intake.yaml`
2. 对当前 batch 是否允许进入 `domain_mapping` 的明确决策

## 当前门禁方式

当前阶段先走：

1. rule
2. decision checklist
3. artifact 内 `decision.allow_domain_mapping`

当前还不是正式 reviewer gate。
