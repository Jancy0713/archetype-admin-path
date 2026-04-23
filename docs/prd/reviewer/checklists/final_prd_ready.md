# Reviewer Checklist: final_prd_ready

## 必查项

1. `overview / scope / roles_and_permissions / domain_model / workflow_design / prd_batches` 是否互相一致。
2. `blocking_questions.p0` 是否为空，是否还遗漏 contract 前必须解决的问题。
3. `prd_batches` 的拆分是否符合耦合关系和体量控制，而不是机械平均拆分。
4. 每个 ready batch 的 `contract_handoff.contract_scope`、`priority_modules`、`required_contract_views` 是否足够交接。
5. 每个 ready batch 的 `contract_handoff.do_not_assume` 是否拦住了下游越界假设。
6. 是否仍然存在关键事实缺失却被写成既定结论的情况。
7. 如果允许进入 contract，ready batch 的四个 handoff 列表是否都非空且没有重复项。

## 放行标准

只有当下面条件成立，才允许进入 `contract`：

1. `final_prd` 已经成为当前唯一可信输入索引，且 batch 拆分足够支撑下游逐批进入 contract。
2. reviewer 没有识别 blocking issue。
3. `decision.allow_contract_design=true` 与 `blocking_questions` / `ready_batches` 状态一致。
