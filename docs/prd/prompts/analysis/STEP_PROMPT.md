# Analysis Step Prompt

这个补充 prompt 只服务 `analysis`。

## 当前目标

把输入先整理成稳定的分析产物，为 `clarification` 提供唯一上游输入。

## 你必须覆盖

1. `input_summary`
2. `scope_analysis`
3. `domain_breakdown.modules`
4. `domain_breakdown.pages`
5. `domain_breakdown.resources`
6. `domain_breakdown.flows`
7. `risk_analysis`
8. `clarification_candidates.confirmation_items`
9. `handoff`

## 当前重点

1. 先表达已知范围和边界，不要先发散方案。
2. 风险、阻塞缺口和待确认问题要分开写，不要混成一段说明。
3. `clarification_candidates.confirmation_items` 只放真正需要后续确认的问题。
4. 如果 `risk_analysis.blocking_gaps.p0` 非空，`handoff.ready_for_clarification` 必须为 `false`。
5. `clarification_candidates.confirmation_items.item_id` 使用稳定编号格式，例如 `prd-01-01`。

## 可选 Skill 参考

如果当前材料同时提供了 `to-prd` skill adapter，可以把它当作“整体需求扩写器”使用：

1. 借它补强问题定义、用户价值和用户故事覆盖面。
2. 借它先草拟 major modules，再收口到 `domain_breakdown`。
3. 不得输出 skill 自己的 Markdown PRD 模板。
4. 最终只能回填当前 `analysis` YAML 结构。

## 额外自检

1. `modules / pages / resources / flows` 至少要能让人看出当前需求的初始结构。
2. 术语第一次出现时，用一句白话说明。
3. 不要把未确认事项提前写成 `clarification` 已完成结论。
