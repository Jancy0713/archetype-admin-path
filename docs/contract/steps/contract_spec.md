# Step: contract_spec

## 材料

1. [step prompt](/Users/wangwenjie/project/archetype-admin-path/docs/contract/prompts/contract_spec/STEP_PROMPT.md)
2. [rule](/Users/wangwenjie/project/archetype-admin-path/docs/contract/rules/CONTRACT_SPEC_RULE.md)
3. [reference rule](/Users/wangwenjie/project/archetype-admin-path/docs/contract/rules/CONTRACT_REFERENCE_RULE.md)
4. [template](/Users/wangwenjie/project/archetype-admin-path/docs/contract/templates/structured/contract_spec.template.yaml)
5. [reviewer checklist](/Users/wangwenjie/project/archetype-admin-path/docs/contract/reviewer/checklists/contract_spec_ready.md)
6. [review template](/Users/wangwenjie/project/archetype-admin-path/docs/contract/templates/structured/review.template.yaml)

## 目标

产出当前 flow 的正式实现协议主体，供 review 与后续 release 包收口使用。

## 输入

1. 已完成决策放行的 `scope_intake`
2. 已完成决策放行的 `domain_mapping`
3. 必要的前序 released contracts

## 输出

1. `contract-03.contract_spec.yaml`：必须包含非空的 `api_surface.endpoints` 定义。
2. 进入正式 review gate 的被审主体。

## 当前门禁方式

这是当前 MVP 唯一正式 reviewer gate。

进入下一步前至少需要：

1. `decision.allow_review=true`
2. 独立 reviewer 根据 checklist 审查
3. review 明确允许 release
