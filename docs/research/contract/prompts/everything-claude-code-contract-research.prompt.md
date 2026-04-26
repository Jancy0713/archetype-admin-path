# Prompt: Everything Claude Code Contract Research

你正在为本仓库设计一套新的 `contract` 标准流程做调研。

目标不是实现 `contract`，而是基于我们的现有系统设计，以及对 `affaan-m/everything-claude-code` 源码和结构的研读，产出一份“我们应该如何设计 contract”的方案草案。

## 研究对象

- 仓库：`https://github.com/affaan-m/everything-claude-code`

## 你的任务

1. 先研读本仓库当前与 `init / prd / contract` 相关的文档和上下文，至少包含：
   - `docs/exploration/MVP_WORKFLOW.md`
   - `docs/exploration/README.md`
   - `docs/prd/README.md`
   - `docs/prd/WORKFLOW_GUIDE.md`
   - `docs/research/contract/notes/2026-04-23-contract-foundation-notes.md`
2. 再系统研读 `affaan-m/everything-claude-code` 仓库源码和文档，不要只看 README、AGENTS.md 或 CLAUDE.md。
3. 重点分析它的这些方面：
   - 顶层目录结构如何组织 `agents / skills / commands / hooks / rules / mcp-configs / scripts / tests`
   - 它如何把“规则、命令、技能、自动化、代理协作”拆成不同层次
   - 它的可扩展性和长期维护性来自哪些结构决策
   - 它有哪些地方体现出“系统化、可演化、可运营”的设计
   - 如果把它的思想迁移到我们的 `contract` 体系，哪些点有帮助，哪些点不适合直接照搬
4. 最后输出一份面向我们仓库的方案文档，不是泛泛总结。

## 你必须回答的问题

1. 站在 `everything-claude-code` 的肩膀上，我们的 `contract` 应该被定义成什么？
2. `contract` 在我们当前主链路里，应该如何从“输入索引”进化成“正式系统”？
3. 我们是否应该为 `contract` 引入类似 `rules / prompts / templates / scripts / review / generated outputs` 的分层？
4. `contract` 的研究、生成、review、冻结、下游消费，是否应该拆成多个正式步骤？
5. 为了支持长期项目演化，`contract` 未来应如何组织目录和引用关系？
6. 如果未来按模块拆分 contract，跨模块依赖应该如何被记录和查找？
7. 哪些地方如果直接照搬 ECC，会让我们的体系过重或偏离重点？

## 输出要求

把结果写到：

- `/Users/wangwenjie/project/archetype-admin-path/docs/research/contract/findings/everything-claude-code-contract-research.md`

文档必须至少包含这些章节：

1. `Research Scope`
2. `What Everything Claude Code Actually Does`
3. `Structural Patterns Worth Reusing`
4. `Patterns We Should Not Copy Blindly`
5. `Proposed Contract System Shape For Our Repo`
6. `Proposed Contract Workflow MVP`
7. `Proposed Directory / Artifact Strategy`
8. `Cross-Module Reference Strategy`
9. `Open Questions`
10. `Recommended Next Step`

## 约束

- 你必须引用具体源码路径、文件或目录，而不是只谈 README 印象
- 你必须显式区分“从源码确认的事实”和“你基于事实做出的推断”
- 你不能开始实现任何 contract 模板、脚本或 schema
- 你只能产出调研分析文档
- 你的结论必须回到我们仓库当前上下文，不允许只写对方仓库的读书笔记
