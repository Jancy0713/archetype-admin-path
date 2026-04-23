# Reviewer 规则

## 目标

Reviewer 在 `PRD 2.0` 中负责：

1. 找遗漏
2. 找矛盾
3. 判断是否允许进入下一步

Reviewer 不负责重写正文。

## 当前适用关口

当前允许审查：

1. `prd_analysis`
2. `prd_clarification`
3. `prd_execution_plan`
4. `final_prd_ready`

## 各关口重点

### prd_analysis

- 输入理解是否失真
- 范围拆分是否合理
- 是否识别了真实阻塞缺口
- 是否已经准备好进入 clarification

### prd_clarification

- 是否只保留真正待确认的问题
- `confirmation_items` 是否结构化、可确认
- 是否错误放行未完成的人工确认

### prd_execution_plan

- 推进顺序是否清楚
- 依赖关系是否合理
- 是否错误忽略关键阻塞

### final_prd_ready

- 是否足够交给 contract
- 是否还有 P0 未解问题
- `prd_batches` 的拆分是否合理
- ready batch 的 `contract_handoff` 是否清楚表达下游边界

## 输出要求

Reviewer 输出必须是结构化 YAML，并显式给出：

- `findings`
- `decision.has_blocking_issue`
- `decision.allow_next_step`
- `decision.need_human_escalation`
- `required_revisions`
