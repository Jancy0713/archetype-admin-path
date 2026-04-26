# [PLANNED] Contract New Step 6 Workplan

这一步是 `contract-new` 的第六轮修正。

它不改变新版主链：

```text
init -> prd -> contract_handoff -> contract -> openapi/swagger -> develop
```

它修正两个已经暴露出来的体验问题：

1. `prd-05 contract_handoff` 拆出的多个 contract flow run，必须像 `init` / `prd` run 一样是标准化、独立可继续执行的工作区。
2. `prd-05` 完成后给 human 的回复必须有固定结构，先告诉下一步怎么做，再展示批次、路径和启动提示词，最后才列关键文件。

## 这一步的唯一目标

把 `prd-05 -> contract flow run` 的落盘方式和 human 回报格式标准化。

## 必须成立的事实

1. 每个 `runs/YYYY-MM-DD-contract-<flow-id>/` 都是一个独立 run，不要求 human 再去别的 `runs/<prd-run>/` 里找材料才能继续。
2. contract flow run 不能由 AI 临时 `mkdir` 拼目录；必须通过统一创建入口生成标准结构。
3. 每个 contract flow run 必须包含可直接交给 AI 的启动提示词，而不是只把 handoff YAML 当成启动材料。
4. `prd-05` 完成回报必须用固定格式，不能自然语言堆一段让人自己提取重点。
5. 批次顺序和名称可以让 human 二次修改，但默认表达应是“如果没问题，建议直接执行下一步”，不是阻塞式“请确认”。

## 标准 contract flow run 形态

当 `prd-05` 拆出多个 contract flows 后，后续进入 contract 的每个 flow 都应以标准 run 形态存在：

```text
runs/YYYY-MM-DD-contract-<flow-id>/
  raw/
    request.md
    attachments/
      contract-handoff.snapshot.yaml
      contract-handoff.snapshot.md
      source-final-prd.snapshot.yaml
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

说明：

- `raw/`、`prompts/`、`progress/` 是和 `init` / `prd` 对齐的标准 run 外壳。
- `intake/` 保留为 contract 机器流程的正式输入快照。
- `raw/attachments/` 保留 human 和 AI 容易理解的上游材料快照。
- `prompts/run-agent-prompt.md` 是 human 真正拿来启动该 flow 的材料。
- `contract/working/` 是过程态。
- `contract/release/` 是后续 `develop` 能消费的正式包。

## 创建规则

第六步要把 contract flow run 的创建方式统一成下面一种口径：

1. `prd-05` 负责从 `final_prd` 生成 `contract_handoff/`。
2. 需要生成 contract flow run 时，必须调用统一创建入口。
3. 推荐扩展现有 `scripts/create_run.rb` 支持 `contract` flow，或提供一个内部复用同一套模板的 contract wrapper。
4. 禁止 AI 在执行过程中自己手写三套临时目录。
5. 对有前置依赖的 flow，可以先生成标准 run，但 `progress` 必须写清楚 `pending_dependencies`，不能让人误以为已经可直接开工。

## 全链路同步修改要求

第六步不是只改一个脚本入口。

AI 执行时必须先扫描并同步处理所有会参与 `prd-05 -> contract flow run` 的正式入口，至少包括：

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

执行要求：

1. 先用 `rg` 找出所有旧口径，包括 `contract_handoff`、`init_flow_run`、`run-agent-prompt`、`handoff.yaml`、`pending_dependencies`、`contract-progress`、`review_complete`。
2. 如果某个改动影响 run 结构，必须同步更新脚本、prompt、reviewer checklist、materials、template、progress board 和 smoke。
3. 不允许只改 `init_flow_run.rb` 或只改一个 prompt，然后留下其它入口继续生成旧结构。
4. 不允许让 reviewer、materials 或 execution checklist 仍然把 YAML 当 human 启动材料。
5. 完成时必须汇报“扫描过哪些入口、哪些已同步修改、哪些确认无需修改”。

## 启动材料规则

human 面前的“启动材料”必须是提示词，不是 YAML。

每个 flow 至少要有：

```text
runs/YYYY-MM-DD-contract-<flow-id>/prompts/run-agent-prompt.md
```

这个提示词必须说明：

- 当前 flow 要做什么功能
- 当前 flow 的工作区路径
- 当前 flow 的状态是 `ready` 还是 `pending_dependencies`
- 上游 handoff 快照在哪里
- contract 本轮应该产出哪些文件
- 不允许读取整份 `final_prd` 后自行扩 scope
- 如果依赖未满足，必须停止并提示先完成前置 flow

## prd-05 完成回报标准格式

`prd-05` 完成后，AI 必须按下面结构回复：

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

## 回报格式纪律

1. 第一屏先说下一步，不先列文件。
2. 批次必须一行一个，不用 `batch-a -> batch-b` 这种中英文混杂链式表达。
3. 每个批次都要有中文功能名、工作区、状态、本批目标、启动提示词。
4. 文件清单放最后，只列关键材料。
5. 不要问“是否现在创建并初始化这些标准 contract run 工作区”。这是流程实现细节，不应抛给 human。
6. 不要把 `handoff.yaml` 说成启动材料；它只是启动提示词会读取的输入快照。

## 执行范围

### A. 统一 contract run 创建入口

- 检查 `scripts/create_run.rb` 是否适合扩展 `contract` flow。
- 如果扩展成本合理，直接支持 `contract`。
- 如果不适合，新增 contract wrapper，但必须复用同一套标准目录和 prompt/progress 模板。

### B. 标准化 contract run 外壳

- 为 contract run 补齐 `raw/`、`prompts/`、`progress/`、`rendered/`、`archive/`。
- 保留现有 `intake/`、`contract/working/`、`contract/release/` 语义。
- 确保单个 contract run 不依赖 human 手动回源 PRD run 找材料。

### C. 生成每个 flow 的启动提示词

- 每个 flow run 必须有 `prompts/run-agent-prompt.md`。
- 提示词要能直接被新上下文 AI 使用。
- 提示词不能要求 AI 自己猜顺序、依赖、范围。

### D. 修正 prd-05 完成回报

- 把完成回报固定为本 workplan 中的标准结构。
- 下一步建议要写成非阻塞建议：
  - 如果没问题，建议直接执行下一步。
  - 如果有问题，先修改批次名称、顺序或依赖。

### E. 补验证

至少补一条 smoke 或回归断言：

- `prd-05` 后能看到标准 contract run 外壳。
- 每个 flow 都有启动提示词。
- pending flow 不会被误标为 ready。
- human output 生成逻辑不再把 YAML 当启动材料。
- PRD prompt、contract prompt、reviewer checklist、materials 和 progress template 不再保留旧启动口径。

## 完成标准

1. `prd-05` 拆出的每个 contract flow 都有标准 run 工作区。
2. 每个 flow run 都能独立继续执行，不依赖 human 翻找上游 run。
3. 每个 flow run 都有可直接交给 AI 的启动提示词。
4. `prd-05` 完成回报符合固定格式。
5. 文档里不再把 handoff YAML 描述成人类启动材料。
6. 所有相关脚本、提示词、reviewer、materials、模板和 smoke 已同步更新或明确确认无需修改。

## 建议交给 AI 的一句话任务

完成第六步：把 `prd-05` 后生成的 contract flow run 改成和 `init` / `prd` 对齐的标准独立 run，统一通过创建入口生成，并把 `prd-05` 完成回报改成固定结构，优先告诉 human 下一步建议和每个功能批次的启动提示词。
