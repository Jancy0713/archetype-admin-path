# 初始化结构化产物指南

## 目标

这份文档定义项目初始化阶段的结构化产物格式。

当前目标是让 AI 在固定 YAML 框架内填内容，再通过脚本：

1. 生成空白骨架
2. 校验结构和状态
3. 渲染成人类更容易读的 Markdown

## 当前产物类型

当前先覆盖 6 类：

1. `project_profile`
2. `review`
3. `baseline`
4. `design_seed`
5. `bootstrap_plan`
6. `change_request`

## 核心变化

`project_profile` 不再把确认项拆成多套结构。

当前统一规则是：

- 当前阶段所有需要人工确认的内容，都写进 `confirmation_items`
- 每个确认项使用统一字段结构
- 只通过 `level` 区分展示优先级，而不是拆成不同数据源

`level` 只允许：

- `secondary`：当前按推荐收敛，如需可改
- `primary`：需要用户重点拍板
- `required`：必须人工明确回复，否则不能推进

## `project_profile` 规则

每个阶段都必须保留固定 `confirmation_items` 骨架。

固定骨架就是这些 `item_id`：

- `foundation_context`
  - `system_type`
  - `audience_type`
  - `default_region`
  - `default_language`
  - `primary_clients`
  - `core_usage_scenario`
- `tenant_governance`
  - `tenant_model`
  - `tenant_subject`
  - `platform_tenant_layers`
  - `org_structure_needed`
  - `org_structure_purpose`
  - `governance_boundary`
- `identity_access`
  - `login_method`
  - `account_identifier`
  - `account_system`
  - `cross_tenant_account`
  - `permission_model`
  - `privileged_roles`
  - `member_permission_basis`
- `experience_platform`
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

每个 `confirmation_item` 统一包含：

- `item_id`
- `question`
- `level`
- `answer_mode`
- `recommended`
- `options`
- `reason`
- `allow_custom_answer`
- `default_if_no_answer`

建议：

- 优先用 `answer_mode: single_choice`
- 需要多选时再用 `multi_choice`
- 只有确实无法结构化时才用 `text`
- 同一件事只出现一次，不要拆成 `secondary + primary` 两遍
- 如果是 `ui_style_recipe`，优先写成“顾问式推荐”，即：
  - `recommended` 给明确主推方案
  - `reason` 解释为什么适合当前系统
  - `options[].description` 提供简短风格预览，而不是只写抽象标签

结构示例：

```yaml
confirmation_items:
  - item_id: ui_style_recipe
    question: 整个系统的 UI 风格方案采用什么方向？
    level: primary
    answer_mode: single_choice
    recommended: flat_minimal_ai_native
    options:
      - value: flat_minimal_ai_native
        label: Flat Design + Minimalism + AI-Native UI
        description: 浅色主界面、规整卡片和表格为主，参数区与结果区明确分栏，整体更像专业 AI 工作台。
      - value: data_dense_minimal
        label: Data-Dense + Heat Map & Heatmap + Minimalism
        description: 首页更偏指标看板和任务概览，图表、筛选器和状态表达权重更高。
      - value: glass_flat
        label: Glassmorphism + Flat Design
        description: 后台结构保持清晰，但在概览卡和弹窗里加入轻毛玻璃和层叠感，观感更现代 SaaS。
    reason: UI 风格会直接影响后续页面布局、色彩体系、组件风格和交互节奏，不应只问深浅色；推荐项应优先复用 UI/UX Pro Max 的现成风格组合。
    allow_custom_answer: true
    default_if_no_answer: flat_minimal_ai_native
  - item_id: theme_mode
    question: 主题模式是什么？
    level: secondary
    answer_mode: single_choice
    recommended: light
    options:
      - value: light
        label: 浅色主题为默认
        description: 更适合商家后台日常办公使用。
      - value: dual
        label: 浅深双主题
        description: 首版即支持主题切换。
    reason: 商家后台以白天办公和高频列表操作为主，浅色默认更稳妥。
    allow_custom_answer: true
    default_if_no_answer: light
  - item_id: platform_capability_floor
    question: 首版是否确认把上传、导出、站内通知、审计日志作为平台能力底座？
    level: primary
    answer_mode: single_choice
    recommended: all_four
    options:
      - value: all_four
        label: 四项都纳入首版底座
        description: 上传、导出、站内通知、审计日志都进入首版。
      - value: upload_and_export
        label: 仅保留上传和导出
        description: 通知与审计日志暂缓。
    reason: 这会直接影响后续页面框架与任务流设计。
    allow_custom_answer: true
    default_if_no_answer: ""
```

## `baseline` 规则

`baseline` 的核心字段仍然是：

- `project_summary`
- `identity_access`
- `ui_foundation`
- `platform_defaults`

其中 `ui_foundation` 建议至少覆盖：

- `visual_direction`
- `style_recipe`
- `theme_mode`
- `density`
- `navigation_style`

其中 `style_recipe` 建议写成后续团队可以直接继承的完整句式，例如：

- `Flat Design + Minimalism + AI-Native UI，浅色主界面，参数区与结果区分栏，局部保留轻量数据看板卡片。`

如果 baseline 关口仍需要人工确认，也统一写进 `confirmation_items`，结构与 `project_profile` 一致。

同时继续保留 `field_sources` 追踪来源。

来源追踪建议只用这几类：

- `confirmation_item`
- `project_profile_field`
- `stage_summary`

## `design_seed` 规则

`design_seed` 用于把已经确认的风格方向自动收敛成后续默认继承的设计约束。

建议至少包含：

- `design_context`
- `theme_strategy`
- `token_baseline`
- `layout_principles`

补充要求：

- 具体 token 数值不要求用户逐项确认
- 这一步应优先基于 baseline 和风格参考自动生成
- `meta.source_paths` 至少应引用 `baseline`

## `bootstrap_plan` 规则

`bootstrap_plan` 用于明确哪些底座工作应在进入业务 PRD 前先完成。

建议至少包含：

- `init_execution_scope`
- `project_conventions`
- `prd_bootstrap_context`

补充要求：

- `meta.source_paths` 至少应引用 `design_seed`
- `project_conventions` 应以 `design_seed` 为长期规则主来源
- `project_conventions` 应指向一个可长期落在项目仓库内的规则文件
- `project_conventions` 应明确脚本生成骨架、AI 补强与 reviewer 校验的参与方式
- `prd_bootstrap_context` 应清楚承接 `init-01` 到 `init-04` 已确认的项目基础前提，但它不是项目内长期规则文件
- `prd_bootstrap_context` 更像交给下一轮 `prd` 的基础 PRD 初稿，应优先覆盖：
  - 项目概况
  - 登录 / 账号 / 租户 / 权限等基础前提
  - 框架型组件基础
  - 平台通用能力组件基础
  - 基础模块需求
  - 本轮 PRD 关注点
- `prd_bootstrap_context` 应采用“脚本先产骨架，AI 再补强，reviewer 再检查边界”的模式
- `prd_bootstrap_context` 不应提前带入任何具体业务功能前提
- 这一步结尾需要人工确认

## 渲染目标

`project_profile.md` 面向人工确认，结构应聚焦当前阶段：

- 项目概览
- 当前阶段结论
- 重点确认项
- 次要确认项
- 必须明确回复的问题

`baseline.md` 面向基线定稿，默认只展示：

- 本次定稿内容
- 收敛依据
- 对后续阶段的默认约束

`design_seed.md` 面向设计约束沉淀，默认只展示：

- 设计约束基线

`bootstrap_plan.md` 面向初始化计划确认，默认只展示：

- 初始化底座计划
- 人工确认方式

## 当前限制

这仍然是第一版统一结构，暂时没有做到：

- 自动从历史 run 迁移旧 schema
- init / prd 共用同一套确认项实现
