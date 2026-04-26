# Step: domain_mapping

## 材料

1. [step prompt](/Users/wangwenjie/project/archetype-admin-path/docs/contract/prompts/domain_mapping/STEP_PROMPT.md)
2. [rule](/Users/wangwenjie/project/archetype-admin-path/docs/contract/rules/CONTRACT_DOMAIN_MAPPING_RULE.md)
3. [reference rule](/Users/wangwenjie/project/archetype-admin-path/docs/contract/rules/CONTRACT_REFERENCE_RULE.md)
4. [template](/Users/wangwenjie/project/archetype-admin-path/docs/contract/templates/structured/domain_mapping.template.yaml)
5. [decision checklist](/Users/wangwenjie/project/archetype-admin-path/docs/contract/reviewer/checklists/domain_mapping_ready.md)

## 目标

把当前 batch 范围收敛成可直接供 `contract_spec` 使用的结构骨架。

## 输入

1. 已完成决策放行的 `scope_intake`
2. 与本 batch 相关的 `final_prd` 结构化信息
3. 如有需要，前序 frozen contract

## 输出

1. `contract-02.domain_mapping.yaml`
2. 对当前 batch 是否允许进入 `contract_spec` 的明确决策

## 当前门禁方式

当前阶段先走：

1. rule
2. decision checklist
3. artifact 内 `decision.allow_contract_spec`

当前还不是正式 reviewer gate。
