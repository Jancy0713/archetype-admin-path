# 执行清单

## Step 1：项目画像

主模型输入：

- 用户的一句话描述 / 项目背景 / 整份 PRD
- [MASTER_PROMPT.md](/Users/wangwenjie/project/archetype-admin-path/docs/init/prompts/MASTER_PROMPT.md)
- [rules/PROJECT_PROFILE_RULE.md](/Users/wangwenjie/project/archetype-admin-path/docs/init/rules/PROJECT_PROFILE_RULE.md)
- [templates/structured/project_profile.template.yaml](/Users/wangwenjie/project/archetype-admin-path/docs/init/templates/structured/project_profile.template.yaml)

检查点：

- 是否先抽项目画像摘要，再进入分阶段确认
- 是否明确 `current_stage`、`completed_stages`、`remaining_stages`
- 是否只展开当前阶段，而不是一次性展开所有阶段
- 是否按阶段递进确认：
  - 第一阶段：地区、语言、系统类型、主要使用端
  - 第二阶段：租户模型、平台级 / 租户级管理结构
  - 第三阶段：登录方式、账号体系、权限模型
  - 第四阶段：UI 风格、主题、通用平台能力
- 是否只在当前阶段填写 `key_decisions` 和 `recommended_defaults`
- 未进入阶段是否只保留固定题骨架，而不是提前填写正式结论或扩成大题库

## Step 2：Reviewer 审查项目画像

reviewer 输入：

- 已通过：
  - `ruby scripts/init/validate_artifact.rb project_profile path/to/project_profile.yaml`
- [REVIEWER_PROMPT.md](/Users/wangwenjie/project/archetype-admin-path/docs/init/prompts/REVIEWER_PROMPT.md)
- [rules/REVIEWER_RULE.md](/Users/wangwenjie/project/archetype-admin-path/docs/init/rules/REVIEWER_RULE.md)
- [templates/structured/review.template.yaml](/Users/wangwenjie/project/archetype-admin-path/docs/init/templates/structured/review.template.yaml)
- 建议先执行：
  - `ruby scripts/init/init_artifact.rb --step project_initialization review path/to/review.yaml`

检查点：

- 是否抓准项目类型
- 是否阶段划分合理，推进顺序清晰
- 是否优先确认了高优先级阶段
- 是否把关键问题错误地下沉成默认值
- 是否提供了足够清晰的推荐项和短解释
- 是否错误地把后续阶段扩成了完整题库
- 是否填写了 `current_stage_review.checklist`
- checklist 是否覆盖了当前阶段全部专项检查项

阶段通过后，还应有人执行：

- 当前阶段 Human Confirmation Gate
- 只有确认结果回填到 `confirmation` 后，才允许把下一阶段转成 `in_progress`

## Step 3：初始化基线

主模型输入：

- 已通过且已完成阶段确认的项目画像
- [MASTER_PROMPT.md](/Users/wangwenjie/project/archetype-admin-path/docs/init/prompts/MASTER_PROMPT.md)
- [rules/BASELINE_RULE.md](/Users/wangwenjie/project/archetype-admin-path/docs/init/rules/BASELINE_RULE.md)
- [templates/structured/baseline.template.yaml](/Users/wangwenjie/project/archetype-admin-path/docs/init/templates/structured/baseline.template.yaml)

检查点：

- 是否沉淀成统一基线
- 是否保留仍待确认的关键问题
- 是否已经通过：
  - `ruby scripts/init/validate_artifact.rb baseline path/to/baseline.yaml`

## Step 4：初始化变更

- 需要修改系统基座时，使用 [change_request.template.yaml](/Users/wangwenjie/project/archetype-admin-path/docs/init/templates/structured/change_request.template.yaml)

## 当前执行约束

- AI 主输出一律为 YAML
- Markdown 只作为渲染结果给人看
- 每次主模型产出后必须先运行：
  - `ruby scripts/init/validate_artifact.rb <type> <artifact.yml>`
- 脚本校验失败时，不进入 reviewer，直接返工修正 YAML
- `project_profile` 默认按多阶段多轮更新同一个 YAML，而不是一次性填满
- 每个阶段都必须单独经过：AI 产出 -> 脚本校验 -> reviewer -> Human Confirmation Gate
