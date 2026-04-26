# Contract New Step 2 Workplan

这份文档只服务第二步执行：

- 把 `final_prd -> contract_handoff` 真正落盘

这一步不进入单 flow `contract` run 改造，不进入 `contract/release/` 正式产物实现，也不进入 `develop`。

## 这一步的唯一目标

让 `final_prd` 通过后，仓库里真的出现一个明确的 `contract_handoff/` 层，而不是只在文档里说“下一步会拆 flows”。

## 这一步完成后必须成立的事实

1. `final_prd` 后不再是“概念上可以进 contract”。
2. `prd run` 内会长出正式的 `contract_handoff/` 目录。
3. `contract_handoff/` 里至少有：
   - 总览索引
   - 总览说明
   - per-flow handoff 文件
4. 后续进入 `contract` 时，默认输入是单个 flow 的 handoff，而不是整份 PRD 直接进 `contract`。

## 这一步必须坚持的原则

1. 只做 `final_prd -> contract_handoff`。
2. 不提前进入单 flow `contract` run 结构改造。
3. 不提前进入 `contract/release/` 设计。
4. 不提前进入 `develop` 输入设计。
5. 不再引入任何旧 `freeze/publish/published_contract/generation bridge` 语义。

## 这一步的处理范围

### A. 要落地的目录语义

目标形态至少要能表达成：

```text
runs/<prd-run-id>/
  prd/
    prd-04.final_prd.yaml
  contract_handoff/
    contract-handoff.index.yaml
    contract-handoff.md
    flows/
      01.<flow-id>.handoff.yaml
      01.<flow-id>.handoff.md
      02.<flow-id>.handoff.yaml
      02.<flow-id>.handoff.md
```

这里的重点不是文件名绝对固定，而是语义必须落地：

- 有总览索引
- 有人类可读总览
- 有 per-flow 结构化 handoff
- 有 per-flow 可读 handoff

### B. handoff 必须表达的信息

总览索引至少要表达：

- 本次拆出多少个 flows
- flows 的顺序
- flows 的依赖关系
- 当前推荐先进入哪个 flow
- 每个 flow 当前状态

单个 flow handoff 至少要表达：

- flow id
- flow 名称或范围摘要
- 上游来源
- 依赖 flows
- 当前范围
- 禁止假设项
- 推荐进入说明

### C. 这一轮必须改的入口

这一轮至少要检查并必要时改这些地方：

- [docs/prd/WORKFLOW_GUIDE.md](/Users/wangwenjie/project/archetype-admin-path/docs/prd/WORKFLOW_GUIDE.md)
- [docs/contract/WORKFLOW_GUIDE.md](/Users/wangwenjie/project/archetype-admin-path/docs/contract/WORKFLOW_GUIDE.md)
- [scripts/prd/review_complete.rb](/Users/wangwenjie/project/archetype-admin-path/scripts/prd/review_complete.rb)
- [docs/development_progress/contract-new/CONTRACT_NEW_EXECUTION_RUNBOOK.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/contract-new/CONTRACT_NEW_EXECUTION_RUNBOOK.md)

目标是让这几个入口都明确：

- `final_prd` 完成后下一步就是 `contract_handoff`
- handoff 是正式落盘，不是脑补步骤

### D. 这一轮允许碰的脚本范围

这一轮如果要改脚本，优先只允许动：

- `scripts/prd/review_complete.rb`
- 与 `contract_handoff` 直接相关的最小辅助逻辑

不要顺手扩到：

- 单 flow `contract` run
- `openapi/swagger`
- `develop`
- baseline

## 执行顺序

### Phase 2A: 确认 handoff 最小结构

先把 `contract_handoff/` 的最小目录与文件语义写死。

本 phase 输出：

- 明确目录结构
- 明确每个文件的职责

### Phase 2B: 接到 `final_prd` 收口点

把 handoff 正式挂到 `final_prd` 完成后的主链收口动作上。

本 phase 输出：

- `final_prd` 完成后可生成 `contract_handoff/`

### Phase 2C: 产出最小 handoff 内容

至少让 handoff 能稳定产出：

- 总览索引
- 总览说明
- per-flow handoff

本 phase 输出：

- 不再只有概念定义，已经有真实落盘

### Phase 2D: 入口文档同步

把相关 guide 和说明同步到 handoff 新事实。

本 phase 输出：

- 文档和实际落盘对齐

### Phase 2E: 清理检查

结束前至少检查：

- 是否还有入口把 `final_prd` 之后直接写成 `contract`
- 是否还有入口把 handoff 写成可有可无的隐式动作
- 是否引入了第二步之外的结构

## 明确不在本步做的事

下面这些不是第二步范围：

- `runs/YYYY-MM-DD-contract-<flow-id>/` 独立 run 落盘
- `contract/working/` 与 `contract/release/` 分层
- `openapi.yaml` 正式产物
- `develop` 输入
- baseline 沉淀

碰到这些说明已经越界。

## 完成标准

这一步完成后，至少要满足：

1. `final_prd` 后真的会产出 `contract_handoff/`。
2. handoff 至少有总览索引、总览说明和 per-flow 文件。
3. 文档入口已经把 handoff 当正式步骤，而不是临时说明。
4. 后续进入 `contract` 时，默认前提已经是“先选定一个 flow handoff”。

## 建议交给 AI 的一句话任务

只做第二步：把 `final_prd -> contract_handoff` 真实落盘并同步入口文档，不进入单 flow run 或 develop。
