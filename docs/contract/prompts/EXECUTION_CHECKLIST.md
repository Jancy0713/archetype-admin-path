# Contract 执行清单

## Step 1：scope_intake

输入：

- 单个 ready batch 的 `final_prd` handoff
- [scope_intake step prompt](/Users/wangwenjie/project/archetype-admin-path/docs/contract/prompts/scope_intake/STEP_PROMPT.md)
- [CONTRACT_SCOPE_INTAKE_RULE.md](/Users/wangwenjie/project/archetype-admin-path/docs/contract/rules/CONTRACT_SCOPE_INTAKE_RULE.md)
- [scope_intake.template.yaml](/Users/wangwenjie/project/archetype-admin-path/docs/contract/templates/structured/scope_intake.template.yaml)

检查点：

- 当前 batch 范围是否明确
- 当前 batch 依赖是否明确
- `do_not_assume` 是否被显式吸收
- 是否仍有阻塞进入 `domain_mapping` 的问题

## Step 2：domain_mapping

输入：

- 已完成决策放行的 `scope_intake`
- [domain_mapping step prompt](/Users/wangwenjie/project/archetype-admin-path/docs/contract/prompts/domain_mapping/STEP_PROMPT.md)
- [CONTRACT_DOMAIN_MAPPING_RULE.md](/Users/wangwenjie/project/archetype-admin-path/docs/contract/rules/CONTRACT_DOMAIN_MAPPING_RULE.md)
- [domain_mapping.template.yaml](/Users/wangwenjie/project/archetype-admin-path/docs/contract/templates/structured/domain_mapping.template.yaml)

检查点：

- 资源和动作边界是否清楚
- consumer views 是否基本清楚
- 共享定义和新增定义边界是否清楚
- 关键引用计划是否已标记

## Step 3：contract_spec

输入：

- 已完成决策放行的 `domain_mapping`
- [contract_spec step prompt](/Users/wangwenjie/project/archetype-admin-path/docs/contract/prompts/contract_spec/STEP_PROMPT.md)
- [CONTRACT_SPEC_RULE.md](/Users/wangwenjie/project/archetype-admin-path/docs/contract/rules/CONTRACT_SPEC_RULE.md)
- [CONTRACT_REFERENCE_RULE.md](/Users/wangwenjie/project/archetype-admin-path/docs/contract/rules/CONTRACT_REFERENCE_RULE.md)
- [contract_spec.template.yaml](/Users/wangwenjie/project/archetype-admin-path/docs/contract/templates/structured/contract_spec.template.yaml)

检查点：

- 关键 consumer views 是否具备可消费完整度
- 资源、字段、状态、权限和错误语义是否达到关键完整度
- 是否仍然在当前 batch 范围内
- 引用关系是否清楚且稳定

## Step 4：contract_spec review

检查点：

- review 是否由独立 reviewer 子 agent 或独立上下文执行
- `meta.subject_path` 是否指向当前 `contract_spec` YAML
- reviewer 是否满足 [contract_spec_ready checklist](/Users/wangwenjie/project/archetype-admin-path/docs/contract/reviewer/checklists/contract_spec_ready.md)
- reviewer 是否明确给出 blocking issue、返工落点和是否允许 release

## Step 5：release

输入：

- 已通过 review 的 `contract_spec`
- [review step prompt](/Users/wangwenjie/project/archetype-admin-path/docs/contract/prompts/review/STEP_PROMPT.md)
- `contract/release/openapi.yaml`
- `contract/release/openapi.summary.md`
- `contract/release/develop-handoff.md`

检查点：

- 是否只有在 review 通过后才生成 release
- `contract/working/` 与 `contract/release/` 是否明确分离
- 下游正式输入是否已经落在 `contract/release/`
- 是否误把 working 过程态当成正式交付
