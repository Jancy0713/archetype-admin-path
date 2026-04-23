# Reviewer Checklist: prd_execution_plan

## 必查项

1. `workstreams` 是否表达了可执行的工作流拆分。
2. `plan_steps` 是否具备清楚的排序、输入、输出和依赖关系。
3. `contract_priorities` 是否能指导下游先做什么。
4. `risks_and_watchpoints.blockers` 是否真实阻塞 `final_prd`。
5. 是否把未确认事实伪装成已确定推进顺序。

## 放行标准

只有当下面条件成立，才允许进入 `final_prd`：

1. 当前计划可以真实指导下游推进，而不是形式步骤。
2. 关键依赖没有遗漏。
3. `decision.allow_final_prd=true` 与风险状态一致。
