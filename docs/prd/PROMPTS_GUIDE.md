# PRD 2.1 Prompt 指南

## 当前流程

当前 prompt 组合围绕 4 个正式步骤，并按“通用 + 分步骤补充”组织：

1. `analysis`
2. `clarification`
3. `execution_plan`
4. `final_prd`

reviewer 可在每一步后启用。

推荐入口：

1. [prompt 索引](/Users/wangwenjie/project/archetype-admin-path/docs/prd/prompts/README.md)
2. [步骤材料索引](/Users/wangwenjie/project/archetype-admin-path/docs/prd/steps/README.md)

## 最小执行顺序

1. 用 `scripts/prd/init_artifact.rb` 初始化当前 YAML 骨架
2. 把输入材料、规则文档和模板交给主模型
3. 用 [MASTER_PROMPT.md](/Users/wangwenjie/project/archetype-admin-path/docs/prd/prompts/MASTER_PROMPT.md) + 当前步骤 `STEP_PROMPT.md` 生成主产物
4. 运行 `validate_artifact.rb`
5. 脚本失败直接返工，不进入 reviewer
6. 脚本通过后，再初始化 `review.yaml`
7. 用 [REVIEWER_PROMPT.md](/Users/wangwenjie/project/archetype-admin-path/docs/prd/prompts/REVIEWER_PROMPT.md) + 当前阶段 reviewer checklist 生成 reviewer 结果
8. 超过 retry 上限后升级给人
9. `clarification` 通过后必须走 Human Confirmation Gate
10. `final_prd` 通过后先生成 `contract_handoff`，再从单个 flow handoff 进入 contract

## 当前注意事项

1. YAML 是唯一主输出。
2. Markdown 只是展示层。
3. `clarification` 默认必须人工确认。
4. `final_prd` 是当前生成 `contract_handoff` 的唯一正式输入；后续 contract 默认消费单个 flow handoff。
5. reviewer 必须由独立 reviewer 子 agent 或独立新上下文执行，主 agent 不得自己兼任 reviewer。

## 当前 prompt 组织

### 主模型

- 通用主 prompt：
  [MASTER_PROMPT.md](/Users/wangwenjie/project/archetype-admin-path/docs/prd/prompts/MASTER_PROMPT.md)
- 分步骤补充：
  - [analysis](/Users/wangwenjie/project/archetype-admin-path/docs/prd/prompts/analysis/STEP_PROMPT.md)
  - [clarification](/Users/wangwenjie/project/archetype-admin-path/docs/prd/prompts/clarification/STEP_PROMPT.md)
  - [execution_plan](/Users/wangwenjie/project/archetype-admin-path/docs/prd/prompts/execution_plan/STEP_PROMPT.md)
  - [final_prd](/Users/wangwenjie/project/archetype-admin-path/docs/prd/prompts/final_prd/STEP_PROMPT.md)

### reviewer

- 通用 reviewer prompt：
  [REVIEWER_PROMPT.md](/Users/wangwenjie/project/archetype-admin-path/docs/prd/prompts/REVIEWER_PROMPT.md)
- reviewer 材料入口：
  [reviewer/README.md](/Users/wangwenjie/project/archetype-admin-path/docs/prd/reviewer/README.md)
