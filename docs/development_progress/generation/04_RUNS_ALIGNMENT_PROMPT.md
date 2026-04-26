# Runs Alignment Prompt

你现在接手本仓库的 `generation` 正式流程 `04`：统一调整现有 `runs/`、examples、说明文档和 smoke，使其符合当前 multi generation entry 正式入口，并尽量把旧 generation 主路径清理干净。

开始前先明确：

- `Phase 1` 已完成：generation 新方向已定稿
- `Phase 2` 已完成：现有 generation 偏差审计已完成
- `Phase 3.0` 已完成：结构收口与第一批 bridge 抓手已完成
- `Phase 3.5` 已完成：多 generation 起点方案已定稿
- `Phase 3.6` 已完成：旧资产直接收敛方案已定稿
- 当前现在要做的是 `04`
- 当前还不能进入 generation 内部开发

## 开始前必须阅读

- [docs/development_progress/DEVELOPMENT_CONTEXT_PRINCIPLES.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/DEVELOPMENT_CONTEXT_PRINCIPLES.md)
- [docs/development_progress/README.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/README.md)
- [docs/development_progress/generation/README.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/generation/README.md)
- [docs/development_progress/generation/03_STRUCTURE_CLEANUP_DECISION.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/generation/03_STRUCTURE_CLEANUP_DECISION.md)
- [docs/development_progress/generation/03_CONTRACT_TO_GENERATION_BRIDGE_DEFINITION.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/generation/03_CONTRACT_TO_GENERATION_BRIDGE_DEFINITION.md)
- [docs/development_progress/generation/03_5_MULTI_GENERATION_ENTRY_DEFINITION.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/generation/03_5_MULTI_GENERATION_ENTRY_DEFINITION.md)
- [docs/development_progress/generation/03_6_LEGACY_CONVERGENCE_DEFINITION.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/generation/03_6_LEGACY_CONVERGENCE_DEFINITION.md)
- [docs/development_progress/generation/04_RUNS_ALIGNMENT_WORKPLAN.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/generation/04_RUNS_ALIGNMENT_WORKPLAN.md)

如需核对历史资产，再按需阅读：

- [docs/development_progress/generation/02_EXISTING_GENERATION_AUDIT.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/generation/02_EXISTING_GENERATION_AUDIT.md)

## 本轮任务目标

你这次不是实现 generation，而是做下面四件事：

1. 盘点旧样例、旧 README、旧 smoke 与 run 产物里仍残留的旧入口
2. 把它们统一调整到新的 multi-entry 语义
3. 尽量把旧 generation 主路径从正式叙事中清理出去
4. 给下一轮主链验证准备唯一正式依据

## 你必须遵守的边界

- 不把单个 `contract_id` kickoff 继续当成正式入口
- 不把 `generation_manifest.yaml` 继续写成 generation 唯一正式输入
- 不把旧 `generation-run.yaml` / `generation-output-manifest.yaml` 继续当成 bridge 主线样例
- 不提前实现 `openapi.yaml` 生成逻辑
- 不直接进入 generation reviewer / publish / lifecycle 设计

## 本轮优先产出

- 旧路径到新 multi-entry 路径的映射
- 更新后的 runs/examples 样例
- 清理后的 README / smoke 口径
- 下一轮 `05` 主链验证所需的验证清单与 prompt 入口

## 执行顺序

1. 先按 `03.5/03.6` 文档确认正式边界
2. 盘点 `runs/`、examples、README、smoke 里残留的错误 generation 入口
3. 先做样例与目录语义对齐
4. 再清 README、guide、smoke 清单中的旧主路径叙事
5. 最后整理下一轮 `05` 验证入口
6. 停在验证准备完成处，不进入 generation 内部开发
