# Multi Generation Entry Prompt

你现在接手本仓库的 `generation` 正式流程 `03.5`：把 `contract => generation` 修正为“批量创建多个 generation 起点”。

开始前先明确：

- `01` 已完成：generation 基本方向已定稿
- `02` 已完成：现有 generation 偏差审计已完成
- `03.0` 已完成：历史收口与第一批 bridge 抓手已落下
- 当前要做的是 `03.5`
- 当前不要进入 `04/05`
- 当前不要进入 generation 内部开发

## 开始前必须阅读

- [docs/development_progress/DEVELOPMENT_CONTEXT_PRINCIPLES.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/DEVELOPMENT_CONTEXT_PRINCIPLES.md)
- [docs/development_progress/README.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/README.md)
- [docs/development_progress/generation/README.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/generation/README.md)
- [docs/development_progress/generation/01_GENERATION_DIRECTION_WORKPLAN.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/generation/01_GENERATION_DIRECTION_WORKPLAN.md)
- [docs/development_progress/generation/02_EXISTING_GENERATION_AUDIT.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/generation/02_EXISTING_GENERATION_AUDIT.md)
- [docs/development_progress/generation/03_5_MULTI_GENERATION_ENTRY_WORKPLAN.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/generation/03_5_MULTI_GENERATION_ENTRY_WORKPLAN.md)
- [docs/development_progress/generation/03_5_MULTI_GENERATION_ENTRY_DEFINITION.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/generation/03_5_MULTI_GENERATION_ENTRY_DEFINITION.md)

如需核对 `03.0` 结果，再按需阅读：

- [docs/development_progress/generation/03_STRUCTURE_CLEANUP_DECISION.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/generation/03_STRUCTURE_CLEANUP_DECISION.md)
- [docs/development_progress/generation/03_CONTRACT_TO_GENERATION_BRIDGE_DEFINITION.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/generation/03_CONTRACT_TO_GENERATION_BRIDGE_DEFINITION.md)

## 当前已确认方向

- 一个 published contract 对应一个 generation 起点
- 系统应一次性为用户准备多个 generation 起点
- 用户自己决定先做哪个 generation
- AI 可以给推荐顺序，但不能把用户锁死在唯一顺序上
- 有依赖关系的要写清楚
- 平行关系的也要写清楚
- generation 起点应自动准备初始化材料

## 本轮必须解决的问题

1. generation 起点的正式目录结构是什么
2. `request.md` 是否自动生成，以及应该写什么
3. contract 输入材料如何注入 generation 起点
4. 每个 generation 起点的说明文档应该写什么
5. 总览文档应该如何告诉用户推荐顺序、依赖关系和平行关系

## 本轮优先产出

- 修正后的 `contract => generation` 正式文档
- 多 generation 起点的结构定义
- 给下一轮代码实现使用的正式依据

## 本轮不应直接展开

- generation 内部真实代码生成器
- generation 测试执行器
- generation GUI

## 执行顺序

1. 先修正文档口径
2. 再定 generation 起点结构
3. 再定批量创建 workflow
4. 停在文档定稿处，等待下一轮实际开发
