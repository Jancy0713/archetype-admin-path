# 执行清单

## 目标

这份清单用于实际跑一轮 PRD 拆解流程时，防止遗漏步骤。

## Step 1：需求补充提问

主模型输入：

- 原始 PRD / 原型 / 简述
- [MASTER_PROMPT.md](/Users/wangwenjie/project/archetype-admin-path/docs/prd/prompts/MASTER_PROMPT.md)
- [rules/REQUIREMENT_CLARIFICATION_RULE.md](/Users/wangwenjie/project/archetype-admin-path/docs/prd/rules/REQUIREMENT_CLARIFICATION_RULE.md)
- [templates/structured/clarification.template.yaml](/Users/wangwenjie/project/archetype-admin-path/docs/prd/templates/structured/clarification.template.yaml)

检查点：

- 是否已经列出缺口
- 是否已经提出补问问题
- 是否已经标出 P0
- 是否只输出 YAML，没有自由 Markdown
- 是否优先使用 `decision_candidates` 和 `proposed_defaults`，而不是抛一堆开放题

## Step 2：Reviewer 审查补问结果

reviewer 输入：

- 主模型输出
- 已通过：
  - `ruby scripts/prd/validate_artifact.rb clarification path/to/clarification.yaml`
- [REVIEWER_PROMPT.md](/Users/wangwenjie/project/archetype-admin-path/docs/prd/prompts/REVIEWER_PROMPT.md)
- [rules/REVIEWER_RULE.md](/Users/wangwenjie/project/archetype-admin-path/docs/prd/rules/REVIEWER_RULE.md)
- [templates/structured/review.template.yaml](/Users/wangwenjie/project/archetype-admin-path/docs/prd/templates/structured/review.template.yaml)
- 建议先执行：
  - `ruby scripts/prd/init_artifact.rb --step requirement_clarification review path/to/review.yaml`

检查点：

- 是否漏掉关键问题域
- 是否过早默认业务边界
- 是否允许进入 brief
- `meta.subject_path` 是否指向当前被审的 clarification YAML
- 当前审查是否聚焦内容而不是重复脚本已覆盖的格式问题

## Step 3：澄清版 Brief

主模型输入：

- 已补充后的关键信息
- [MASTER_PROMPT.md](/Users/wangwenjie/project/archetype-admin-path/docs/prd/prompts/MASTER_PROMPT.md)
- [templates/structured/brief.template.yaml](/Users/wangwenjie/project/archetype-admin-path/docs/prd/templates/structured/brief.template.yaml)

检查点：

- 是否固定了当前共识
- 是否把待确认项独立列出
- 是否只填写 YAML 模板，不写额外说明
- 是否已经通过：
  - `ruby scripts/prd/validate_artifact.rb brief path/to/brief.yaml`
- 是否沉淀了关键决策候选项和可沿用默认值

## Step 4：PRD 结构化拆解

主模型输入：

- 澄清版 brief
- [MASTER_PROMPT.md](/Users/wangwenjie/project/archetype-admin-path/docs/prd/prompts/MASTER_PROMPT.md)
- [rules/PRD_DECOMPOSITION_RULE.md](/Users/wangwenjie/project/archetype-admin-path/docs/prd/rules/PRD_DECOMPOSITION_RULE.md)
- [templates/structured/decomposition.template.yaml](/Users/wangwenjie/project/archetype-admin-path/docs/prd/templates/structured/decomposition.template.yaml)

检查点：

- 是否拆出了模块、页面、角色、资源、流程、状态
- 是否独立列出了待确认项
- 是否只输出 YAML，没有自由 Markdown

## Step 5：Reviewer 审查结构化拆解

reviewer 输入：

- 结构化拆解结果
- 已通过：
  - `ruby scripts/prd/validate_artifact.rb decomposition path/to/decomposition.yaml`
- [REVIEWER_PROMPT.md](/Users/wangwenjie/project/archetype-admin-path/docs/prd/prompts/REVIEWER_PROMPT.md)
- [rules/REVIEWER_RULE.md](/Users/wangwenjie/project/archetype-admin-path/docs/prd/rules/REVIEWER_RULE.md)
- [templates/structured/review.template.yaml](/Users/wangwenjie/project/archetype-admin-path/docs/prd/templates/structured/review.template.yaml)
- 建议先执行：
  - `ruby scripts/prd/init_artifact.rb --step prd_decomposition review path/to/review.yaml`

检查点：

- 是否有 P0 阻塞
- 是否可以进入 contract
- 是否超过 retry 上限
- `meta.subject_path` 是否指向当前被审的 decomposition YAML
- 当前审查是否聚焦内容而不是重复脚本已覆盖的格式问题

## Retry 规则

- 每个关口最大 retry：`2`
- 超过后必须升级给人

## 当前执行约束

- AI 主输出一律为 YAML
- Markdown 只作为渲染结果给人看，不作为模型主产物
- 每次主模型产出后必须先运行：
  - `ruby scripts/prd/validate_artifact.rb <type> <artifact.yml>`
- 脚本校验失败时，不进入 reviewer，直接返工修正 YAML
- `brief` 必须至少引用一个 `clarification` 产物
- `decomposition` 必须至少引用一个 `brief` 产物
- `review` 必须指向与当前关口一致的被审 YAML
