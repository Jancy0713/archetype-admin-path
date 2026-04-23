# Final PRD Step Prompt

这个补充 prompt 只服务 `final_prd`。

## 当前目标

把已确认范围和执行结论收敛成当前唯一可信的 contract 输入索引，并拆成多个可独立进入 contract 的 PRD batch。

## 你必须覆盖

1. `overview`
2. `scope`
3. `roles_and_permissions`
4. `domain_model`
5. `experience_design`
6. `workflow_design`
7. `constraints`
8. `blocking_questions`
9. `contract_execution`
10. `prd_batches`
11. `decision`

## 当前重点

1. 只汇总已确认信息，不重新打开新的分析分支。
2. 只把真正阻塞 contract 的问题写进 `blocking_questions.p0`；已经确认“不做/延后”的内容不得再写成 P1/P2 问题。
3. `prd_batches` 要按功能耦合、共享页面、共享对象和依赖顺序分组，避免形成一个超大 PRD。
4. 每个 batch 的 `contract_handoff` 都要明确“contract 该做什么”和“不能自行假设什么”。
5. `blocking_questions.p0` 非空时，不得放行到 contract。
6. 页面、流程、角色、资源之间要能互相对上，避免只做散点罗列。
7. 如果某个 batch 的 `decision.allow_contract_design=true`，它的 `contract_scope`、`priority_modules`、`required_contract_views`、`do_not_assume` 四个列表都必须填写。

## 可选 Skill 参考

如果当前阶段需要为下游交付继续拆分，可以把 `to-issues` 当作后置辅助器参考：

1. 先用当前 `final_prd` 明确 ready batches，再考虑 issue 拆分。
2. 只把它当作“下游垂直切片建议器”，不要反向改写当前 `final_prd` 协议。
3. issue 拆分必须尊重现有 batch 边界、依赖关系和 `do_not_assume` 约束。
4. 当前步骤的正式产物仍然只有 `final_prd` YAML，不直接输出 issue 列表替代它。

## 额外自检

1. `prd_batches[*].grouped_modules` 是否和 `execution_plan.batching_strategy.batches` 一致。
2. `decision.ready_batches` 是否只包含真正 ready 的 batch。
3. 每个 ready batch 的 `required_contract_views` 是否足够支撑 contract 设计输入。
4. 每个 ready batch 的 `do_not_assume` 是否真的拦住下游越界假设。
