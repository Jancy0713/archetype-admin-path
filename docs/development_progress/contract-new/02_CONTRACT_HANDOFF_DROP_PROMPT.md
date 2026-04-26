# Contract New Step 2 Prompt

你现在只负责 `contract-new` 的第二步执行。

这一轮不是继续清理旧入口，也不是进入单 flow `contract` run 改造，而是：

- 把 `final_prd -> contract_handoff` 真正落盘

## 本轮唯一目标

让 `final_prd` 通过后，仓库里真的出现一个正式的 `contract_handoff/` 层，并让后续 `contract` 默认从单个 flow handoff 进入。

## 开始前先确认

开始之前，先确认第一步已经满足最小前提：

1. 根目录 `contracts/` 已不再作为正式入口存在。
2. 正式入口已经统一站到新主链：

```text
init -> prd -> contract_handoff -> contract -> openapi/swagger -> develop
```

3. `docs/development_progress/contract/` 和 `docs/development_progress/generation/` 只是历史记录，不再充当当前正式入口。

如果这些前提仍不成立，先指出问题，再继续本轮。

## 你必须先读取这些文件

- /Users/wangwenjie/project/archetype-admin-path/docs/development_progress/contract-new/README.md
- /Users/wangwenjie/project/archetype-admin-path/docs/development_progress/contract-new/CONTRACT_NEW_FULL_DIRECTION.md
- /Users/wangwenjie/project/archetype-admin-path/docs/development_progress/contract-new/CONTRACT_NEW_IMPLEMENTATION_PLAN.md
- /Users/wangwenjie/project/archetype-admin-path/docs/development_progress/contract-new/CONTRACT_NEW_EXECUTION_RUNBOOK.md
- /Users/wangwenjie/project/archetype-admin-path/docs/development_progress/contract-new/02_CONTRACT_HANDOFF_DROP_WORKPLAN.md
- /Users/wangwenjie/project/archetype-admin-path/docs/prd/WORKFLOW_GUIDE.md
- /Users/wangwenjie/project/archetype-admin-path/docs/contract/WORKFLOW_GUIDE.md
- /Users/wangwenjie/project/archetype-admin-path/scripts/prd/review_complete.rb

如果仓库里还有现成的 handoff 生成逻辑，也可以读，但只能用于复用最小必要部分，不能把旧主链重新带回来。

## 本轮硬约束

1. 只做 `final_prd -> contract_handoff`。
2. 不做兼容层。
3. 不再引入旧 `freeze/publish/published_contract/generation bridge` 语义。
4. 不提前进入单 flow `contract` run 改造。
5. 不提前进入 `contract/release/`、`openapi/swagger`、`develop` 或 baseline。

## 本轮必须完成的事情

### 1. 定义并落地 `contract_handoff/`

目标形态至少要能表达：

```text
runs/<prd-run-id>/
  contract_handoff/
    contract-handoff.index.yaml
    contract-handoff.md
    flows/
      01.<flow-id>.handoff.yaml
      01.<flow-id>.handoff.md
```

重点不是文件名绝对固定，而是语义必须存在：

- 总览索引
- 总览说明
- per-flow 结构化 handoff
- per-flow 可读 handoff

### 2. 把 handoff 接到 `final_prd` 收口动作

至少要让：

- `final_prd` 完成后，不再只是“概念上可以进 contract”
- 系统能正式生成 `contract_handoff/`

如果要改脚本，优先改：

- `scripts/prd/review_complete.rb`

### 3. handoff 至少要表达这些内容

总览索引至少要有：

- flows 列表
- 顺序
- 依赖
- 当前推荐入口
- 每个 flow 状态

单个 flow handoff 至少要有：

- flow id
- 范围摘要
- 上游来源
- 依赖 flows
- 禁止假设项
- 推荐进入说明

### 4. 同步入口文档

至少同步这些认知：

- `final_prd` 后下一步是 `contract_handoff`
- 后续 `contract` 默认消费单个 flow handoff
- handoff 是正式落盘结果，不是嘴上说说

## 本轮禁止做的事

不要做下面这些：

- 不要开始实现 `runs/YYYY-MM-DD-contract-<flow-id>/`
- 不要开始实现 `contract/working/`
- 不要开始实现 `contract/release/`
- 不要开始生成 `openapi.yaml`
- 不要开始实现 `develop`
- 不要顺手把第三步、第四步也写了

## 执行顺序

按下面顺序来：

1. 确认 handoff 最小结构
2. 接到 `final_prd` 收口点
3. 产出最小 handoff 内容
4. 同步入口文档
5. 做一轮清理检查

## 清理检查清单

结束前必须确认：

1. 是否还有入口把 `final_prd` 后直接写成 `contract`
2. 是否把 handoff 仍写成隐式动作
3. 是否顺手引入了第二步之外的结构
4. 是否又把旧主链语义带了回来

只要发现，就继续修，不要留到下一轮。

## 输出要求

本轮结束时必须明确汇报：

1. `contract_handoff/` 最终落成了什么结构
2. `final_prd` 完成后现在会生成什么
3. 改了哪些入口文档或脚本
4. 哪些内容明确留到第三步，不在本轮处理
5. 为什么本轮已经满足第二步完成标准
