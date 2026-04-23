# `grill-me` Skill Adapter for PRD Flow

## 目的

这份说明把已安装的外部 skill `grill-me` 适配到当前仓库的 `clarification` 协议里。

skill 路径：

- `/Users/wangwenjie/.agents/skills/grill-me/SKILL.md`

## 适用范围

当前只允许把它当作下面阶段的辅助参考：

1. `clarification`
2. `prd_clarification` reviewer 准备

## 允许借用的能力

### 在 `clarification`

可以借用：

- 逼出隐藏假设
- 区分哪些问题真的需要用户确认
- 找出会影响执行顺序、权限边界、contract 边界的问题

落地要求：

- 最终只能回填到 `clarification.confirmation_items`
- 优先把问题收敛为可确认的选项题，而不是开放题
- 不得把 skill 追问过程直接当正式产物保存

## 明确禁止

- 不允许替代 `Human Confirmation Gate`
- 不允许为了追问而追问，把低价值问题塞进 `confirmation_items`
- 不允许替代 reviewer checklist
- 不允许把未确认事实写成 `clarified_decisions`

## 推荐使用方式

1. 先读 `analysis` 产物、当前步骤 rule 和 template。
2. 再用 `grill-me` 的思路检查哪里还存在关键岔路未决。
3. 只保留真正需要人确认的问题。
4. 最后回到当前 YAML 模板，收口 `confirmation_items`、`human_confirmation` 和 `decision`。

## 输出纪律

- 当前正式产物仍然只有仓库里的结构化 YAML。
- `grill-me` 只增强问题质量，不拥有最终决策权。
