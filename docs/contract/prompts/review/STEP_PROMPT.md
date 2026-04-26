# Contract Step Prompt: review

当前步骤：`contract-04 review`

## 目标

对当前 flow 的 `contract_spec` 做独立审查；review 通过后，才允许生成正式 release 包。

## 必读材料

1. [REVIEWER_PROMPT.md](/Users/wangwenjie/project/archetype-admin-path/docs/contract/prompts/REVIEWER_PROMPT.md)
2. [review.template.yaml](/Users/wangwenjie/project/archetype-admin-path/docs/contract/templates/structured/review.template.yaml)
3. [REVIEWER_WORKFLOW.md](/Users/wangwenjie/project/archetype-admin-path/docs/contract/reviewer/common/REVIEWER_WORKFLOW.md)
4. [contract_spec_ready checklist](/Users/wangwenjie/project/archetype-admin-path/docs/contract/reviewer/checklists/contract_spec_ready.md)

## 这一步必须完成

1. reviewer 必须由独立 reviewer 子 agent 执行；这不是人工 review，也不能由当前主 agent 自审。
2. reviewer 只审查，不重写正文。
3. reviewer 必须明确 blocking issue、返工落点和是否允许 release。
4. 只有 review 明确通过后，才生成 `contract/release/` 下的正式交付。
5. release 包必须记录 review 来源和正式输入边界。

## 这一步不能做

1. 主 agent 不得兼任 reviewer。
2. 不把 review 和 release 产物混成一个 YAML。
3. 不在 review 里脑补缺失的关键业务事实。

## 输出要求

1. reviewer 输出 `review` YAML。
2. review 通过后，主流程再输出 `openapi.yaml`、`openapi.summary.md`、`develop-handoff.md`。
3. 正式交付必须保持 `contract_id` 可追踪。
