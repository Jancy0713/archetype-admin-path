# Contract New Execution Runbook

这份文档是直接执行版。

用途只有一个：

- 把这次需求拆成几批，让 AI 一次只做一批

不要基于这份文档继续扩写探索性文档；只有已经明确为实现修正项的批次才允许追加 prompt 或 workplan。

## 总执行纪律

这次改造有一个硬约束：

- 我们没有历史包袱，不做兼容层

具体要求：

- 不保留旧逻辑兼容代码
- 不保留继续参与正式执行的旧提示词
- 不保留继续参与正式入口判断的旧 README / guide / examples
- 不保留“先兼容旧路径，后面再清”的过渡实现

允许保留的只有：

- 明确标注为 historical / legacy 的历史记录

但这类历史记录不能继续作为正式入口、正式样例、正式脚本依据或默认读取路径。

## 使用方式

每次只执行一个 batch。

一轮只做：

- 指定范围内的代码和文档修改
- 必要验证
- 输出修改结果和风险

不要在同一轮里同时做后面 batch 的事。

## Pre-Batch: 旧资产立即清理

目标：

- 先把明显属于旧主链的垃圾入口清掉，避免后续 AI 继续误读

本批要做：

- 删除根目录 `contracts/`
- 删除所有只服务旧 `contract -> generation`、`freeze/publish`、`generation bridge` 的说明和样例
- 保留 `docs/development_progress/contract/` 和 `docs/development_progress/generation/` 作为历史记录，但要避免它们继续充当正式入口
- 检查仓库里是否还有默认读取旧路径、旧 published contract、旧 generation bridge 的脚本和提示词；能删就删，不能删就安排在后续 batch 立即重写，不允许长期并存

完成标准：

- 仓库里不再存在会把 AI 带回旧主链的显眼入口
- 后续实现不再背“兼容老方案”的包袱

建议交给 AI 的一句话任务：

- 只清理旧主链资产，不开始新实现。

每个 batch 结束前，都要补做一次清理检查：

- 有没有旧入口还在引用
- 有没有旧脚本还在被正式流程依赖
- 有没有为了省事留下兼容分支

发现了就直接清，不要记成“后续再说”。

## Batch 1: 主链入口改造

目标：

- 让仓库里的正式入口先统一站到新主链上

本批要做：

- 检查 `docs/prd/WORKFLOW_GUIDE.md`
- 检查 `docs/contract/WORKFLOW_GUIDE.md`
- 检查 `docs/development_progress/contract/README.md`
- 检查 `docs/development_progress/generation/README.md`
- 把所有默认主链改成：

```text
init -> prd -> contract_handoff -> contract -> openapi/swagger -> develop
```

- 给旧 `generation` 和旧 `freeze/publish` 相关说明打上 legacy / historical 标记

完成标准：

- 仓库关键入口不再默认写 `contract -> generation`
- 新上下文 AI 先读入口文档时，不会被带回旧主链

建议交给 AI 的一句话任务：

- 只改入口文档口径，不碰脚本和目录实现。

## Batch 2: PRD 到 Contract Handoff 落盘

目标：

- 让 `final_prd` 后真的有一个显式 `contract_handoff/` 层

本批要做：

- 定义并落地 `prd run` 下的 `contract_handoff/`
- 至少包含总览索引、总览说明、per-flow handoff 文件
- 明确 handoff 如何表达 flow 顺序、依赖和当前推荐入口
- 补齐对应 README 或示例路径

完成标准：

- `final_prd` 后不再只是“概念上可以进 contract”
- 仓库里已经有明确的 handoff 目录和文件语义

建议交给 AI 的一句话任务：

- 只实现 `final_prd -> contract_handoff` 的目录和文档/脚本入口，不处理 develop。

## Batch 3: 单 Flow Contract Run 改造

目标：

- 让每个 contract flow 成为独立 run，并收口到 release 包

本批要做：

- 把单 flow run 目录改成独立形态
- 区分 `intake/`、`contract/working/`、`contract/release/`
- 让正式输出至少包含：

```text
openapi.yaml
openapi.summary.md
develop-handoff.md
```

- 停止把旧 `freeze/publish` 当作单 flow 正式终点

完成标准：

- 一个 flow 对应一个独立 run
- `contract/release/` 成为正式下游输入

建议交给 AI 的一句话任务：

- 只改单 flow contract run 结构和 release 产物，不处理 baseline。

## Batch 4: Develop 输入与回改基线

目标：

- 让 `develop` 真正接到 release，并补上实现后基线逻辑

本批要做：

- 明确 `develop` 默认消费哪些 release 文件
- 补实现后 baseline 的目录和说明
- 明确后续改需求时如何判断回入口：
  - 回 `final_prd`
  - 回 `contract_handoff`
  - 回单个 flow
  - 回 baseline

完成标准：

- `develop` 输入清晰
- “改需求从哪回去”不再靠猜

建议交给 AI 的一句话任务：

- 只补 develop 输入和 baseline 规则，不清理旧资产。

## Batch 5: 样例、Smoke、清旧入口

目标：

- 让仓库最终只剩新主链的正式入口

本批要做：

- 更新样例到新结构
- 更新 smoke 到新主链
- 降级或移除旧 `generation bridge`、旧 nested run、旧 freeze/publish 正式入口
- 保留必要 legacy 文档，但不能再当正式入口
- 删除这一轮实现后已经确认不再使用的旧提示词、旧脚本、旧目录和死代码

完成标准：

- 样例和 smoke 站在新主链上
- 旧主链只剩历史参考，不再干扰执行
- 仓库里不存在“为了兼容旧逻辑先留着”的残留代码

建议交给 AI 的一句话任务：

- 只做样例、smoke 和旧入口清理，不重做前面 batch 已完成的结构。

## Batch 6: Contract Run 标准化与 Human 输出

目标：

- 修正 `prd-05` 后多个 contract flow run 的目录形态和 human 回报体验

本批要做：

- 先扫描所有相关脚本、提示词、reviewer、materials、模板和 smoke，确认没有只改一个入口导致其它入口继续生成旧结构
- 让每个 `runs/YYYY-MM-DD-contract-<flow-id>/` 都通过统一创建入口生成
- contract run 外壳对齐 `init` / `prd`：
  - `raw/`
  - `prompts/`
  - `progress/`
  - `rendered/`
  - `archive/`
- 保留 contract 专属目录：
  - `intake/`
  - `contract/working/`
  - `contract/release/`
- 每个 flow run 生成 `prompts/run-agent-prompt.md`
- `prd-05` 完成回报固定为：
  - 下一步建议
  - 本次拆出的功能批次
  - 已生成的关键材料
  - 异常或偏差

完成标准：

- human 不再需要拿 handoff YAML 当启动材料
- human 可以选择在当前上下文说“执行第 1 批”，也可以新开上下文使用启动提示词
- 如果批次名称、顺序或依赖有问题，回报中明确说先修改 `contract_handoff`，不进入 contract
- 不再出现“是否现在创建并初始化这些标准 contract run 工作区”这类实现内部问题
- 脚本、prompt、reviewer checklist、materials、template、progress board 和 smoke 已同步更新或明确确认无需修改

建议交给 AI 的一句话任务：

- 只修正 contract flow run 标准化和 `prd-05` 完成回报格式，不改变新版主链。

## 推荐执行顺序

严格按顺序来：

1. Pre-Batch
2. Batch 1
3. Batch 2
4. Batch 3
5. Batch 4
6. Batch 5
7. Batch 6

## 当前判断

如果前五批已经完成，下一步建议直接执行 Batch 6，修正 contract flow run 标准化和 human 输出体验。
