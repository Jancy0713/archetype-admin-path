# Contract New Step 1 Prompt

你现在只负责 `contract-new` 的第一步执行。

这一轮不是继续写规划，也不是进入后续实现，而是：

- 清理旧入口
- 统一正式入口口径

## 本轮唯一目标

把当前仓库中会把人或 AI 带回旧主链的正式入口清掉，并让所有关键入口统一采用下面这条主链：

```text
init -> prd -> contract_handoff -> contract -> openapi/swagger -> develop
```

## 你必须先读取这些文件

- /Users/wangwenjie/project/archetype-admin-path/docs/development_progress/contract-new/README.md
- /Users/wangwenjie/project/archetype-admin-path/docs/development_progress/contract-new/CONTRACT_NEW_FULL_DIRECTION.md
- /Users/wangwenjie/project/archetype-admin-path/docs/development_progress/contract-new/CONTRACT_NEW_IMPLEMENTATION_PLAN.md
- /Users/wangwenjie/project/archetype-admin-path/docs/development_progress/contract-new/CONTRACT_NEW_EXECUTION_RUNBOOK.md
- /Users/wangwenjie/project/archetype-admin-path/docs/development_progress/contract-new/01_ENTRY_CLEANUP_AND_ALIGNMENT_WORKPLAN.md
- /Users/wangwenjie/project/archetype-admin-path/docs/prd/WORKFLOW_GUIDE.md
- /Users/wangwenjie/project/archetype-admin-path/docs/contract/README.md
- /Users/wangwenjie/project/archetype-admin-path/docs/contract/WORKFLOW_GUIDE.md
- /Users/wangwenjie/project/archetype-admin-path/docs/development_progress/contract/README.md
- /Users/wangwenjie/project/archetype-admin-path/docs/development_progress/generation/README.md

如果根目录 `contracts/` 仍存在，也要检查它的说明与引用。

## 本轮硬约束

1. 只做第一步，不进入第二步之后的实现。
2. 不做兼容层。
3. 不保留“先兼容旧路径，后面再清”的过渡实现。
4. 旧逻辑要么删除，要么明确降级为历史记录。
5. `docs/development_progress/contract/` 和 `docs/development_progress/generation/` 可以保留，但只能是历史记录，不能再充当当前正式入口。

## 本轮必须完成的事情

### 1. 删除显眼旧入口

优先删除或清理：

- 根目录 `contracts/`
- `docs/contract/examples/1.0/`
- 其它只服务旧 `contract -> generation`、`freeze/publish`、`generation bridge` 的正式样例或正式入口说明

### 2. 改写正式入口文档

至少改这些：

- `docs/prd/WORKFLOW_GUIDE.md`
- `docs/contract/README.md`
- `docs/contract/WORKFLOW_GUIDE.md`
- 必要时补改 `contract-new` 目录下的入口文档

改写要求：

- 默认主链不再写 `contract -> generation`
- 不再把 `freeze/publish` 当新版正式终点
- 明确 `contract_handoff` 是显式步骤
- 明确一个 flow 的正式终点是独立 `openapi/swagger`
- 明确 `develop` 是下游阶段

### 3. 降级历史记录目录

对下面两个目录：

- `docs/development_progress/contract/`
- `docs/development_progress/generation/`

要求：

- 保留目录
- 但 README 必须明确说明它们只是历史记录
- 不能继续被推荐成当前正式入口

### 4. 清理旧脚本入口引用

重点排查这些类型：

- `freeze`
- `publish`
- `published_contract`
- `generation_bridge`
- `generation_input`
- `generation_materials`

本轮最低要求：

- 不能再让正式入口文档默认把这些脚本当当前主链入口
- 明显纯旧逻辑的，可以直接删除
- 暂时不删但后续要重写的，必须从正式入口说明中摘掉

## 本轮禁止做的事

不要做下面这些：

- 不要开始实现 `contract_handoff/` 落盘
- 不要开始改单 flow run 目录
- 不要开始实现 `contract/release/`
- 不要开始实现 `develop`
- 不要开始设计 baseline 落盘
- 不要顺手扩写新的多阶段规划文档

## 执行顺序

按下面顺序来：

1. 识别要删 / 要改 / 只降级的入口
2. 先删显眼旧入口
3. 再改正式入口文档
4. 再把历史记录目录降级
5. 最后做一轮清理检查

## 清理检查清单

结束前必须确认：

1. 是否还有关键入口默认写 `contract -> generation`
2. 是否还有关键入口把 `freeze/publish` 写成新版正式终点
3. 是否还有正式入口引用根目录 `contracts/`
4. 是否还有 README / prompt / guide 在推荐旧 bridge 逻辑
5. 是否还留下“先兼容旧逻辑”的描述或代码

只要发现，就继续清，不要留到下一轮。

## 输出要求

本轮结束时必须明确汇报：

1. 删掉了哪些旧入口
2. 改了哪些正式入口文档
3. 哪些目录被保留为历史记录
4. 还有哪些旧脚本只是暂时保留、后续必须重写或删除
5. 为什么本轮已经满足“第一步完成标准”
