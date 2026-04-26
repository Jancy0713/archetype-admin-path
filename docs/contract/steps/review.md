# Step: review

## 材料

1. [step prompt](/Users/wangwenjie/project/archetype-admin-path/docs/contract/prompts/review/STEP_PROMPT.md)
2. [reviewer prompt](/Users/wangwenjie/project/archetype-admin-path/docs/contract/prompts/REVIEWER_PROMPT.md)
3. [reviewer README](/Users/wangwenjie/project/archetype-admin-path/docs/contract/reviewer/README.md)
4. [reviewer workflow](/Users/wangwenjie/project/archetype-admin-path/docs/contract/reviewer/common/REVIEWER_WORKFLOW.md)
5. [contract_spec_ready checklist](/Users/wangwenjie/project/archetype-admin-path/docs/contract/reviewer/checklists/contract_spec_ready.md)
6. [review template](/Users/wangwenjie/project/archetype-admin-path/docs/contract/templates/structured/review.template.yaml)

## 目标

完成独立审查，并在通过后触发 release 包生成，使当前 flow 成为正式可消费版本。

## 输入

1. 当前 flow 的 `contract_spec`
2. 对应的 `scope_intake` 与 `domain_mapping`
3. 当前 flow 的 `intake/contract-handoff.snapshot.yaml`

## 输出

1. `contract-04.review.yaml`
2. review 通过后生成的 `contract/release/openapi.yaml`
3. `contract/release/openapi.summary.md`
4. `contract/release/develop-handoff.md`
5. `state/contract-04.review-result.yaml`

## 当前门禁方式

1. reviewer 必须由独立 reviewer 子 agent 执行；这不是人工 review
2. 主 agent 不得自己兼任 reviewer
3. 只有 `review.decision.allow_release=true` 才允许生成 release 包
4. `review_complete.rb` 必须校验当前 review 与 subject 都属于本 flow run，并把 pass / block 结果写入 run 内 state snapshot
