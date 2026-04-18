# 初始化基线规则

## 目标

这一步用于把已经澄清过的项目画像整理成一个统一的系统基线。

后续普通功能流程默认继承这份基线。

## 正确产出

至少应包含：

1. 项目画像摘要
2. 地区与语言基线
3. 登录与账号基线
4. 权限与租户基线
5. UI 风格与主题基线
6. 通用平台能力基线
7. 仍待确认的问题

## 基本原则

1. 只整理已经有依据的基线，不虚构系统级决策。
2. 关键基线问题要显式列出，不要埋在长描述里。
3. 常规默认值可以保留，但要说明升级条件。
4. 后续普通功能若与基线冲突，应走初始化变更流程。
5. 只允许使用已确认阶段的内容，不允许从未确认阶段取值。
6. 每个正式写入的 baseline 字段都应记录可追踪来源。

## 输入映射规则

`baseline` 不是自由发挥，而是从已确认的 `project_profile` 收敛出来。

建议按下面优先级取值：

1. 优先使用对应阶段里已确认的 `key_decisions`
2. 若该字段没有明确决策，再使用对应阶段的 `recommended_defaults`
3. 若仍没有结构化值，再谨慎参考该阶段 `summary`
4. 若来源阶段未确认，不得写入正式 baseline

## 字段来源追踪

`baseline` 里的核心字段不仅要有值，还要能追溯来源。

建议做法：

- 保留原有值结构，供后续流程直接消费
- 额外维护 `field_sources`
- `field_sources` 的字段路径应与下面几组核心基线字段一一对应：
  - `project_summary`
  - `identity_access`
  - `ui_foundation`
  - `platform_defaults`

每个来源记录应至少包含：

- `stage_id`
- `source_type`
- `source_id`
- `note`

推荐的 `source_type`：

- `required_question`
- `adaptive_question`
- `key_decision`
- `recommended_default`
- `project_profile_field`
- `stage_summary`

使用原则：

1. 如果某个 baseline 字段有正式值，就应有正式来源。
2. 优先记录最直接的结构化来源，不要只写模糊说明。
3. 如果来自阶段固定题，`source_id` 应对应 `question_id`。
4. 如果来自关键决策，`source_id` 应对应 `key_decisions.topic`。
5. 如果来自推荐默认值，`source_id` 应对应 `recommended_defaults.topic`。
6. 只有在确实没有更直接的结构化来源时，才退回 `project_profile_field` 或 `stage_summary`。

建议映射关系：

1. `baseline.project_summary`
   - 主要来自 `project_profile.project_summary`
   - 补充参考 `foundation_context` 已确认结论
   - 对应来源写入 `field_sources.project_summary.*`
2. `baseline.identity_access`
   - 主要来自 `identity_access`
   - `tenant_model` 可从 `tenant_governance` 已确认结果继承
   - 对应来源写入 `field_sources.identity_access.*`
3. `baseline.ui_foundation`
   - 主要来自 `experience_platform`
   - 对应来源写入 `field_sources.ui_foundation.*`
4. `baseline.platform_defaults`
   - 主要来自 `experience_platform`
   - 对应来源写入 `field_sources.platform_defaults.*`
5. `baseline.key_decisions`
   - 应收录仍需要人在 baseline 关口再次确认的关键结论
6. `baseline.recommended_defaults`
   - 应收录可以直接沿用的已确认默认值

## 进入条件

出现下面任一情况，不应生成正式 baseline：

- `project_profile.stage_progress.profile_ready` 不是 `true`
- 任一阶段 `confirmation.confirmed` 不是 `true`
- 任一阶段仍有 `p0`
- 需要写入 baseline 的字段只能从未确认阶段推断
