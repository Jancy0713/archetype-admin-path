# Development Progress

这个目录用于集中管理“开发推进”材料，而不是业务流程正文或 research 材料。

统一用途：

- 记录每一轮开发循环的 workplan
- 记录每一轮开发循环对应的执行 prompt
- 记录用户补充且影响后续推进的上下文增量
- 记录用户明确说“先放一下、后面再优化”的 pending items

统一边界：

- 业务文档继续放在各自领域目录下，例如 `docs/contract/`、`docs/prd/`、`docs/init/`
- research 文档继续放在 `docs/research/`
- 开发推进材料统一放在这里，不再混放到 research 或业务正文目录

## Global Files

1. [DEVELOPMENT_CONTEXT_PRINCIPLES.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/DEVELOPMENT_CONTEXT_PRINCIPLES.md)
   - 记录会持续影响后续开发方向的用户共识与设计原则
2. [PENDING_ITEMS.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/PENDING_ITEMS.md)
   - 只记录用户明确说“先放一下、后面再优化”的事项，不记录下一步立即要做的工作

## Cycle Rules

从现在开始，后续项目都统一按这个循环推进：

1. 先写计划
2. 再写该计划的开始提示词
3. 再按计划实际开发
4. 当前开发完成后，立刻写下一步计划
5. 下一轮开发开始前，先回看并更新 `DEVELOPMENT_CONTEXT_PRINCIPLES.md`
6. 用户明确说“先放一下、后面再优化”的内容，先记入 `PENDING_ITEMS.md`

补充约束：

1. 每一个新的循环开始之前，都要先把当前可沉淀的用户共识整理进 `DEVELOPMENT_CONTEXT_PRINCIPLES.md`
2. 每一个新的循环开始之前，都要先把“用户明确要求先放一下、后面再优化”的事项整理进 `PENDING_ITEMS.md`
3. 如果执行中发现计划缺项、顺序不对或必须新增工作项，必须先更新计划，再继续开发
4. 每一个循环都要保留编号和状态，便于回放和续接

## Project Index

1. [contract-new](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/contract-new/README.md)
   - 当前正式入口
2. [contract](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/contract/README.md)
   - 历史记录，不是当前正式入口
3. [generation](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/generation/README.md)
   - 历史记录，不是当前正式入口
