# Contract Run Isolation Discussion

这份文档记录一个后续待改造的问题：进入 `contract` 后，应禁止下游流程继续回写上游 PRD run。

## 背景

当前执行 `contract` 时，某些步骤会回头更新原始 PRD run 里的状态或 handoff 信息。

从业务角度看，这样做有原因：

- `prd-05` 会把一个 final PRD 拆成多个 contract batch。
- 第 1 个 contract batch 完成后，后续 batch 需要知道依赖是否已满足。
- 现在部分状态更新会写回上游 run，方便后续 batch 感知解锁状态。

但从 run 的设计边界看，这会让职责变得混在一起：

- PRD run 原本应该是上游输入和交接快照。
- contract run 原本应该是下游独立执行工作区。
- 下游执行时修改上游 run，会让“哪个 run 是事实源”变得不清楚。

## 当前担心

用户倾向认为每个 `runs/<id>` 应该是相对独立的工作区。

因此进入 contract 后，如果继续改 `runs/<prd-run>/`，会产生几个问题：

1. 上游 PRD run 不再是稳定快照。
2. contract 执行状态和 PRD 交接状态混在一起。
3. 后续排查时，很难区分哪些内容是 PRD 产物，哪些内容是 contract 运行态。
4. 如果多个 contract batch 并行推进，回写上游 run 可能引入状态竞争。

## 确定方向

后续改造应采用以下边界：

```text
PRD run：只读，作为上游输入快照
contract run：只改自己
依赖状态：由下游读取和检查，不回写上游
```

也就是：

- `runs/<prd-run>/` 在 `prd-05` 之后冻结，不再由 contract 阶段修改。
- `runs/YYYY-MM-DD-contract-<flow-id>/` 只维护当前 batch 自己的进度、产物、review 和 release。
- batch 解锁状态不写回 PRD run，而是由当前 contract run 在启动或继续执行时读取依赖状态。
- 下游可以读取上游 PRD run 和依赖 contract run，但不能修改它们。
- 同级 contract run 之间也不应该互相写文件，只能通过已发布产物或状态文件判断依赖是否满足。

## 目标模型

每个 contract run 启动或继续执行时，只做检查：

- 依赖的 `runs/YYYY-MM-DD-contract-<flow-id>/contract/release/openapi.yaml` 是否存在。
- 依赖的 `develop-handoff.md` 是否存在。
- 依赖的 review/release 状态是否满足。

如果依赖不满足，当前 contract run 应停止并提示 human，而不是去修改上游 PRD run 或依赖 run。

## 改造原则

1. `prd-05` 可以生成 handoff 和标准 contract run shell。
2. `prd-05` 之后，PRD run 作为上游事实冻结。
3. contract 阶段只能修改当前正在执行的 `runs/YYYY-MM-DD-contract-<flow-id>/`。
4. contract 阶段可以读取上游 PRD run 和依赖 contract run。
5. contract 阶段不能回写上游 PRD run。
6. contract 阶段不能修改其他 contract run 的状态。
7. 依赖是否满足，应通过读取依赖 run 的 release/review 产物判断。

## 后续讨论点

- 现有 `review_complete.rb` / `build_release.rb` 中哪些回写上游 run 的逻辑需要删除或迁移。
- contract run 继续执行时，具体检查哪些依赖 release 文件和状态文件。
- 依赖未满足时，提示 human 的标准文案和退出码如何定义。
