# `to-issues` Skill Adapter for PRD Flow

## 目的

这份说明把已安装的外部 skill `to-issues` 适配到当前仓库的 `final_prd` 下游拆分语境里。

skill 路径：

- `/Users/wangwenjie/.agents/skills/to-issues/SKILL.md`

## 适用范围

当前只允许把它当作下面阶段的后置辅助参考：

1. `final_prd`
2. `final_prd_ready` 之后的 issue 拆分准备

## 允许借用的能力

### 在 `final_prd`

可以借用：

- 检查 `prd_batches` 是否足够形成独立垂直切片
- 检查 batch 之间的阻塞关系是否清楚
- 为后续 issue 拆分准备更稳定的切片边界

落地要求：

- 当前步骤正式产物仍然只能是 `final_prd` YAML
- 只能辅助校验和细化 `prd_batches` / `contract_execution` 的可拆分性
- 不得用 issue 列表替代 `final_prd`

## 明确禁止

- 不允许反向改写当前 PRD 协议
- 不允许跳过 `final_prd` 直接产 issue 作为主交付
- 不允许忽略现有 batch 依赖、`required_contract_views` 或 `do_not_assume`

## 推荐使用方式

1. 先完成 `final_prd` 的正式结构化收口。
2. 再参考 `to-issues` 的 tracer-bullet 切片思路，检查 batch 是否足够独立、可验证、可并行。
3. 如需后续创建 issue，也应基于当前 `ready_batches` 和依赖顺序展开。

## 输出纪律

- 当前正式产物仍然只有仓库里的结构化 YAML。
- issue 拆分属于 `final_prd` 之后的下游动作，不是当前步骤的替代物。
