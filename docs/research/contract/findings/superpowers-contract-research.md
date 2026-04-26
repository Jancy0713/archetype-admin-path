# Superpowers Contract Research

## Research Scope

本次调研只回答一个问题：在我们当前 `init -> prd -> contract -> generation` 主链路里，如何借鉴 `obra/superpowers` 的结构化方法，设计出适合本仓库的 `contract` 流程 MVP。

### In-scope

- 我们仓库当前上下文：
  - [`docs/exploration/MVP_WORKFLOW.md`](/Users/wangwenjie/project/archetype-admin-path/docs/exploration/MVP_WORKFLOW.md)
  - [`docs/exploration/README.md`](/Users/wangwenjie/project/archetype-admin-path/docs/exploration/README.md)
  - [`docs/prd/README.md`](/Users/wangwenjie/project/archetype-admin-path/docs/prd/README.md)
  - [`docs/prd/WORKFLOW_GUIDE.md`](/Users/wangwenjie/project/archetype-admin-path/docs/prd/WORKFLOW_GUIDE.md)
  - [`docs/research/contract/notes/2026-04-23-contract-foundation-notes.md`](/Users/wangwenjie/project/archetype-admin-path/docs/research/contract/notes/2026-04-23-contract-foundation-notes.md)
  - [`scripts/prd/workflow_manifest.rb`](/Users/wangwenjie/project/archetype-admin-path/scripts/prd/workflow_manifest.rb)
- `obra/superpowers` 的目录、技能、hook、命令、测试与平台装配层，而不只看 README。

### Research Sources

以下是本次直接引用过的 `superpowers` 源码路径或文件：

- 根目录与结构入口：
  - [`README.md`](https://github.com/obra/superpowers/blob/main/README.md)
  - [`package.json`](https://github.com/obra/superpowers/blob/main/package.json)
  - [`CLAUDE.md`](https://github.com/obra/superpowers/blob/main/CLAUDE.md)
- 平台装配：
  - [`.claude-plugin/plugin.json`](https://github.com/obra/superpowers/blob/main/.claude-plugin/plugin.json)
  - [`.claude-plugin/marketplace.json`](https://github.com/obra/superpowers/blob/main/.claude-plugin/marketplace.json)
  - [`.codex/INSTALL.md`](https://github.com/obra/superpowers/blob/main/.codex/INSTALL.md)
  - [`docs/README.codex.md`](https://github.com/obra/superpowers/blob/main/docs/README.codex.md)
- 结构目录：
  - [`agents/`](https://github.com/obra/superpowers/tree/main/agents)
  - [`commands/`](https://github.com/obra/superpowers/tree/main/commands)
  - [`docs/`](https://github.com/obra/superpowers/tree/main/docs)
  - [`docs/superpowers/specs`](https://github.com/obra/superpowers/tree/main/docs/superpowers/specs)
  - [`docs/superpowers/plans`](https://github.com/obra/superpowers/tree/main/docs/superpowers/plans)
  - [`hooks/`](https://github.com/obra/superpowers/tree/main/hooks)
  - [`skills/`](https://github.com/obra/superpowers/tree/main/skills)
  - [`tests/`](https://github.com/obra/superpowers/tree/main/tests)
- 关键技能与模板：
  - [`skills/using-superpowers/SKILL.md`](https://github.com/obra/superpowers/blob/main/skills/using-superpowers/SKILL.md)
  - [`skills/brainstorming/SKILL.md`](https://github.com/obra/superpowers/blob/main/skills/brainstorming/SKILL.md)
  - [`skills/writing-plans/SKILL.md`](https://github.com/obra/superpowers/blob/main/skills/writing-plans/SKILL.md)
  - [`skills/executing-plans/SKILL.md`](https://github.com/obra/superpowers/blob/main/skills/executing-plans/SKILL.md)
  - [`skills/subagent-driven-development/SKILL.md`](https://github.com/obra/superpowers/blob/main/skills/subagent-driven-development/SKILL.md)
  - [`skills/subagent-driven-development/implementer-prompt.md`](https://github.com/obra/superpowers/blob/main/skills/subagent-driven-development/implementer-prompt.md)
  - [`skills/subagent-driven-development/spec-reviewer-prompt.md`](https://github.com/obra/superpowers/blob/main/skills/subagent-driven-development/spec-reviewer-prompt.md)
  - [`skills/subagent-driven-development/code-quality-reviewer-prompt.md`](https://github.com/obra/superpowers/blob/main/skills/subagent-driven-development/code-quality-reviewer-prompt.md)
  - [`skills/requesting-code-review/SKILL.md`](https://github.com/obra/superpowers/blob/main/skills/requesting-code-review/SKILL.md)
  - [`skills/requesting-code-review/code-reviewer.md`](https://github.com/obra/superpowers/blob/main/skills/requesting-code-review/code-reviewer.md)
  - [`skills/test-driven-development/SKILL.md`](https://github.com/obra/superpowers/blob/main/skills/test-driven-development/SKILL.md)
  - [`skills/writing-skills/SKILL.md`](https://github.com/obra/superpowers/blob/main/skills/writing-skills/SKILL.md)
- 触发与测试：
  - [`hooks/hooks.json`](https://github.com/obra/superpowers/blob/main/hooks/hooks.json)
  - [`hooks/session-start`](https://github.com/obra/superpowers/blob/main/hooks/session-start)
  - [`docs/testing.md`](https://github.com/obra/superpowers/blob/main/docs/testing.md)
  - [`tests/claude-code/README.md`](https://github.com/obra/superpowers/blob/main/tests/claude-code/README.md)
  - [`tests/claude-code/test-subagent-driven-development-integration.sh`](https://github.com/obra/superpowers/blob/main/tests/claude-code/test-subagent-driven-development-integration.sh)
  - [`tests/skill-triggering/run-test.sh`](https://github.com/obra/superpowers/blob/main/tests/skill-triggering/run-test.sh)
  - [`tests/subagent-driven-dev/run-test.sh`](https://github.com/obra/superpowers/blob/main/tests/subagent-driven-dev/run-test.sh)

## What Superpowers Actually Does

### Source-confirmed facts

1. `superpowers` 不是只提供一篇方法论 README，而是把工作流拆进仓库结构里。
   - 根目录存在 `agents/`, `commands/`, `docs/`, `hooks/`, `skills/`, `tests/` 等一级目录，说明它把角色、入口、文档、触发器和验证都做成了并列构件，而不是仅靠单文档约束。
   - `README.md` 的 “Basic Workflow” 明确列出 `brainstorming -> using-git-worktrees -> writing-plans -> subagent-driven-development/executing-plans -> requesting-code-review -> finishing-a-development-branch` 这条主链。

2. 它的核心单元不是“长文档”，而是 `skills/<name>/SKILL.md`。
   - `skills/using-superpowers/SKILL.md` 负责把“先找 skill 再行动”变成会话级纪律。
   - `skills/brainstorming/SKILL.md` 负责把想法先收敛成 design/spec。
   - `skills/writing-plans/SKILL.md` 负责把 spec 变成可执行 plan。
   - `skills/executing-plans/SKILL.md` 与 `skills/subagent-driven-development/SKILL.md` 负责执行。
   - `skills/requesting-code-review/SKILL.md` 与 `skills/requesting-code-review/code-reviewer.md` 负责 review。

3. 它把“流程产物”落到了固定目录，而不是只存在对话里。
   - `skills/brainstorming/SKILL.md` 要求把设计文档写到 `docs/superpowers/specs/YYYY-MM-DD--design.md`。
   - `skills/writing-plans/SKILL.md` 要求把实现计划写到 `docs/superpowers/plans/YYYY-MM-DD-.md`。
   - `docs/superpowers/` 目录下确实存在 `specs/` 与 `plans/` 两个子目录。

4. 它把“原则”进一步拆成可复用 prompt 模板。
   - `skills/subagent-driven-development/implementer-prompt.md` 不是讲道理，而是规定了 implementer 子代理接收到的上下文结构、状态回传格式和升级条件。
   - `spec-reviewer-prompt.md` 要求 reviewer 不得信任 implementer 报告，必须独立读代码对照规格。
   - `code-quality-reviewer-prompt.md` 则把 spec review 之后的质量 review 交给单独的 reviewer 模板。

5. 它保留了命令层，但命令层已明显退居次要位置。
   - `commands/brainstorm.md`, `commands/write-plan.md`, `commands/execute-plan.md` 都是 deprecated stub，正文直接让用户改用对应 skill。
   - 这说明 `superpowers` 的正式抽象不是 command，而是 skill。

6. 它有 hook 注入层，把“先使用 superpowers”从自觉行为变成启动时环境注入。
   - `hooks/hooks.json` 把 `SessionStart` 绑定到 `hooks/session-start`。
   - `hooks/session-start` 会读取 `skills/using-superpowers/SKILL.md`，然后把它注入到会话上下文里。

7. 它有真实测试，不只是“建议这样做”。
   - `tests/skill-triggering/run-test.sh` 用自然语言 prompt 检查 skill 是否会被自动触发。
   - `tests/claude-code/test-subagent-driven-development-integration.sh` 会构造最小项目、写入计划、调用 Claude headless 执行，再检查是否真的触发 skill、是否创建实现文件、是否产生 commits。
   - `docs/testing.md` 明确把 skill 测试定义为通过真实会话 transcript 来验证 workflow 行为。

### Inference based on facts

- `superpowers` 的核心贡献不在“发明了一条软件流程”，而在于它把流程拆成了可以被 agent 搜索、触发、组合、测试、审查的结构单元。
- 对它来说，README 只是导航；真正决定行为的是 `SKILL.md + prompt templates + hooks + tests + output directories`。

## Patterns Worth Reusing

### 1. 把 `contract` 视为独立流程产物，不把它混进 `final_prd`

事实依据：

- 我们自己的 [`docs/prd/README.md`](/Users/wangwenjie/project/archetype-admin-path/docs/prd/README.md) 已把 `contract` 放在 `prd-04 final_prd` 之后。
- [`docs/prd/WORKFLOW_GUIDE.md`](/Users/wangwenjie/project/archetype-admin-path/docs/prd/WORKFLOW_GUIDE.md) 和 [`scripts/prd/workflow_manifest.rb`](/Users/wangwenjie/project/archetype-admin-path/scripts/prd/workflow_manifest.rb) 都把 PRD 正式步骤止于 `prd-04`，然后才进入 `contract`。
- `superpowers` 也是 `spec` 与 `plan` 分离：`brainstorming` 产出 `specs/`，`writing-plans` 产出 `plans/`。

可复用结论：

- 我们也应该把 `contract` 视为和 `final_prd` 不同的正式 artifact 层。
- `final_prd` 负责“业务意图、范围、批次、确认结论”；`contract` 负责“实现边界、资源结构、字段/状态/权限/接口/校验约束”。

### 2. 把规则、模板、步骤材料、reviewer、入口分层，而不是把 contract 写成一篇总说明

事实依据：

- `superpowers` 至少有这些层次：
  - `skills/*/SKILL.md`：流程规则
  - `skills/.../*.md`：子 prompt 模板
  - `agents/code-reviewer.md`：专用 reviewer 角色
  - `hooks/`：会话触发
  - `tests/`：行为验证
  - `docs/superpowers/specs|plans`：产物目录

可复用结论：

- 我们的 `contract` 也不应只有一个模板文件。
- 最小可维护分层建议至少包含：
  - `rules/`：该步骤能写什么、不能写什么
  - `templates/`：结构化 artifact 模板
  - `steps/`：每一步的输入输出与材料索引
  - `reviewer/`：独立 reviewer 规则
  - `prompts/`：主 agent 与 reviewer 的 prompt 入口

### 3. 把 reviewer 变成正式关口，而不是写完就算

事实依据：

- `superpowers` 的 `subagent-driven-development` 明确要求每个任务先过 spec compliance review，再过 code quality review。
- `skills/requesting-code-review/SKILL.md` 规定 review 不是可选动作，而是开发中反复出现的正式动作。
- 我们自己的 PRD 流程也已经坚持 reviewer 独立性。

可复用结论：

- `contract` 也应该继承 PRD 的 reviewer discipline。
- 至少需要一个 `contract reviewer`，专门检查：
  - 是否超出 `final_prd` 已确认范围
  - 是否存在未显式确认的字段/状态/权限假设
  - 是否满足前后端与脚本消费的最低完备性
  - 是否存在命名漂移、资源重复定义、批次越界

### 4. 把“过程原则”沉入模板与材料，而不是依赖 agent 记忆

事实依据：

- `writing-plans` 不只说“写计划”，而是规定 plan header、task 粒度、每步必须带文件路径与验证命令。
- `writing-skills` 不只讲“如何写 skill”，而是把 description 如何写、何时拆 supporting file、如何做测试都写成明确约束。

可复用结论：

- 我们的 `contract` 也应把“什么必须填、什么禁止含糊、什么必须引用上游 batch 输入”固化在模板和 validator 里。
- 否则 `contract` 只会退化成“final_prd 的另一份自然语言改写”。

### 5. 为 `contract` 预留测试/验证思路

事实依据：

- `superpowers` 用 `tests/skill-triggering` 检验触发是否生效，用 `tests/claude-code/*integration*` 检验整条工作流是否按设计运行。

可复用结论：

- 我们短期不需要实现完整自动测试，但设计时就应把验证对象想清楚：
  - artifact 是否能通过 schema/validator
  - reviewer 是否能挡住越界假设
  - 一个 batch 的 `contract` 是否足够驱动前端类型/mock/页面骨架和后端 DTO/route 输入建议

## Patterns We Should Not Copy Blindly

### 1. 不要照搬它的“从会话开始就先强制 skill”

事实依据：

- `using-superpowers` + `hooks/session-start` 试图从每次会话开始就把所有工作拉入 superpowers discipline。

为什么不适合我们：

- 我们当前问题不是“通用 coding agent 如何统一行为”，而是“仓库内一条特定 `contract` 标准流程如何定义”。
- 若直接照搬，会把范围从 `contract` 设计研究扩张成“全局代理框架改造”，偏离当前目标。

结论：

- 我们现阶段只需要在 `contract` 流程内部强约束，不需要先做全仓通用 hook 注入。

### 2. 不要照搬它的实现导向流程名词

事实依据：

- `superpowers` 的主链路是 `brainstorming -> spec -> plan -> execute -> review -> finish branch`，核心对象是“代码实现任务”。

为什么不适合我们：

- `contract` 不是代码任务计划，也不是实现执行入口。
- 它更像“把已确认的产品范围压成可执行实现真相源”的中间标准层。

结论：

- 我们可以借它的“分层固化法”，但不能把 `contract` 误建成 `implementation plan`。

### 3. 不要把 `contract artifact` 写成 plan 那种超细任务清单

事实依据：

- `writing-plans` 明确要求把任务拆成 2-5 分钟粒度、甚至直接给出代码片段与命令。

为什么不适合我们：

- `contract` 的消费者是前端、后端、AI、脚本，而不是单个 implementer agent。
- `contract` 需要的是资源、字段、状态、权限、接口、查询能力、错误语义等“稳定约束”，不是 step-by-step coding checklist。

结论：

- `contract` 应更接近“结构化实施协议”，不是“任务执行计划”。

### 4. 不要默认采用它的 TDD 话语来约束 contract

事实依据：

- `test-driven-development/SKILL.md` 在 superpowers 中是近乎全局铁律。

为什么不适合我们：

- `contract` 设计本身不是测试先行问题，而是边界、命名、约束、消费完整性的问题。
- 如果直接照搬，会把重点从“定义实现接口层真相源”误转到“怎么写实现代码”。

结论：

- 我们需要的是 `validation-driven contract`，不是 `test-driven contract`。

## Proposed Contract Definition For Our System

### Source-grounded framing

结合我们现有文档：

- [`docs/exploration/MVP_WORKFLOW.md`](/Users/wangwenjie/project/archetype-admin-path/docs/exploration/MVP_WORKFLOW.md) 明确写了 “contract 是前后端协作的真相源”。
- [`docs/research/contract/notes/2026-04-23-contract-foundation-notes.md`](/Users/wangwenjie/project/archetype-admin-path/docs/research/contract/notes/2026-04-23-contract-foundation-notes.md) 已经把 `contract` 定位为：
  - 比 PRD 更硬、更明确的结构化输入
  - 前后端和 AI 的共同语言层
  - 变更时优先修改对象之一

### Proposed definition

`contract` 应被定义为：

> 基于已确认 `final_prd` batch 产出的、面向实现阶段的结构化协议层。  
> 它把某一批业务范围压缩成前后端和 AI 都能稳定消费的“实现真相源”，重点描述资源边界、字段语义、状态流转、权限与租户规则、接口与查询约束、页面实现所需的数据形状，以及关键错误/空态/枚举约束。

### What it is not

- 不是 `final_prd` 的自然语言重写
- 不是 Swagger/OpenAPI 的镜像替代品
- 不是代码实现计划
- 不是只给后端看的 API 文档

### What it must guarantee

1. 前端拿到后，不需要再猜：
   - 列表字段
   - 表单字段
   - 枚举/状态
   - 关键交互约束
   - 权限显示边界
2. 后端拿到后，不需要再猜：
   - 资源与动作边界
   - DTO/校验方向
   - 权限与租户约束
   - 查询参数与错误语义
3. AI/脚本拿到后，不需要再猜：
   - 类型生成输入
   - mock 生成输入
   - CRUD 骨架生成输入
   - batch 间依赖和引用

### Answer to mandatory question 1

站在 `superpowers` 的肩膀上，我们的 `contract` 不应被定义成“下一步文档”，而应被定义成“独立 artifact 类别 + 独立 review gate + 独立模板/规则体系”的实现协议层。

## Proposed Contract Workflow MVP

### Position in current chain

基于 [`docs/prd/WORKFLOW_GUIDE.md`](/Users/wangwenjie/project/archetype-admin-path/docs/prd/WORKFLOW_GUIDE.md)：

- `contract` 应处在 `final_prd` 之后
- 只能消费 `final_prd.decision.allow_contract_design=true` 的 batch
- 应按 `final_prd.contract_execution.recommended_batch_order` 逐 batch 推进，而不是整份 `final_prd` 一次性展开

### Answer to mandatory question 2

`contract` 在我们当前主链路里，应该是：

- `final_prd` 的正式下游
- generation/frontend/backend scaffolding 的正式上游
- 变更回流时优先维护的中枢层

### Formal stages

建议 MVP 先定义 4 个正式阶段：

1. `contract-01 scope_intake`
   - 输入：单个 ready batch 的 `final_prd` 切片、相关 clarification 决议、execution_plan 顺序上下文
   - 目标：确认本批 contract 的边界、依赖、禁止越界项

2. `contract-02 domain_mapping`
   - 目标：把 batch 中的页面/模块需求映射为资源、动作、状态、角色、租户边界、跨模块引用
   - 产物：资源清单与依赖图，而不是最终 contract 正文

3. `contract-03 contract_spec`
   - 目标：产出正式 contract artifact
   - 内容：资源定义、字段、查询、命令动作、状态、枚举、权限、租户、错误语义、UI 消费提示、依赖引用

4. `contract-04 review_and_freeze`
   - 目标：独立 reviewer 校验后冻结本批 contract
   - 通过后才允许进入 generation 或 handoff

### Why this split

这是从 `superpowers` 借来的分层思路，但做了本地化改造：

- 它先把 spec 与 plan 分开
- 我们则把 intake / mapping / contract_spec / review 分开
- 这样 `contract` 不会一上来就把业务描述、资源分解、实现协议混写在一个 YAML 里

### Answer to mandatory question 3

`contract` 的正式步骤，MVP 建议就是上面这 4 步；如果后面发现 `scope_intake` 与 `domain_mapping` 总是一起完成，再考虑合并，而不是一开始就压成单步。

### Should we split it like superpowers?

答案：应该，但只拆最小必要层。

最小建议：

- `rules/`
- `templates/`
- `steps/`
- `reviewer/`
- `prompts/`

暂不建议 MVP 首期就上：

- 全局 hook
- 自动 skill 注入
- 多平台插件装配
- 完整行为测试矩阵

### Answer to mandatory question 5

我们应该像 `superpowers` 一样拆成规则、模板、步骤材料、reviewer、执行入口，但不需要复制它的插件化与会话 hook 体系。

### MVP first landing areas

最小 MVP 应先落这几块：

1. `contract` 的术语定义与边界规则
2. 单 batch contract artifact 模板
3. reviewer 规则与 reviewer 输出模板
4. step materials 索引，明确每步消费哪些上游文件
5. workflow guide，把 `final_prd -> contract` 的入口门禁写清楚

### Answer to mandatory question 6

最小 MVP 先落规则、模板、reviewer、步骤材料索引、workflow guide；不要先写生成脚本、schema 执行器或全局自动化。

## Implications For final_prd -> contract

### What should stay in `final_prd`

`final_prd` 应保留：

- 业务目标与范围
- 模块/页面/角色/流程的业务叙述
- MVP 边界
- 待办 batch 划分与推荐顺序
- clarification 决议汇总
- 阻塞问题与是否允许进入 contract 的决策

原因：

- 这些内容本质上是“为什么做”和“做到哪里”，不是“怎么作为实现协议被消费”。

### What should move into `contract artifact`

`contract artifact` 应承载：

- 资源/实体定义
- 字段级语义、类型倾向、必填/可选/只读/系统生成
- 列表查询参数、筛选、排序、分页、搜索约束
- 创建/编辑/详情/状态变更动作的输入输出形状
- 状态机、枚举、合法流转
- 权限点与租户隔离边界
- 错误场景、空态、冲突态、禁用条件
- 页面消费需要的聚合视图字段或衍生字段说明
- 跨资源引用与依赖来源

### Answer to mandatory question 4

判断标准很简单：

- 仍属于“业务意图、范围、确认结论、批次安排”的，留在 `final_prd`
- 已经属于“实现消费者不应再猜”的，进入 `contract artifact`

### Recommended handoff rule

`final_prd -> contract` 的 handoff 不应只是“把 whole final_prd 喂给 contract agent”，而应至少先抽出：

- 当前 batch scope
- 相关角色与资源
- clarification 已确认决议
- blocking questions 是否已清零
- 前序 batch 已冻结的 contract 依赖

## Open Questions

1. `contract` 的正式拆分颗粒度是按“模块”还是按“资源组”更合适？
   - 当前内部 notes 倾向按模块，但资源复用会要求稳定引用机制。

2. `contract artifact` 是否应该一开始就同时兼顾前端视图层字段和后端接口层字段？
   - 我的判断是要兼顾，但要区分“canonical resource fields” 与 “view composition fields”。

3. batch 间引用如何固化？
   - 如果批次 B 依赖批次 A 的资源定义，需要一套稳定引用方式，否则 contract 会碎片化。

4. reviewer 的拒绝条件是否需要先做成显式 checklist？
   - 从 PRD 经验看，答案大概率是需要。

5. 首个 MVP 是否就要上 schema validator？
   - 推断：模板先于 validator；但 reviewer checklist 至少要先有。

## Recommended Next Step

下一步不应直接实现 `contract` 脚本或 schema，而应先在本仓库内部补出一版 `contract workflow skeleton` 设计文档，最少回答三件事：

1. `contract` 的正式步骤编号与每步输入输出
2. 单 batch `contract artifact` 的字段分区
3. reviewer 的拒绝条件与通过条件

如果只做一个最小动作，我建议先写：

- `docs/contract/WORKFLOW_GUIDE.md` 的草案
- 同时附一份 `contract artifact` 的章节级结构草案

原因是这两件事能最快检验本次调研的核心结论：我们是否真的把 `contract` 当成独立流程，而不是 `final_prd` 的附录。

## Final Recommendation Summary

### Source-confirmed facts

- `superpowers` 成功的关键不是 README，而是把方法拆成 `skills + prompt templates + hooks + tests + artifact directories`。
- 我们当前仓库已经把 `contract` 放在 `final_prd` 之后，但还没有把它建设成独立流程。

### Inference for our system

- 我们的 `contract` 应该成为独立 artifact 体系。
- 应采用“规则、模板、步骤材料、reviewer、入口”这套最小分层。
- 不应照搬 `superpowers` 的 hook-first、TDD-first、implementation-plan-first 思路。
- MVP 先做流程定义和 reviewer 关口，再做脚本与 schema。
