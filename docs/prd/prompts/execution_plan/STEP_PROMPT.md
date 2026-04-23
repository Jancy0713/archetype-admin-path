# Execution Plan Step Prompt

这个补充 prompt 只服务 `execution_plan`。

## 当前目标

把已确认需求转成明确的推进顺序、依赖关系和 contract 优先级。

## 你必须覆盖

1. `planning_basis`
2. `delivery_strategy`
3. `workstreams`
4. `plan_steps`
5. `contract_priorities`
6. `batching_strategy`
7. `risks_and_watchpoints`
8. `decision`

## 当前重点

1. 明确串并行关系，而不是只列任务清单。
2. `plan_steps.step_order` 要形成稳定执行顺序。
3. `contract_priorities` 要能解释为什么某些模块要先进入 contract。
4. `batching_strategy` 要明确哪些内容应该拆成独立 PRD batch，而不是全部塞进一个大 handoff。
5. 如果 `risks_and_watchpoints.blockers` 非空，`decision.allow_final_prd` 必须为 `false`。

## 可选 Skill 参考

如果当前材料同时提供了 `to-prd` skill adapter，可以把它当作“模块拆分 / 深模块草稿器”使用：

1. 借它先草拟 major modules 和深模块边界。
2. 借它识别哪些模块应保持同批、哪些模块适合拆成独立 batch。
3. skill 只能辅助形成 `contract_priorities` 和 `batching_strategy`。
4. 最终只能回填当前 `execution_plan` YAML 结构。

## 额外自检

1. `workstreams.depends_on` 是否真实表达依赖。
2. `handoff_to` 是否让下游知道这一步产出交给谁。
3. `batching_strategy.batches` 是否符合真实耦合关系，而不是机械平均拆分。
4. 不要把未确认业务事实包装成确定排期。
