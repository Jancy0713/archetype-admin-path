# 最终 PRD 规则

## 目标

`final_prd` 是当前进入 `contract` 的唯一正式 PRD 索引输入，但它内部必须拆成多个可独立交接的 `prd_batches`。

## 基本原则

1. 汇总已确认范围，不重开新的分析分支。
2. 不把未确认信息写成既定事实。
3. 只保留真正阻塞 contract 的 `blocking_questions.p0`，不要把已确认延后项写成剩余问题。
4. `prd_batches` 必须按耦合关系、依赖顺序和单批体量限制完成拆分。
5. 每个 ready batch 的 `contract_handoff` 必须明确说明下游能做什么、不能假设什么。
6. 如果某个 batch 允许进入 `contract`，它的 `contract_scope`、`priority_modules`、`required_contract_views`、`do_not_assume` 都必须非空。

## 正确产出

至少应包含：

1. overview
2. scope
3. roles and permissions
4. domain model
5. experience design
6. workflow design
7. constraints
8. blocking questions
9. contract execution
10. prd batches

## 进入 contract 的条件

只有当：

- `decision.allow_contract_design=true`
- `blocking_questions.p0` 为空
- `decision.ready_batches` 非空
- 每个 `ready_batches` 对应的 `prd_batches[*].contract_handoff.contract_scope` 非空
- 每个 `ready_batches` 对应的 `prd_batches[*].contract_handoff.priority_modules` 非空
- 每个 `ready_batches` 对应的 `prd_batches[*].contract_handoff.required_contract_views` 非空
- 每个 `ready_batches` 对应的 `prd_batches[*].contract_handoff.do_not_assume` 非空

才允许进入 contract。
