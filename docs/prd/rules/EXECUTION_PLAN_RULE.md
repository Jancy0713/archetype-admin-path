# 执行计划规则

## 目标

`execution_plan` 负责把已经确认过的需求转成明确的推进顺序。

它不是最终 PRD，也不是 contract 本身。

## 基本原则

1. 重点是先后顺序和依赖关系。
2. 要明确哪些 contract 先做，哪些模块后做。
3. 要明确哪些工作流可以并行，哪些必须串行。
4. 不要把未确认的业务事实补成既定计划。
5. 要输出明确的 batching strategy，为 final_prd 的多批次拆分提供依据。

## 正确产出

至少应包含：

1. planning basis
2. delivery strategy
3. workstreams
4. plan steps
5. contract priorities
6. batching strategy
7. risks and watchpoints

## 不应该做的事

- 不代替 final_prd
- 不直接写接口 contract
- 不直接下沉到数据库设计
