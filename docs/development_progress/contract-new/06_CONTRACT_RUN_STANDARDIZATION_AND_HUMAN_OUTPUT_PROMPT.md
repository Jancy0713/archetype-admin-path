# Contract New Step 6 Prompt

你现在只负责 `contract-new` 的第六步执行。

这一轮的目标是：

- **标准化 `prd-05` 后生成的 contract flow run**
- **标准化 `prd-05` 完成后给 human 的回复格式**

不要重做 `contract-new` 前五步，不要重新讨论主链。

## 本轮唯一目标

让 `prd-05 contract_handoff` 拆出的每个 flow 都进入标准、独立、可继续执行的 contract run，并让 human 收到清晰固定的下一步说明。

## 你必须先读取这些文件

- /Users/wangwenjie/project/archetype-admin-path/docs/development_progress/contract-new/README.md
- /Users/wangwenjie/project/archetype-admin-path/docs/development_progress/contract-new/CONTRACT_NEW_FULL_DIRECTION.md
- /Users/wangwenjie/project/archetype-admin-path/docs/development_progress/contract-new/CONTRACT_NEW_EXECUTION_RUNBOOK.md
- /Users/wangwenjie/project/archetype-admin-path/docs/development_progress/contract-new/06_CONTRACT_RUN_STANDARDIZATION_AND_HUMAN_OUTPUT_WORKPLAN.md
- /Users/wangwenjie/project/archetype-admin-path/scripts/create_run.rb
- /Users/wangwenjie/project/archetype-admin-path/scripts/contract/init_flow_run.rb
- /Users/wangwenjie/project/archetype-admin-path/scripts/contract/handoff_generation.rb
- /Users/wangwenjie/project/archetype-admin-path/scripts/prd/review_complete.rb

## 当前问题

现有实现里，`prd-05` 可以拆出多个 contract flows，但 contract run 的形态与 `init` / `prd` run 不统一。

需要修正为：

1. 每个 contract flow run 都是标准 run。
2. run 创建必须通过统一创建入口，不允许 AI 临时手写目录。
3. human 启动下一批时拿到的是提示词，不是 handoff YAML。
4. `prd-05` 完成回复必须先告诉下一步建议，再展示批次，最后列关键文件。

## 本轮必须完成的事情

### 0. 先做全链路入口扫描

本轮不允许只改一个地方。

在动手前，必须先用 `rg` 扫描所有会参与 `prd-05 -> contract flow run` 的脚本、提示词、review、materials、模板和 smoke。

至少检查：

- `scripts/create_run.rb`
- `scripts/prd/review_complete.rb`
- `scripts/prd/workflow_manifest.rb`
- `scripts/contract/init_flow_run.rb`
- `scripts/contract/handoff_generation.rb`
- `scripts/contract/workflow_manifest.rb`
- `scripts/contract/progress_board.rb`
- `scripts/contract/continue_run.rb`
- `scripts/contract/finalize_step.rb`
- `scripts/contract/review_complete.rb`
- `docs/templates/workflow-progress.template.md`
- `docs/templates/contract-progress.template.md`
- `docs/prd/prompts/`
- `docs/prd/reviewer/`
- `docs/contract/prompts/`
- `docs/contract/reviewer/`
- `docs/contract/steps/`
- `docs/contract/rules/`
- `docs/contract/templates/`
- `scripts/contract/*smoke*.rb`

重点搜索：

- `contract_handoff`
- `init_flow_run`
- `run-agent-prompt`
- `handoff.yaml`
- `pending_dependencies`
- `contract-progress`
- `review_complete`

要求：

1. 如果 run 结构改了，脚本、prompt、reviewer checklist、materials、template、progress board 和 smoke 必须同步更新。
2. 不允许只改 `init_flow_run.rb` 或只改一个 prompt，然后其它入口继续生成旧结构。
3. 不允许 reviewer、materials 或 execution checklist 仍然把 YAML 当 human 启动材料。
4. 最终汇报必须写清楚：扫描过哪些入口、哪些已同步修改、哪些确认无需修改。

### 1. 统一 contract flow run 创建入口

优先检查是否可以扩展 `scripts/create_run.rb` 支持 `contract` flow。

如果可以，直接扩展它。

如果直接扩展不合理，可以新增 contract wrapper，但 wrapper 必须复用和 `create_run.rb` 一致的标准目录、prompt、progress 规则，不能自己拼一套临时结构。

### 2. 标准化 contract run 目录

每个 `runs/YYYY-MM-DD-contract-<flow-id>/` 至少应包含：

```text
raw/
  request.md
  attachments/
prompts/
  run-agent-prompt.md
progress/
  workflow-progress.md
intake/
  contract-handoff.snapshot.yaml
  contract-handoff.snapshot.md
contract/
  working/
  release/
rendered/
archive/
```

要求：

- `raw/attachments/` 中放上游 handoff / final_prd 快照或索引引用。
- `intake/` 保留给 contract 机器流程读取。
- `prompts/run-agent-prompt.md` 是 human 新开上下文时使用的启动提示词。
- `progress/workflow-progress.md` 表达当前 flow 是 `ready` 还是 `pending_dependencies`。

### 3. 每个 flow 生成启动提示词

每个 `prompts/run-agent-prompt.md` 必须包含：

- 当前 flow 中文功能名
- 当前 flow 工作区路径
- 当前 flow 状态
- 前置依赖
- 当前 handoff 快照路径
- 本轮要产出的 contract 文件
- 禁止扩 scope 的约束
- 如果依赖未满足，应停止并提示先完成前置 flow

不要把 `contract_handoff/flows/*.handoff.yaml` 当成 human 的启动材料。

### 4. 修正 `prd-05` 完成回报

完成回报必须使用下面结构：

```md
# prd-05 已完成：合同交接已生成

## 下一步建议

如果没有异议，建议直接进入第 1 批：<批次中文名>。

- 当前上下文继续执行：直接说“执行第 1 批”
- 新开上下文执行：把启动提示词 `<prompt-path>` 交给 AI
- 如果批次名称、顺序或依赖关系不对，我们先修改 `contract_handoff`，不要进入 contract

## 本次拆出的功能批次

1. <批次中文名>
   工作区：`runs/YYYY-MM-DD-contract-<flow-id>/`
   状态：可开始
   本批目标：<用中文说清楚做什么功能>
   启动提示词：`runs/YYYY-MM-DD-contract-<flow-id>/prompts/run-agent-prompt.md`

2. <批次中文名>
   工作区：`runs/YYYY-MM-DD-contract-<flow-id>/`
   状态：等待第 1 批完成
   本批目标：<用中文说清楚做什么功能>
   启动提示词：`runs/YYYY-MM-DD-contract-<flow-id>/prompts/run-agent-prompt.md`

## 已生成的关键材料

- 总索引：`runs/<prd-run>/contract_handoff/contract-handoff.index.yaml`
- 人类总览：`runs/<prd-run>/contract_handoff/contract-handoff.md`
- 各批次 handoff：`runs/<prd-run>/contract_handoff/flows/`
- 各批次启动提示词：`runs/YYYY-MM-DD-contract-<flow-id>/prompts/run-agent-prompt.md`

## 异常或偏差

无。
```

注意：

- 不要写成“请确认是否按以上顺序执行”。
- 要写成“如果没有异议，建议直接进入下一批；如果有问题，我们先修改批次名称、顺序或依赖”。
- 不要问“是否现在创建并初始化这些标准 contract run 工作区”。
- 不要把文件清单放在最前面。
- 不要用 `batch-a -> batch-b` 这种链式表达代替逐条说明。

### 5. 补充验证

至少验证：

- `prd-05` 后每个 flow 有标准 run 外壳。
- 每个 flow 有 `prompts/run-agent-prompt.md`。
- pending flow 的进度状态不会误写为 ready。
- 完成回报能展示中文批次名、工作区、状态、本批目标、启动提示词。
- PRD prompt、contract prompt、reviewer checklist、materials 和 progress template 没有保留旧启动口径。

## 本轮禁止做的事情

- 不要改变 `init -> prd -> contract_handoff -> contract -> openapi/swagger -> develop` 主链。
- 不要重写前五步已完成的 contract 逻辑。
- 不要把 `contract_handoff` YAML 继续暴露成人类启动材料。
- 不要让 AI 临时创建三个不标准目录。
- 不要把 human 回报写成一段自然语言总结。
- 不要只改一个脚本或一个提示词；流程内所有相关入口必须同步处理。

## 输出要求

本轮结束时必须明确汇报：

1. contract run 创建入口怎么统一了。
2. 标准 run 目录补了哪些层。
3. 启动提示词生成在哪里。
4. `prd-05` 完成回报的新格式是什么。
5. 跑了哪些验证，还有哪些风险。
6. 扫描过哪些脚本、提示词、reviewer、materials、模板和 smoke，哪些已改，哪些确认无需修改。
