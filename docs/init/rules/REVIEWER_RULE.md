# 初始化 Reviewer 规则

## 目标

这份文档定义项目初始化流程中的 reviewer 角色。

## 当前定位

reviewer 不是第二个作者，也不是重新生成一份完整答案的模型。

它的职责只有：

1. 找遗漏
2. 找不合理默认值
3. 判断是否允许进入当前阶段的人类确认
4. 判断是否可以在确认后继续推进下一阶段

## 当前适用关口

当前先在 1 个关口启用：

1. `project_initialization`

## 重点检查内容

- 是否抓准了项目类型
- 是否优先确认了当前阶段对应的高优先级基线
- 是否把本应让用户选择的关键问题错误地下沉成默认值
- 是否给了足够清晰的推荐选项和短解释
- 是否仍存在 P0 阻塞，导致不能进入当前阶段确认
- 是否错误地提前展开了下一阶段

## 当前阶段专项检查项

reviewer 不应只给泛泛结论，而应在 `current_stage_review.checklist` 里逐条检查当前阶段必查项。

### `foundation_context`

- `system_type_clarity`
- `audience_scope_clarity`
- `region_language_grounded`
- `primary_clients_grounded`
- `core_usage_scenario_grounded`
- `recommendations_not_blank_without_reason`
- `no_next_stage_prefill`

### `tenant_governance`

- `tenant_model_clarity`
- `tenant_subject_clarity`
- `platform_tenant_layers_clarity`
- `org_structure_need_clarity`
- `governance_boundary_clarity`
- `recommendations_not_blank_without_reason`
- `no_next_stage_prefill`

### `identity_access`

- `login_method_clarity`
- `account_identifier_clarity`
- `account_system_clarity`
- `cross_tenant_account_clarity`
- `permission_model_clarity`
- `privileged_roles_clarity`
- `recommendations_not_blank_without_reason`
- `no_next_stage_prefill`

### `experience_platform`

- `visual_direction_clarity`
- `ui_style_recipe_clarity`
- `theme_mode_clarity`
- `navigation_style_clarity`
- `information_density_clarity`
- `platform_capabilities_clarity`
- `recommendations_not_blank_without_reason`
- `no_next_stage_prefill`

要求：

- `current_stage_review.stage_id` 必须对应被审 `project_profile` 的当前阶段
- checklist 必须覆盖该阶段全部必查项
- 每项都要给 `passed` 和简短 `note`
