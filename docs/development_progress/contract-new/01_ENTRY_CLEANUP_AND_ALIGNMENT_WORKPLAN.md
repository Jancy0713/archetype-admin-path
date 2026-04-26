# Contract New Step 1 Workplan

这份文档只服务第一步执行：

- 旧入口清理
- 正式入口对齐

这一步不进入 `contract_handoff` 落盘，不进入单 flow run 改造，也不进入 `develop` 实现。

## 这一步的唯一目标

把仓库里所有会把人或 AI 带回旧主链的正式入口清干净，并把当前唯一正式主链统一成：

```text
init -> prd -> contract_handoff -> contract -> openapi/swagger -> develop
```

## 这一步必须坚持的原则

1. 不做兼容层。
2. 不保留“先兼容旧路径，后面再清”的过渡实现。
3. 旧逻辑要么删除，要么明确降级为历史记录。
4. 历史记录可以保留，但不能继续作为正式入口、正式样例、正式脚本依据或默认读取路径。
5. 这一步只处理入口、说明、提示词、旧样例和显眼旧资产，不展开第二步之后的实现。

## 这一步的处理范围

### A. 必须删除或移出正式入口的资产

这些内容继续保留只会污染当前主链理解：

- 根目录 `contracts/`
- `docs/contract/examples/1.0/`
- 所有只服务旧 `contract -> generation`、`freeze/publish`、`generation bridge` 的正式样例与正式入口说明

### B. 必须改写的正式入口

这些文件不删除，但必须改到新主链口径：

- [docs/prd/WORKFLOW_GUIDE.md](/Users/wangwenjie/project/archetype-admin-path/docs/prd/WORKFLOW_GUIDE.md)
- [docs/contract/README.md](/Users/wangwenjie/project/archetype-admin-path/docs/contract/README.md)
- [docs/contract/WORKFLOW_GUIDE.md](/Users/wangwenjie/project/archetype-admin-path/docs/contract/WORKFLOW_GUIDE.md)
- [docs/development_progress/contract-new/README.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/contract-new/README.md)
- [docs/development_progress/contract-new/CONTRACT_NEW_IMPLEMENTATION_PLAN.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/contract-new/CONTRACT_NEW_IMPLEMENTATION_PLAN.md)
- [docs/development_progress/contract-new/CONTRACT_NEW_EXECUTION_RUNBOOK.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/contract-new/CONTRACT_NEW_EXECUTION_RUNBOOK.md)

这些文件至少要满足：

- 默认主链不再写 `contract -> generation`
- 不再把 `freeze/publish` 写成新版正式终点
- 明确 `contract_handoff` 是显式步骤
- 明确 `openapi/swagger` 是单 flow 正式终点
- 明确 `develop` 是后续阶段

### C. 保留为历史记录但必须降级的目录

这些目录按你的要求保留，但只能是历史记录：

- [docs/development_progress/contract](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/contract)
- [docs/development_progress/generation](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/generation)

处理要求：

- 目录可以保留
- README 必须明确写成 historical / legacy
- 不能再被当前正式入口推荐为下一步执行方向
- 不能继续作为默认 prompt 读取入口

### D. 本步要重点排查的旧脚本类型

这一轮不做这些脚本的重写，但要把整组旧链路脚本视为待直接删除资产，而不是保留观察对象。

优先排查这些脚本：

- `scripts/contract/freeze_artifact.rb`
- `scripts/contract/publish_freeze.rb`
- `scripts/contract/published_contract.rb`
- `scripts/contract/generation_bridge.rb`
- `scripts/contract/generation_bridge_index.rb`
- `scripts/contract/generation_bridge_kickoff.rb`
- `scripts/contract/generation_input.rb`
- `scripts/contract/generation_materials.rb`
- `scripts/contract/prepare_generation_bridge.rb`
- `scripts/contract/verify_generation_bridge.rb`
- `scripts/contract/verify_published_contract.rb`

本步对它们的处理要求是：

- 不再在正式文档中被推荐为当前主链入口
- 既然已经判定旧 `freeze/publish/published_contract/generation_bridge` 主链废弃，就按一整个旧链路簇直接删除
- 删除时要同步修掉仍引用它们的活脚本说明与下一步提示，不能留下断引用

## 执行顺序

### Phase 1A: 识别正式入口

先确认当前哪些 README、workflow guide、examples、根目录资产会误导 AI。

本 phase 输出：

- 一份“要删 / 要改 / 仅降级”的清单

### Phase 1B: 清理显眼旧入口

先删最明显的旧主链资产：

- `contracts/`
- 旧 `docs/contract/examples/1.0/`
- 其它明确只服务旧链路的正式样例和入口说明

本 phase 输出：

- 仓库不再存在最显眼的旧主链正式入口

### Phase 1C: 对齐正式入口文档

统一改写 README 和 workflow guide。

本 phase 输出：

- 所有关键入口统一站到新主链

### Phase 1D: 历史记录降级

把 `docs/development_progress/contract/` 与 `docs/development_progress/generation/` 明确降级成历史记录。

本 phase 输出：

- 它们仍存在
- 但不会再误导下一轮 AI 当成当前正式入口

### Phase 1E: 清理检查

执行结束前，必须补一次清理检查。

至少检查：

- 是否还有关键入口默认写 `contract -> generation`
- 是否还有关键入口把 `freeze/publish` 写成新版正式终点
- 是否还有 README / prompt / guide 默认引用 `contracts/`
- 是否还保留了“先兼容旧路径”的描述

## 明确不在本步做的事

下面这些不是第一步范围：

- `final_prd -> contract_handoff/` 真正落盘
- 单 flow `runs/YYYY-MM-DD-contract-<flow-id>/` 目录实现
- `contract/release/` 正式产物实现
- `develop` 输入实现
- baseline 沉淀实现

如果执行中开始碰这些内容，说明已经越界。

## 完成标准

这一步完成后，至少要满足：

1. 仓库正式入口已经统一站到新主链。
2. 根目录 `contracts/` 不再作为正式入口存在。
3. 旧 `freeze/publish` 与 `generation bridge` 不再出现在当前正式主链叙事里。
4. `docs/development_progress/contract/` 与 `docs/development_progress/generation/` 只剩历史记录角色。
5. 没有留下“为了兼容旧逻辑先保留”的正式入口代码或说明。

## 建议交给 AI 的一句话任务

只做第一步：清理旧入口并统一正式入口文档到新主链，不进入后续目录实现或脚本重构。
