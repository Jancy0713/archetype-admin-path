# Contract Step Prompt: contract_spec

当前步骤：`contract-03 contract_spec`

## 目标

产出当前 batch 的正式实现协议主体，使前端、后端、AI 和脚本都不需要再猜关键实现边界。

## 必读材料

1. [MASTER_PROMPT.md](/Users/wangwenjie/project/archetype-admin-path/docs/contract/prompts/MASTER_PROMPT.md)
2. [CONTRACT_SPEC_RULE.md](/Users/wangwenjie/project/archetype-admin-path/docs/contract/rules/CONTRACT_SPEC_RULE.md)
3. [CONTRACT_REFERENCE_RULE.md](/Users/wangwenjie/project/archetype-admin-path/docs/contract/rules/CONTRACT_REFERENCE_RULE.md)
4. [contract_spec.template.yaml](/Users/wangwenjie/project/archetype-admin-path/docs/contract/templates/structured/contract_spec.template.yaml)
5. 已完成决策放行的 `scope_intake` 与 `domain_mapping`
6. 必要的前序 frozen contracts

## 这一步必须完成

1. 明确正式适用范围和共享引用。
2. 写清核心资源协议、字段语义、状态约束和引用关系。
3. 写清关键 consumer views。
4. 写清查询、命令、权限、租户、校验和错误语义。
5. 在 `decision` 中明确是否允许进入 review。

## 这一步不能做

1. 不重新打开需求澄清。
2. 不引入新的未确认功能。
3. 不把宏观 PRD 背景或实现任务清单写进主体。
4. 不引用未冻结、不可追踪的外部中间状态。

## 输出要求

1. 只输出 `contract_spec` YAML。
2. 严格遵循模板字段。
3. 引用关系必须可定位、可解释、可追踪。
