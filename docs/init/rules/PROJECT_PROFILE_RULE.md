# 项目画像规则

## 目标

这一步用于把用户输入的一句话描述、项目背景或整份 PRD 先压成一个系统级画像。

## 基本原则

1. `project_profile` 必须分阶段推进，不再一次性平铺所有初始化问题。
2. 每次只允许 AI 深入当前阶段；已确认阶段保留确认结果，后续阶段只保留固定确认项骨架。
3. 先读整体，再问关键基线，不先钻具体页面。
4. 所有需要人工确认的内容，统一写进当前阶段的 `confirmation_items`。
5. 不再把确认项拆成 `required_questions`、`key_decisions`、`recommended_defaults`、`open_questions` 多套结构。
6. `confirmation_items` 只允许 3 个等级：
   - `secondary`
   - `primary`
   - `required`
7. `secondary` 表示当前按推荐收敛、用户如有异议可改。
8. `primary` 表示真正需要用户重点拍板的问题。
9. `required` 表示用户不答就不能继续推进的问题。
10. 能做成判断题、单选题或多选题的，不要开放提问。
11. 对成熟方案优先给推荐值和备选项。
12. 同一件事只允许在 `confirmation_items` 里出现一次，不要换个说法重复追问。
13. 候选项一般控制在 2-5 个。
14. 即使提供候选项，也要允许用户补充自定义答案。

## 阶段推进规则

每个阶段都必须单独经过下面流程：

1. 主模型产出当前阶段内容
2. 先过脚本校验
3. 再进入 reviewer 审查
4. 人工确认当前阶段
5. 确认后，下一阶段才允许转为 `in_progress`

补充要求：

- 当前阶段之前的阶段必须已经 `confirmed`
- 当前阶段之后的阶段必须保持 `pending`
- 当前阶段固定确认项必须完整出现
- `pending` 阶段不应预填正式结论
- 阶段确认结果写进 `confirmation`
- 只有 4 个阶段全部 `confirmed`，且不存在 `level: required` 的确认项时，才允许 `allow_baseline: true`

## 固定确认项

每个阶段都必须至少保留固定 `item_id` 集合，且顺序不能变：

1. `foundation_context`
   - `system_type`
   - `audience_type`
   - `default_region`
   - `default_language`
   - `primary_clients`
   - `core_usage_scenario`
2. `tenant_governance`
   - `tenant_model`
   - `tenant_subject`
   - `platform_tenant_layers`
   - `org_structure_needed`
   - `org_structure_purpose`
   - `governance_boundary`
3. `identity_access`
   - `login_method`
   - `account_identifier`
   - `account_system`
   - `cross_tenant_account`
   - `permission_model`
   - `privileged_roles`
   - `member_permission_basis`
4. `experience_platform`
   - `visual_direction`
   - `ui_style_recipe`
   - `theme_mode`
   - `navigation_style`
   - `information_density`
   - `notifications_needed`
   - `audit_log_needed`
   - `export_needed`
   - `upload_needed`
   - `i18n_needed`

## 对 AI 的要求

AI 在这一步应：

- 提取系统级画像摘要
- 明确当前阶段、已完成阶段和剩余阶段
- 只展开当前阶段
- 为固定确认项生成推荐值、候选项和简短理由
- 只在必要时新增额外 `confirmation_items`
- 用 `level` 表达确认优先级，而不是额外再拆数据结构

AI 不应：

- 直接开始设计普通业务功能
- 在关键基线问题未确认时擅自拍板复杂架构
- 为后续阶段预先生成大而全的问题清单
- 在当前阶段未人工确认前推进下一阶段
