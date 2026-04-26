# Contract New Step 3 Prompt

你现在只负责 `contract-new` 的第三步执行。

这一轮不是继续做 `contract_handoff`，也不是进入 `develop` 或 baseline，而是：

- 把 `contract` 改成单 flow 独立 run

## 本轮唯一目标

让后续 `contract` 默认按“一个 flow 一个独立 run”的方式推进，并在 run 内明确分出：

- `intake/`
- `contract/working/`
- `contract/release/`

## 开始前先确认

开始之前，先确认前两步已经满足最小前提：

1. 根目录 `contracts/` 已不再作为正式入口存在。
2. `final_prd` 之后已经能生成正式 `contract_handoff/`。
3. 入口文档已经明确：

```text
init -> prd -> contract_handoff -> contract -> openapi/swagger -> develop
```

如果这些前提仍不成立，先指出问题，再继续本轮。

## 你必须先读取这些文件

- /Users/wangwenjie/project/archetype-admin-path/docs/development_progress/contract-new/README.md
- /Users/wangwenjie/project/archetype-admin-path/docs/development_progress/contract-new/CONTRACT_NEW_FULL_DIRECTION.md
- /Users/wangwenjie/project/archetype-admin-path/docs/development_progress/contract-new/CONTRACT_NEW_IMPLEMENTATION_PLAN.md
- /Users/wangwenjie/project/archetype-admin-path/docs/development_progress/contract-new/CONTRACT_NEW_EXECUTION_RUNBOOK.md
- /Users/wangwenjie/project/archetype-admin-path/docs/development_progress/contract-new/03_SINGLE_FLOW_CONTRACT_RUN_WORKPLAN.md
- /Users/wangwenjie/project/archetype-admin-path/docs/contract/WORKFLOW_GUIDE.md
- 与 `contract` run 初始化、路径推导、handoff 接入直接相关的脚本

如果仓库里已经有部分单 flow 结构雏形，也可以读，但不能把旧 `freeze/publish` 或旧大一统 contract run 带回来。

## 本轮硬约束

1. 只做单 flow `contract` run 改造。
2. 不做兼容层。
3. 不再引入旧 `freeze/publish/published_contract` 语义。
4. 不提前进入 `develop` 输入实现。
5. 不提前进入 baseline 沉淀和回改规则。

## 本轮必须完成的事情

### 1. 定义并落地单 flow run

目标形态至少要能表达：

```text
runs/YYYY-MM-DD-contract-<flow-id>/
  intake/
    contract-handoff.snapshot.yaml
    contract-handoff.snapshot.md
  contract/
    working/
    release/
```

重点不是文件名绝对固定，而是层级语义必须存在。

### 2. 把 handoff 接成 intake

至少要让：

- 单个 flow handoff 会进入独立 run 的 `intake/`
- 后续 `contract` 默认从 handoff snapshot 起步
- 不再从整份 `final_prd` 直接起步

### 3. 分离过程态和正式交付

至少要让：

- `contract/working/` 只存过程态
- `contract/release/` 只存正式交付
- 下游默认不直接吃 working

### 4. release 至少要能表达最小正式交付

至少有：

- `openapi.yaml`
- `openapi.summary.md`
- `develop-handoff.md`

本轮不要求把它们做到最终完善，但语义和路径必须成立。

## 本轮禁止做的事

不要做下面这些：

- 不要开始实现 `develop` 默认消费逻辑
- 不要开始设计 baseline 目录
- 不要开始写“改需求从哪回切”的规则
- 不要顺手把第四步、第五步也写了

## 执行顺序

按下面顺序来：

1. 定义单 flow run 目录
2. 接上 handoff snapshot
3. 分离 working 和 release
4. 落最小 release 包
5. 做一轮清理检查

## 清理检查清单

结束前必须确认：

1. 是否还把整份 PRD 直接当 contract 启动输入
2. 是否还把 working 和 release 混在一起
3. 是否还把旧 `freeze/publish` 当正式终点
4. 是否顺手引入了 `develop` 或 baseline 设计

只要发现，就继续修，不要留到下一轮。

## 输出要求

本轮结束时必须明确汇报：

1. 单 flow run 最终落成了什么结构
2. handoff 如何进入 intake
3. working 和 release 如何分层
4. release 层当前已经有哪些正式交付
5. 哪些内容明确留到第四步，不在本轮处理
