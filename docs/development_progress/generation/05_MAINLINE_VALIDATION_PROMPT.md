你现在接手本仓库的 `generation` 正式流程 `05`：验证当前 `contract => bridge => standalone generation runs` 主链是否已经收稳。

开始前先明确：

- 当前正式语义已经改为：`one published contract = one generation run`
- generation run 直接创建在 `runs/` 下
- 源 run 只保留 bridge 总览，不再保留正式 `generation/<contract_id>/` 子目录
- 当前还不能进入 generation 内部开发

开始前必须阅读：

- `docs/development_progress/DEVELOPMENT_CONTEXT_PRINCIPLES.md`
- `docs/development_progress/generation/README.md`
- `docs/development_progress/generation/03_5_MULTI_GENERATION_ENTRY_DEFINITION.md`
- `docs/development_progress/generation/03_6_LEGACY_CONVERGENCE_DEFINITION.md`
- `docs/development_progress/generation/04_RUNS_ALIGNMENT_WORKPLAN.md`
- `docs/development_progress/generation/05_MAINLINE_VALIDATION_WORKPLAN.md`

本轮任务目标：

1. 验证 bridge 产物是否稳定生成多个独立 generation runs
2. 验证每个 generation run 的 `run.yaml`、`request.md`、`README.md`、`inputs/`
3. 验证 README / examples / smoke 是否已不再依赖 nested generation 结构
4. 给后续 generation 内部开发确认唯一正式 run 结构

停在主链验证完成处，不进入 generation 内部开发。
