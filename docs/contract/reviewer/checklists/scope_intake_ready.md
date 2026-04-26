# Reviewer Checklist: scope_intake_ready

## 当前用途

这份清单当前用于 `scope_intake` 的规则 + 决策门禁自检材料，不代表已经启用正式 reviewer gate。

## 必查项

1. 当前 `scope_intake` 是否仍然严格限定在目标 batch 范围内。
2. 是否明确写出当前 batch 覆盖什么、不覆盖什么。
3. 是否显式吸收了上游 `contract_handoff.do_not_assume`。
4. 是否明确列出前置 batch、frozen contract 和未满足依赖。
5. 是否只保留真正阻塞进入 `domain_mapping` 的问题，而不是把开放讨论继续带下去。
6. 是否把未确认事实误写成既定范围。

## 放行标准

只有当下面条件成立时，才允许进入 `domain_mapping`：

1. 当前 batch 范围边界清楚。
2. 当前 batch 依赖关系清楚。
3. `do_not_assume` 已被明确吸收。
4. 没有遗漏会直接影响资源映射的阻塞问题。

## 典型阻塞信号

以下情况通常应直接阻塞：

1. 当前 batch 覆盖范围仍然模糊。
2. 前置依赖未标清，无法判断是否可继续。
3. `do_not_assume` 未落进当前结论。
4. 混入其他 batch 内容，导致边界漂移。
