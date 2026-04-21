# Profile Execution Checklist

覆盖 `init-01` 到 `init-04`。

## 主模型输入

- 用户的一句话描述 / 项目背景 / 整份 PRD
- [MASTER_PROMPT.md](/Users/wangwenjie/project/archetype-admin-path/docs/init/prompts/MASTER_PROMPT.md)
- [rules/PROJECT_PROFILE_RULE.md](/Users/wangwenjie/project/archetype-admin-path/docs/init/rules/PROJECT_PROFILE_RULE.md)
- [templates/structured/project_profile.template.yaml](/Users/wangwenjie/project/archetype-admin-path/docs/init/templates/structured/project_profile.template.yaml)
- [references/UI_UX_PRO_MAX_STYLE_REFERENCE.md](/Users/wangwenjie/project/archetype-admin-path/docs/init/references/UI_UX_PRO_MAX_STYLE_REFERENCE.md)

## 执行步骤

1. 初始化当前阶段画像：
   - `ruby scripts/init/profile/init_project_profile_step.rb <run_dir> <init-01|init-02|init-03|init-04>`
2. 填写或修正当前 `project_profile` YAML
3. 校验并渲染当前阶段：
   - `ruby scripts/init/profile/render_project_profile_step.rb <run_dir> <init-01|init-02|init-03|init-04>`
4. 初始化 reviewer：
   - `ruby scripts/init/profile/init_project_profile_review.rb <run_dir> <init-01|init-02|init-03|init-04>`
5. 完成 reviewer 审查
6. 进入当前阶段 Human Confirmation Gate

## 检查点

- 是否先抽项目画像摘要，再进入分阶段确认
- 是否明确 `current_stage`、`completed_stages`、`remaining_stages`
- 是否只展开当前阶段，而不是一次性展开所有阶段
- 是否按阶段递进确认：
  - 第一阶段：地区、语言、系统类型、主要使用端
  - 第二阶段：租户模型、平台级 / 租户级管理结构
  - 第三阶段：登录方式、账号体系、权限模型
  - 第四阶段：UI 风格方案、主题、通用平台能力
- 是否只在当前阶段填写有效的 `confirmation_items`
- 未进入阶段是否只保留固定题骨架，而不是提前填写正式结论或扩成大题库
- reviewer 是否填写了 `current_stage_review.checklist`
- checklist 是否覆盖了当前阶段全部专项检查项

## 通过条件

- 当前阶段 reviewer 已通过
- 当前阶段人工确认已回填到 `confirmation`
- 下一阶段才允许转成 `in_progress`
