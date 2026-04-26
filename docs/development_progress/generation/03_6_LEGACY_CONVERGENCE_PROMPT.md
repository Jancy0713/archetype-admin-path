# Legacy Convergence Prompt

你现在接手本仓库的 `generation` 正式流程 `03.6`：把旧 generation 资产直接收敛到最新正式方案，尽量不留历史包袱。

开始前先明确：

- `01` 已完成：generation 基本方向已定稿
- `02` 已完成：现有 generation 偏差审计已完成
- `03.0` 已完成：桥接定义与历史收口已完成
- `03.5` 已完成：multi generation entry 正式方案已定稿
- 当前要做的是 `03.6`
- 当前不要进入 `04/05`
- 当前不要进入 generation 内部开发

## 开始前必须阅读

- [docs/development_progress/DEVELOPMENT_CONTEXT_PRINCIPLES.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/DEVELOPMENT_CONTEXT_PRINCIPLES.md)
- [docs/development_progress/README.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/README.md)
- [docs/development_progress/generation/README.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/generation/README.md)
- [docs/development_progress/generation/02_EXISTING_GENERATION_AUDIT.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/generation/02_EXISTING_GENERATION_AUDIT.md)
- [docs/development_progress/generation/03_5_MULTI_GENERATION_ENTRY_DEFINITION.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/generation/03_5_MULTI_GENERATION_ENTRY_DEFINITION.md)
- [docs/development_progress/generation/03_6_LEGACY_CONVERGENCE_WORKPLAN.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/generation/03_6_LEGACY_CONVERGENCE_WORKPLAN.md)
- [docs/development_progress/generation/03_6_LEGACY_CONVERGENCE_DEFINITION.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/generation/03_6_LEGACY_CONVERGENCE_DEFINITION.md)

如需核对历史收口结果，再按需阅读：

- [docs/development_progress/generation/03_STRUCTURE_CLEANUP_DECISION.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/generation/03_STRUCTURE_CLEANUP_DECISION.md)
- [docs/development_progress/generation/03_CONTRACT_TO_GENERATION_BRIDGE_DEFINITION.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/generation/03_CONTRACT_TO_GENERATION_BRIDGE_DEFINITION.md)

## 本轮目标

- 明确旧 generation 资产哪些直接保留
- 明确哪些应该直接改造成最新正式入口
- 明确哪些应该删除或降级为历史记录
- 避免下一轮实现时继续背着历史包袱并行维护旧路径

## 本轮优先产出

- 旧资产分类清单
- 直接改造 / 迁名 / 删除策略
- 给 `04` runs/examples 对齐和 `05` 主链验证使用的正式依据

## 本轮不应直接展开

- generation 内部真实生成器
- generation 测试执行器
- generation GUI

## 执行顺序

1. 先盘点旧资产角色
2. 再定直接收敛策略
3. 再定给 `04/05` 的迁移依据
4. 停在文档定稿处
