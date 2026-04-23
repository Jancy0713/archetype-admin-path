# Reviewer Checklist: prd_clarification

## 必查项

1. `confirmation_items` 是否只保留真正需要人确认的问题。
2. `confirmation_items.item_id` 是否使用稳定编号格式，例如 `prd-02-01`，便于用户按编号回复。
3. 题型、推荐项、默认值是否适合直接进入 Human Confirmation Gate。
4. `applied_defaults` 是否越界补全了关键业务事实。
5. `clarified_decisions` 是否为每个 `required` 级问题记录了对应 `item_id`。
6. `human_confirmation` 状态是否与实际推进状态一致。

## 放行标准

只有当下面条件成立，才允许进入 `execution_plan`：

1. reviewer 没有识别新的 blocking issue。
2. `human_confirmation.required=true` 时，确认状态已经真实完成。
3. `decision.allow_execution_plan=true` 不是误放行。
4. 所有 `required` 级确认项都已被明确收口，不再依赖额外的旧字段兜底。
