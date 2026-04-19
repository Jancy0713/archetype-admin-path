# 初始化基线规则

## 目标

这一步用于把已经确认过的项目画像整理成统一的系统基线。

## 正确产出

至少应包含：

1. 项目画像摘要
2. 地区与语言基线
3. 登录与账号基线
4. 权限与租户基线
5. UI 风格与主题基线
6. 通用平台能力基线

其中 UI 基线不应只停留在“深色 / 浅色”层面，至少应能沉淀一份可被后续 PRD、设计与前端继续继承的完整风格方案说明。

## 基本原则

1. 只整理已经有依据的基线，不虚构系统级决策。
2. 后续普通功能若与基线冲突，应走初始化变更流程。
3. 只允许使用已确认阶段的内容，不允许从未确认阶段取值。
4. 每个正式写入的 baseline 字段都应记录可追踪来源。
5. 如果 baseline 关口仍需要人工确认，也统一写进 `confirmation_items`，不要再拆成多套结构。

## 输入映射规则

`baseline` 不是自由发挥，而是从已确认的 `project_profile` 收敛出来。

建议按下面优先级取值：

1. 优先使用已确认阶段里的 `confirmation_items`
2. 若没有直接结构化来源，再谨慎参考该阶段 `summary`
3. 若来源阶段未确认，不得写入正式 baseline

## 字段来源追踪

`baseline` 里的核心字段不仅要有值，还要能追溯来源。

推荐的 `source_type`：

- `confirmation_item`
- `project_profile_field`
- `stage_summary`

使用原则：

1. 如果某个 baseline 字段有正式值，就应有正式来源。
2. 优先记录最直接的结构化来源。
3. 如果来自确认项，`source_id` 应对应 `confirmation_items.item_id`。
4. 只有在确实没有更直接结构化来源时，才退回 `project_profile_field` 或 `stage_summary`。

## 进入条件

出现下面任一情况，不应生成正式 baseline：

- `project_profile.stage_progress.profile_ready` 不是 `true`
- 任一阶段 `confirmation.confirmed` 不是 `true`
- 任一阶段仍存在 `level: required` 的确认项
- 需要写入 baseline 的字段只能从未确认阶段推断
