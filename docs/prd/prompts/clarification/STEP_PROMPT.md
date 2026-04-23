# Clarification Step Prompt

这个补充 prompt 只服务 `clarification`。

## 当前目标

把真正影响下游推进的问题收敛为可确认、可回写的结构化确认项，并稳定进入 Human Confirmation Gate。

## 你必须覆盖

1. `clarification_context`
2. `confirmation_items`
3. `applied_defaults`
4. `clarified_decisions`
5. `human_confirmation`
6. `decision`

## 当前重点

1. 只保留真正需要用户确认的问题，不重复追问已稳定信息。
2. 能选项化的题目就不要写成开放题。
3. `applied_defaults` 只记录当前明确采用的默认边界，不要偷塞关键业务假设。
4. `human_confirmation.required=true` 且 `confirmed=false` 时，`decision.allow_execution_plan` 必须为 `false`。

## 可选 Skill 参考

如果当前阶段需要更强的追问力度，可以参考 `grill-me` 这类 skill 的思路：

1. 优先逼出隐藏假设、模糊边界和遗漏条件。
2. 重点检查哪些问题如果不问清，会直接影响下游执行顺序或 contract 边界。
3. 不要为了“问得多”而追问；只保留真正值得进入 Human Confirmation Gate 的问题。
4. 最终只能回填当前 `clarification` YAML 结构，不得替代 human gate。

## 额外自检

1. `confirmation_items` 是否适合直接展示给人确认。
2. `confirmation_items.item_id` 是否使用稳定编号格式，例如 `prd-02-01`。
3. `clarified_decisions` 是否为每个 `required` 级问题记录了对应 `item_id`。
4. `clarified_decisions` 是否注明来源，而不是只写结论。
