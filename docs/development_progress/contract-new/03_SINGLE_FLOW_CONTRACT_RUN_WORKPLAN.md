# Contract New Step 3 Workplan

这份文档只服务第三步执行：

- 单 flow `contract` run 改造

这一步不进入 `develop` 输入设计，不进入 baseline 沉淀，也不做最终样例/smoke 收尾。

## 这一步的唯一目标

把 `contract` 从“整份 PRD 直接推进的大而混流程”改成：

- 一个 flow 一个独立 run
- run 内明确区分 intake / working / release
- 单个 flow 的正式交付收口到 release 层

## 这一步完成后必须成立的事实

1. 后续 `contract` 默认按单个 flow 推进，而不是整份 PRD 一次性推进。
2. 一个 flow 对应一个独立 `runs/YYYY-MM-DD-contract-<flow-id>/`。
3. 每个 flow run 至少区分：
   - `intake/`
   - `contract/working/`
   - `contract/release/`
4. `contract/release/` 成为正式下游输入层。
5. 旧 `freeze/publish` 不再被当作单 flow 的正式终点。

## 这一步必须坚持的原则

1. 只做单 flow run 结构改造。
2. 不提前进入 `develop` 输入实现。
3. 不提前进入 baseline 沉淀。
4. `release` 是正式输入层，但这一步不要求把实现后真基线做完。
5. 不再回到旧 `freeze/publish/published_contract` 模型。

## 这一步的处理范围

### A. 要落地的 run 形态

目标形态至少要能表达成：

```text
runs/YYYY-MM-DD-contract-<flow-id>/
  intake/
    contract-handoff.snapshot.yaml
    contract-handoff.snapshot.md
  contract/
    working/
      contract-draft.yaml
      rendered/
    release/
      openapi.yaml
      openapi.summary.md
      develop-handoff.md
```

这里重点不是文件名一字不差，而是分层语义必须成立：

- `intake/` 存正式 handoff 快照
- `contract/working/` 存过程态
- `contract/release/` 存正式交付

### B. 每层职责必须明确

`intake/`：

- 存单个 flow 的正式启动输入
- 不再从整份 `final_prd` 直接起步

`contract/working/`：

- 存推导中的协议过程态
- 可以反复修改
- 不能默认给下游直接消费

`contract/release/`：

- 存当前 flow 对下游正式暴露的稳定输入
- 至少包含独立 `openapi/swagger`
- 至少包含一份面向人类的摘要说明
- 至少包含一份面向后续阶段的 handoff 说明

### C. 这一轮至少要改的入口

优先检查并必要时修改：

- [docs/contract/WORKFLOW_GUIDE.md](/Users/wangwenjie/project/archetype-admin-path/docs/contract/WORKFLOW_GUIDE.md)
- 与 `contract` run 初始化、路径推导、产物输出直接相关的脚本
- 第二步产出的 handoff 与第三步 run 入口之间的连接点

目标是让这些入口都明确：

- 后续 `contract` 是单 flow run
- 默认从 handoff snapshot 进入
- 正式输出在 `release/`

### D. 这一轮允许碰的脚本范围

这一轮如果要改脚本，优先只允许动：

- `contract` run 初始化逻辑
- handoff snapshot 写入逻辑
- working / release 路径推导逻辑
- release 产物最小输出逻辑

不要顺手扩到：

- `develop` 消费逻辑
- baseline 目录
- 最终实现后沉淀规则

## 执行顺序

### Phase 3A: 定义单 flow run 目录

先把单 flow run 的目录层级写死并真正落下。

本 phase 输出：

- `runs/YYYY-MM-DD-contract-<flow-id>/` 最小目录语义成立

### Phase 3B: 接上 handoff snapshot

把第二步产出的 flow handoff 正式接进单 flow run 的 intake 层。

本 phase 输出：

- 后续 `contract` 默认从 handoff snapshot 起步

### Phase 3C: 分离 working 和 release

明确 working 是过程态，release 是正式输入层。

本 phase 输出：

- 目录边界不再混

### Phase 3D: 落最小 release 包

至少让 release 层能表达：

- `openapi.yaml`
- `openapi.summary.md`
- `develop-handoff.md`

本 phase 输出：

- 单 flow 已有最小正式交付包

### Phase 3E: 清理检查

结束前至少检查：

- 是否还把整份 PRD 直接当 contract 启动输入
- 是否还把过程态和正式输入混在一起
- 是否还把旧 `freeze/publish` 当正式终点
- 是否顺手引入了第四步内容

## 明确不在本步做的事

下面这些不是第三步范围：

- `develop` 如何正式消费 release
- baseline 如何沉淀
- 后续改需求从哪里回切
- 最终样例与 smoke 收尾

碰到这些说明已经越界。

## 完成标准

这一步完成后，至少要满足：

1. 一个 flow 一个独立 `contract` run。
2. run 内 intake / working / release 三层边界成立。
3. `contract/release/` 已经成为正式交付层。
4. 单 flow 的正式终态不再依赖旧 `freeze/publish` 叙事。

## 建议交给 AI 的一句话任务

只做第三步：把 `contract` 改成单 flow 独立 run，并分出 intake / working / release，不进入 develop 或 baseline。
