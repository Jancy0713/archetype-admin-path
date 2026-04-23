# 需求澄清规则

## 目标

`clarification` 的职责是把真正不确定、且会影响后续 `execution_plan / final_prd / contract` 的问题收敛出来，并通过人工确认稳定下来。

## 基本原则

1. 只问真正影响后续推进的问题。
2. 所有需要用户确认的内容统一进入 `confirmation_items`。
3. 能结构化的问题，不写成开放题。
4. 已足够明确的信息不重复追问。
5. 未经人工确认，不进入 `execution_plan`。

## 当前协议要求

### `confirmation_items`

统一字段：

- `item_id`
- `question`
- `level`
- `answer_mode`
- `recommended`
- `options`
- `reason`
- `allow_custom_answer`
- `default_if_no_answer`

### 等级

- `secondary`
- `primary`
- `required`

### answer_mode

- `boolean`
- `single_choice`
- `multiple_choice`
- `open_text`

## 正确产出

至少应包含：

1. 当前澄清上下文
2. `confirmation_items`
3. 已采用默认值
4. 已明确决策
5. `human_confirmation`
6. 是否允许进入 `execution_plan`

补充约束：

- `confirmation_items.item_id` 应使用稳定编号，例如 `prd-02-01`
- `required` 级确认项在确认完成后，应在 `clarified_decisions` 中按 `item_id` 留下对应收口结果

## 停止推进条件

出现以下任一情况，不得进入下一步：

- `human_confirmation.required=true` 且 `confirmed=false`
- 存在 `required` 级确认项，但还没有对应的 `clarified_decisions.item_id`
- 关键边界仍然模糊
