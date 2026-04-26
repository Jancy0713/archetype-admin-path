# Contract Step Prompt: scope_intake

当前步骤：`contract-01 scope_intake`

## 目标

接收单个 ready batch 的 `final_prd` handoff，稳定产出后续 `domain_mapping` 可直接消费的 batch 边界输入。

## 必读材料

1. [MASTER_PROMPT.md](/Users/wangwenjie/project/archetype-admin-path/docs/contract/prompts/MASTER_PROMPT.md)
2. [CONTRACT_SCOPE_INTAKE_RULE.md](/Users/wangwenjie/project/archetype-admin-path/docs/contract/rules/CONTRACT_SCOPE_INTAKE_RULE.md)
3. [scope_intake.template.yaml](/Users/wangwenjie/project/archetype-admin-path/docs/contract/templates/structured/scope_intake.template.yaml)
4. 当前 batch 对应的 `final_prd` handoff 和必要上游材料

## 这一步必须完成

1. 明确当前 batch 覆盖什么、不覆盖什么。
2. 明确当前 batch 依赖哪些前置 batch 或 frozen contract。
3. 显式吸收 `do_not_assume`。
4. 只保留真正阻塞进入 `domain_mapping` 的问题。
5. 在 `decision` 中明确是否允许进入下一步。

## 这一步不能做

1. 不直接展开最终字段协议。
2. 不定义最终查询参数和输入输出结构。
3. 不把未确认事实写成既定范围。
4. 不把别的 batch 内容提前混入当前 batch。

## 输出要求

1. 只输出 `scope_intake` YAML。
2. 严格遵循模板字段。
3. 来源路径必须真实可追踪。
