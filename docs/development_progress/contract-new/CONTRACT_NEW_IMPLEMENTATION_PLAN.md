# Contract New Implementation Plan

这份文档不再讨论“先写几轮文档再开工”。

它只回答一件事：

- 真正开始做这次需求时，应该按什么顺序落地

## 总目标

把当前旧主链：

```text
init -> prd -> contract -> generation
```

改成：

```text
init -> prd -> contract_handoff -> contract -> openapi/swagger -> develop
```

## 这次实施只守 7 条原则

1. 先清掉会误导主链的旧入口，再改入口定义，再改落盘路径，再改脚本行为。
2. 一个 PRD 拆多个 contract flows，不再走一个大而混的 contract run。
3. 单个 flow 的正式输出必须是独立 `openapi/swagger`，不是旧 `freeze/publish`。
4. `develop` 只消费正式 release，不消费 `contract` 过程态。
5. 旧 `contract -> generation` 相关资产只能当历史参考，不能继续当正式入口。
6. 不做兼容层；凡是已经判定不属于新主链的旧文档、旧提示词、旧脚本、旧样例和旧目录，要么删除，要么明确降级为历史记录，不能继续参与正式执行。
7. 每个 contract flow run 必须像 `init` / `prd` run 一样由统一创建入口生成标准工作区，并提供可直接交给 AI 的启动提示词。

## 可执行顺序

### 1. 旧入口清理与入口对齐

先把所有会误导 AI 和人的旧入口清掉，再统一入口文档。

这一轮要完成：

- 删除或归档根目录 `contracts/` 这类旧 published contract 入口
- 保留 `docs/development_progress/contract/` 与 `docs/development_progress/generation/` 作为历史记录，但必须确保它们不再被当成当前正式入口
- 删除默认把主链指向 `contract -> generation` 的旧样例、旧说明和旧 bridge 叙事
- 把 `final_prd -> contract_handoff -> contract -> openapi/swagger -> develop` 设成唯一主链
- 给旧 `contract` / 旧 `generation` 文档补 legacy 说明
- 去掉“实现前 freeze/publish 是正式终点”的表达

完成后才能进入下一轮，否则后面实现一定会继续跑偏。

### 2. 正式目录落点

把新主链对应的正式目录定下来并真正开始落地。

这一轮要完成：

- `prd run` 在 `final_prd` 后产出 `contract_handoff/`
- 每个 flow 落到独立 `runs/YYYY-MM-DD-contract-<flow-id>/`
- flow 的正式交付统一进 `contract/release/`
- `develop` 输入明确指向 release，而不是 working 过程态

### 3. contract 主流程改造

把当前 `contract` 相关脚本和入口从旧 lifecycle 改到新模型。

这一轮要完成：

- 输入从“整份 PRD 直接进 contract”改成“handoff 后进入单 flow contract”
- 输出从旧 `freeze/publish/generation bridge` 改成 `openapi/swagger + handoff`
- 明确 working 和 release 的职责边界

### 4. develop 接入与基线

把 `develop` 需要吃的输入接上，并把实现后基线补出来。

这一轮要完成：

- `develop` 只消费 release 包
- 实现完成后沉淀 flow 级 baseline
- 后续改需求时，能判断该回到 `final_prd`、`contract_handoff`、某个 flow，还是 baseline

### 5. 样例与 smoke 收尾

最后只做新版样例和 smoke 收尾，不再把“清旧入口”拖到这里。

这一轮要完成：

- 新版样例跑通
- smoke 围绕新主链断言
- 只保留仍服务新版主链的脚本与示例

### 6. contract run 标准化与 human 输出

这一轮修正前五步完成后暴露出的体验问题。

这一轮要完成：

- `prd-05` 拆出的每个 contract flow run 都用统一创建入口生成
- 每个 `runs/YYYY-MM-DD-contract-<flow-id>/` 都补齐 `raw/`、`prompts/`、`progress/`、`intake/`、`contract/working/`、`contract/release/`
- 每个 flow run 都生成 `prompts/run-agent-prompt.md`
- `prd-05` 完成回报固定成“下一步建议 -> 批次列表 -> 关键材料 -> 异常偏差”的结构
- human 启动下一批时使用提示词，不直接拿 handoff YAML 当启动材料

## 你现在真正该怎么推进

不要再让 AI “继续整理四个阶段文档”。

从现在开始，只按下面方式推进：

1. 选一个执行批次
2. 让 AI 只做这一批代码和文档改造
3. 做完后检查结果
4. 再进入下一批

每一批结束前都要额外检查：

- 有没有留下旧逻辑兼容代码
- 有没有留下旧入口引用
- 有没有留下“先保留以后再删”的过渡实现

发现了就直接清，不往后拖。

真正的批次拆法见：

- [CONTRACT_NEW_EXECUTION_RUNBOOK.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/contract-new/CONTRACT_NEW_EXECUTION_RUNBOOK.md)

## 当前边界

这份计划不再继续扩展探索性阶段文档；只有已经明确为修正项的执行批次才追加到 runbook。
