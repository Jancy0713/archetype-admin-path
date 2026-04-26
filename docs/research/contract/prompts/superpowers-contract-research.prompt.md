# Prompt: Superpowers Contract Research

你正在为本仓库设计一套新的 `contract` 标准流程做调研。

目标不是实现 `contract`，而是基于我们的现有系统设计，以及对 `obra/superpowers` 源码和结构的研读，产出一份“我们应该如何设计 contract”的方案草案。

## 研究对象

- 仓库：`https://github.com/obra/superpowers`

## 你的任务

1. 先研读本仓库当前与 `init / prd / contract` 相关的文档和上下文，至少包含：
   - `docs/exploration/MVP_WORKFLOW.md`
   - `docs/exploration/README.md`
   - `docs/prd/README.md`
   - `docs/prd/WORKFLOW_GUIDE.md`
   - `docs/research/contract/notes/2026-04-23-contract-foundation-notes.md`
2. 再系统研读 `obra/superpowers` 仓库源码和文档，不要只看 README。
3. 重点分析它的这些方面：
   - 顶层目录结构如何组织 `agents / skills / commands / hooks / docs / tests`
   - 它的核心工作流如何从“想法”推进到“设计、计划、执行、review、收尾”
   - 它如何把“原则”固化成可复用结构，而不是只写成长文档
   - 它有哪些值得借鉴的 prompt / skill / workflow 分层方式
   - 如果把它的思想迁移到我们的 `contract` 体系，哪些点有帮助，哪些点不适合直接照搬
4. 最后输出一份面向我们仓库的方案文档，不是泛泛总结。

## 你必须回答的问题

1. 站在 `superpowers` 的肩膀上，我们的 `contract` 应该被定义成什么？
2. `contract` 在我们当前主链路里，应该处在什么位置？
3. `contract` 应该有哪些正式阶段或步骤？
4. 哪些内容应该进 `contract artifact`，哪些内容仍应留在 `final_prd`？
5. 我们是否应该像 `superpowers` 一样，把 `contract` 拆成规则、模板、步骤材料、reviewer、执行入口？
6. 如果这样做，最小 MVP 应该先落哪几块？
7. 哪些地方如果直接照搬 `superpowers`，会和我们的项目不匹配？

## 输出要求

把结果写到：

- `/Users/wangwenjie/project/archetype-admin-path/docs/research/contract/findings/superpowers-contract-research.md`

文档必须至少包含这些章节：

1. `Research Scope`
2. `What Superpowers Actually Does`
3. `Patterns Worth Reusing`
4. `Patterns We Should Not Copy Blindly`
5. `Proposed Contract Definition For Our System`
6. `Proposed Contract Workflow MVP`
7. `Implications For final_prd -> contract`
8. `Open Questions`
9. `Recommended Next Step`

## 约束

- 你必须引用具体源码路径、文件或目录，而不是只谈 README 印象
- 你必须显式区分“从源码确认的事实”和“你基于事实做出的推断”
- 你不能开始实现任何 contract 模板、脚本或 schema
- 你只能产出调研分析文档
- 你的结论必须回到我们仓库当前上下文，不允许只写对方仓库的读书笔记
