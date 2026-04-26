# Contract Step Prompt: domain_mapping

当前步骤：`contract-02 domain_mapping`

## 目标

把当前 batch 的范围映射成 `contract_spec` 可直接消费的结构骨架，重点拉清资源、动作、状态、权限、视图和引用关系。

## 必读材料

1. [MASTER_PROMPT.md](/Users/wangwenjie/project/archetype-admin-path/docs/contract/prompts/MASTER_PROMPT.md)
2. [CONTRACT_DOMAIN_MAPPING_RULE.md](/Users/wangwenjie/project/archetype-admin-path/docs/contract/rules/CONTRACT_DOMAIN_MAPPING_RULE.md)
3. [CONTRACT_REFERENCE_RULE.md](/Users/wangwenjie/project/archetype-admin-path/docs/contract/rules/CONTRACT_REFERENCE_RULE.md)
4. [domain_mapping.template.yaml](/Users/wangwenjie/project/archetype-admin-path/docs/contract/templates/structured/domain_mapping.template.yaml)
5. 已完成决策放行的 `scope_intake`

## 这一步必须完成

1. 明确当前 batch 的核心资源和动作边界。
2. 明确哪些状态、枚举、权限点由本批定义。
3. 明确哪些内容来自共享 contract，哪些内容由本批新增。
4. 明确本批必须支撑的 consumer views。
5. 在 `reference_plan` 中标出后续 `contract_spec` 必须固化的引用。

## 这一步不能做

1. 不直接把最终字段协议写满。
2. 不把最终 DTO 或接口结构提前当成 mapping 主体。
3. 不忽略 consumer views 或跨模块依赖。
4. 不引用未冻结 contract。

## 输出要求

1. 只输出 `domain_mapping` YAML。
2. 严格遵循模板字段。
3. 共享定义与新增定义必须显式区分。
