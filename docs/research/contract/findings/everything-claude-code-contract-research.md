# Everything Claude Code Contract Research

## Research Scope

本次调研只回答一个问题：站在 `affaan-m/everything-claude-code`（下文简称 ECC）的结构设计之上，我们仓库里的 `contract` 正式流程应该如何定义，而不是如何立刻实现模板、脚本或 schema。

本次已研读的本仓库上下文：

- [`docs/exploration/MVP_WORKFLOW.md`](/Users/wangwenjie/project/archetype-admin-path/docs/exploration/MVP_WORKFLOW.md)
- [`docs/exploration/README.md`](/Users/wangwenjie/project/archetype-admin-path/docs/exploration/README.md)
- [`docs/prd/README.md`](/Users/wangwenjie/project/archetype-admin-path/docs/prd/README.md)
- [`docs/prd/WORKFLOW_GUIDE.md`](/Users/wangwenjie/project/archetype-admin-path/docs/prd/WORKFLOW_GUIDE.md)
- [`docs/research/contract/notes/2026-04-23-contract-foundation-notes.md`](/Users/wangwenjie/project/archetype-admin-path/docs/research/contract/notes/2026-04-23-contract-foundation-notes.md)
- [`scripts/prd/workflow_manifest.rb`](/Users/wangwenjie/project/archetype-admin-path/scripts/prd/workflow_manifest.rb)

本次已研读的 ECC 关键源码/文档：

- 仓库根目录树：[`/`](https://github.com/affaan-m/everything-claude-code)
- agents 目录：[`agents/`](https://github.com/affaan-m/everything-claude-code/tree/main/agents)
- skills 目录：[`skills/`](https://github.com/affaan-m/everything-claude-code/tree/main/skills)
- commands 目录：[`commands/`](https://github.com/affaan-m/everything-claude-code/tree/main/commands)
- hooks 目录与说明：[`hooks/README.md`](https://github.com/affaan-m/everything-claude-code/blob/main/hooks/README.md), [`hooks/hooks.json`](https://github.com/affaan-m/everything-claude-code/blob/main/hooks/hooks.json)
- rules 目录与说明：[`rules/README.md`](https://github.com/affaan-m/everything-claude-code/blob/main/rules/README.md), [`rules/common/testing.md`](https://github.com/affaan-m/everything-claude-code/blob/main/rules/common/testing.md), [`rules/typescript/testing.md`](https://github.com/affaan-m/everything-claude-code/blob/main/rules/typescript/testing.md)
- install manifests：[`manifests/install-components.json`](https://github.com/affaan-m/everything-claude-code/blob/main/manifests/install-components.json), [`manifests/install-modules.json`](https://github.com/affaan-m/everything-claude-code/blob/main/manifests/install-modules.json), [`manifests/install-profiles.json`](https://github.com/affaan-m/everything-claude-code/blob/main/manifests/install-profiles.json)
- scripts/tests：[`scripts/catalog.js`](https://github.com/affaan-m/everything-claude-code/blob/main/scripts/catalog.js), [`tests/run-all.js`](https://github.com/affaan-m/everything-claude-code/blob/main/tests/run-all.js)
- sample command/skill/agent：[`commands/multi-plan.md`](https://github.com/affaan-m/everything-claude-code/blob/main/commands/multi-plan.md), [`commands/code-review.md`](https://github.com/affaan-m/everything-claude-code/blob/main/commands/code-review.md), [`skills/deep-research/SKILL.md`](https://github.com/affaan-m/everything-claude-code/blob/main/skills/deep-research/SKILL.md), [`skills/documentation-lookup/SKILL.md`](https://github.com/affaan-m/everything-claude-code/blob/main/skills/documentation-lookup/SKILL.md), [`skills/eval-harness/SKILL.md`](https://github.com/affaan-m/everything-claude-code/blob/main/skills/eval-harness/SKILL.md), [`agents/planner.md`](https://github.com/affaan-m/everything-claude-code/blob/main/agents/planner.md), [`agents/code-reviewer.md`](https://github.com/affaan-m/everything-claude-code/blob/main/agents/code-reviewer.md)
- cross-harness config：[`AGENTS.md`](https://github.com/affaan-m/everything-claude-code/blob/main/AGENTS.md), [`CLAUDE.md`](https://github.com/affaan-m/everything-claude-code/blob/main/CLAUDE.md), [`.codex/config.toml`](https://github.com/affaan-m/everything-claude-code/blob/main/.codex/config.toml), [`docs/SKILL-PLACEMENT-POLICY.md`](https://github.com/affaan-m/everything-claude-code/blob/main/docs/SKILL-PLACEMENT-POLICY.md)

## What Everything Claude Code Actually Does

### 1. 它是一个“分层能力仓库”，不是单一 prompt 包

源码确认的事实：

- ECC 根目录直接把能力拆到 `agents/`, `skills/`, `commands/`, `hooks/`, `rules/`, `mcp-configs/`, `scripts/`, `tests/`, `manifests/`, `.codex/`, `.cursor/`, `.claude/` 等平级目录中，而不是把所有约束塞进一个总说明文件。
- [`CLAUDE.md`](https://github.com/affaan-m/everything-claude-code/blob/main/CLAUDE.md) 和 [`AGENTS.md`](https://github.com/affaan-m/everything-claude-code/blob/main/AGENTS.md) 只负责总入口说明；真正可执行的细节分别落在目录内部。
- [`tests/run-all.js`](https://github.com/affaan-m/everything-claude-code/blob/main/tests/run-all.js) 会递归发现 `tests/` 下的测试文件并统一执行，说明这些目录并不是文档摆设，而是被持续校验的系统部件。

基于事实的推断：

- ECC 的长期维护性来自“能力按职责拆目录，目录再被 manifest 与 tests 绑定”。
- 对我们来说，`contract` 也不该是一篇总说明或一个 YAML 模板，而应该是一个小型系统面。

### 2. 它把“规则、技能、命令、自动化、代理协作”拆成不同层

源码确认的事实：

- `rules/` 定义长期稳定的规范层。[`rules/README.md`](https://github.com/affaan-m/everything-claude-code/blob/main/rules/README.md) 明确区分 `common/` 与语言层目录，并写明 “Rules tell you what to do; skills tell you how to do it.”
- [`rules/common/testing.md`](https://github.com/affaan-m/everything-claude-code/blob/main/rules/common/testing.md) 给出全局测试底线；[`rules/typescript/testing.md`](https://github.com/affaan-m/everything-claude-code/blob/main/rules/typescript/testing.md) 只补充 TS/JS 特有内容，并显式声明“extends common/testing.md”。
- `skills/` 是任务知识与操作策略层。比如 [`skills/documentation-lookup/SKILL.md`](https://github.com/affaan-m/everything-claude-code/blob/main/skills/documentation-lookup/SKILL.md) 要求查库文档时优先走 Context7；[`skills/deep-research/SKILL.md`](https://github.com/affaan-m/everything-claude-code/blob/main/skills/deep-research/SKILL.md) 负责多源调研；[`skills/eval-harness/SKILL.md`](https://github.com/affaan-m/everything-claude-code/blob/main/skills/eval-harness/SKILL.md) 负责评测框架。
- `commands/` 是面向用户/操作者的流程入口层。比如 [`commands/code-review.md`](https://github.com/affaan-m/everything-claude-code/blob/main/commands/code-review.md) 定义了本地 review 的 gather/review checklist；[`commands/multi-plan.md`](https://github.com/affaan-m/everything-claude-code/blob/main/commands/multi-plan.md) 定义多模型协作计划流程。
- `agents/` 是受限职责角色层。比如 [`agents/planner.md`](https://github.com/affaan-m/everything-claude-code/blob/main/agents/planner.md) 只做规划；[`agents/code-reviewer.md`](https://github.com/affaan-m/everything-claude-code/blob/main/agents/code-reviewer.md) 只做 review。
- `hooks/` 是事件驱动自动化层。[`hooks/README.md`](https://github.com/affaan-m/everything-claude-code/blob/main/hooks/README.md) 明确 PreToolUse/PostToolUse/Stop/SessionStart/PreCompact 等生命周期；[`hooks/hooks.json`](https://github.com/affaan-m/everything-claude-code/blob/main/hooks/hooks.json) 把它们具体落成可执行 hook。
- `mcp-configs/` 是外部能力接入层。[`mcp-configs/mcp-servers.json`](https://github.com/affaan-m/everything-claude-code/blob/main/mcp-configs/mcp-servers.json) 把 `exa-web-search`, `context7`, `playwright` 等服务集中声明。

基于事实的推断：

- ECC 的关键不是“文件很多”，而是“每层只承担一种职责”。
- 如果迁移到我们的 `contract`，最值得学的不是 agent 数量，而是层次分工。

### 3. 它通过 manifest 把“内容层”升级为“可安装、可组合、可裁剪的系统”

源码确认的事实：

- [`manifests/install-components.json`](https://github.com/affaan-m/everything-claude-code/blob/main/manifests/install-components.json) 用 component 把模块组合成更高一层的可安装单元，例如 `baseline:rules`, `baseline:hooks`, `capability:research`。
- [`manifests/install-modules.json`](https://github.com/affaan-m/everything-claude-code/blob/main/manifests/install-modules.json) 用 module 记录 `id / kind / description / paths / targets / dependencies / defaultInstall / cost / stability`。例如 `workflow-quality` 直接列出一组 workflow skills；`orchestration` 同时引用 commands、scripts、skills。
- [`manifests/install-profiles.json`](https://github.com/affaan-m/everything-claude-code/blob/main/manifests/install-profiles.json) 再把 module 组装成 `core / developer / security / research / full` 等 profile。
- [`scripts/catalog.js`](https://github.com/affaan-m/everything-claude-code/blob/main/scripts/catalog.js) 提供 `profiles / components / show` 查询入口，说明 manifest 不只是静态清单，而是被脚本消费。

基于事实的推断：

- ECC 的“系统化”来自显式清单化：内容目录只是存放层，manifest 才是运营层。
- 我们的 `contract` 将来如果要长期演化，也需要“索引层”与“消费层”分开。

### 4. 它把自动化和协作做成正式系统部件，而不是约定俗成

源码确认的事实：

- [`hooks/hooks.json`](https://github.com/affaan-m/everything-claude-code/blob/main/hooks/hooks.json) 中既有 `SessionStart` 加载上下文，也有 `PreCompact` 保存状态，还有编辑后质量检查与 design-quality-check。
- [`commands/multi-plan.md`](https://github.com/affaan-m/everything-claude-code/blob/main/commands/multi-plan.md) 不是一句“让多模型一起看”，而是把上下文检索、双模型并行、等待策略、停止机制、只读边界全部写死。
- [`.codex/config.toml`](https://github.com/affaan-m/everything-claude-code/blob/main/.codex/config.toml) 显式声明 Codex MCP、profiles、multi-agent、agent role config，说明它把跨 harness 行为也纳入系统配置，而不是靠口头约定。

基于事实的推断：

- ECC 把“人会不会记得这样做”转换成“系统是否允许/默认这样做”。
- 对 `contract` 而言，这意味着研究、生成、review、冻结、消费都应该成为正式步骤，而不是文档里写一句“建议 review 一下”。

### 5. 它有明确的“已发布内容”和“运行时生成内容”边界

源码确认的事实：

- [`docs/SKILL-PLACEMENT-POLICY.md`](https://github.com/affaan-m/everything-claude-code/blob/main/docs/SKILL-PLACEMENT-POLICY.md) 明确区分 curated / learned / imported / evolved skills。
- 该文档还明确规定：只有 `skills/` 下的 curated 技能进入 install manifests；运行时生成或导入的技能不进 repo、不参与发布。

基于事实的推断：

- ECC 不只是“支持生成”，而是把“什么可长期提交、什么只是运行时派生物”说清楚了。
- 这对我们的 `contract` 很重要：正式 `contract artifact`、review 记录、rendered view、`generated outputs` 不应混在一个层里。

## Structural Patterns Worth Reusing

### 1. 把 `contract` 定义成独立系统层，而不是 `final_prd` 附件

回到我们仓库当前事实：

- [`docs/prd/README.md`](/Users/wangwenjie/project/archetype-admin-path/docs/prd/README.md) 已把正式流程止于 `prd-04 final_prd`，然后才进入 `contract`。
- [`docs/prd/WORKFLOW_GUIDE.md`](/Users/wangwenjie/project/archetype-admin-path/docs/prd/WORKFLOW_GUIDE.md) 明确说只有 `final_prd.decision.allow_contract_design=true` 才进入 `contract`。
- [`scripts/prd/workflow_manifest.rb`](/Users/wangwenjie/project/archetype-admin-path/scripts/prd/workflow_manifest.rb) 也把 PRD step order 停在 `prd-04`，后面只把 `contract` 当作 next step 文本，而没有正式 manifest。

建议复用的 ECC 思想：

- 像 ECC 区分 `rules / skills / commands / hooks / manifests` 一样，把 `contract` 视为独立系统层。
- `final_prd` 继续做输入索引与批次 handoff；`contract` 才负责实现真相源。

结论：

- 站在 ECC 的肩膀上，我们的 `contract` 应被定义成“面向实现与生成消费的结构化协议系统”，不是 PRD 附页，不是接口文档，也不是单次 prompt 输出。

### 2. 为 `contract` 引入正式分层

建议引入如下分层，且每层只做一件事：

- `rules/`
  - 定义 `contract` 的边界、禁止事项、命名与引用规则。
- `prompts/`
  - 定义每个正式步骤的 prompt，而不是一个大 prompt。
- `templates/`
  - 定义结构化产物模板，但不承载总流程规则。
- `scripts/`
  - 负责 init、validate、freeze、render、index、lookup。
- `review/`
  - 定义 reviewer 规则、checklists、review artifact 模板。
- `generated outputs/`
  - 放 types、mock、frontend starter inputs、backend handoff views 等派生物。

这是直接借鉴 ECC 的“规则层 / 任务知识层 / 入口层 / 自动化层 / 运行层”拆分思路，但压缩成适合我们当前问题域的版本。

### 3. 引入清单/索引层，而不是只靠目录遍历

ECC 值得学的不是 install 功能本身，而是 manifest 思想。

对我们建议：

- `contract` 正式系统要有自己的索引层，至少记录：
  - artifact id
  - module id
  - batch id
  - status
  - frozen version
  - dependency references
  - available rendered views
  - generated outputs
- 这样下游脚本和 agent 不用靠“猜某个目录下哪个 yaml 最新”。

### 4. 把 review 和 freeze 设成硬门禁

我们本仓库已经在 PRD 流程里建立 reviewer discipline：

- [`docs/prd/README.md`](/Users/wangwenjie/project/archetype-admin-path/docs/prd/README.md) 明确 reviewer 必须独立。
- [`docs/prd/WORKFLOW_GUIDE.md`](/Users/wangwenjie/project/archetype-admin-path/docs/prd/WORKFLOW_GUIDE.md) 明确每一步都经 `validate -> review`。

建议：

- `contract` 不要失去这条纪律。
- 至少保留：
  - `contract reviewer`
  - freeze gate
  - 冻结后的消费许可

### 5. 区分“正式 artifact”与“派生产物”

ECC 的 skill placement policy 提醒我们一件很关键的事：不是所有产物都应该进入正式发布面。

迁移到 `contract`：

- 正式 artifact：
  - `scope_intake`
  - `domain_mapping`
  - `contract_spec`
  - `review`
  - `freeze metadata`
- 派生产物：
  - 渲染后的 Markdown view
  - 前端 type/mock/config 输出
  - 后端 DTO/route/schema handoff 视图
  - 各种 generated snapshots

否则目录会迅速失控，正式真相源和临时派生物会混在一起。

## Patterns We Should Not Copy Blindly

### 1. 不要照搬 ECC 的“大而全能力面”

源码确认的事实：

- ECC 根目录同时覆盖工程开发、内容、媒体、运营、跨平台配置、学习演化、MCP、agent orchestration 等广泛能力。
- `skills/` 规模很大，`manifests/install-modules.json` 也按 capability 继续膨胀。

对我们的判断：

- 我们当前要解决的是 `contract` 标准流程，不是做一个全仓通用 agent harness。
- 若直接照搬 ECC 的宽能力面，会把 `contract` 研究偏成“再造一个代理框架”。

### 2. 不要把多模型/多 agent 协作做成 MVP 前置条件

源码确认的事实：

- [`commands/multi-plan.md`](https://github.com/affaan-m/everything-claude-code/blob/main/commands/multi-plan.md) 把多模型并行、session reuse、stop-loss 都写得很重。

对我们的判断：

- `contract` MVP 先不需要 Codex/Gemini 这种并行编排。
- 我们现在真正缺的是 artifact 定义、步骤边界、review gate、引用关系。
- 多 agent 协作可以以后作为增强，而不是先决条件。

### 3. 不要把 hook 自动化直接搬进 contract MVP

ECC 的 hook 系统很强，但那是针对“持续编码会话质量控制”。

对我们判断：

- 现阶段 `contract` 更适合先用显式脚本命令和正式 step 推进。
- 例如 `init_contract_artifact.rb`, `validate_contract_artifact.rb`, `freeze_contract.rb` 这种入口，比先做自动 hook 更符合当前仓库节奏。

### 4. 不要把 contract 做成测试/TDD 话语主导的系统

源码确认的事实：

- ECC 的 common rules 与 eval-harness 明显强调 TDD 与 eval-driven development。

对我们的判断：

- 这些思想对“验证 contract 质量”有帮助，但 contract 本体不是测试计划。
- contract 的主问题是边界清晰、字段/状态/权限/接口/依赖的可消费性，不是先写测试还是先写代码。

### 5. 不要复制 ECC 的跨 harness 兼容负担

ECC 有 `.codex/`, `.cursor/`, `.claude/`, `.opencode/` 等并行配置面。

对我们的判断：

- 我们的 `contract` 体系当前只要先对齐本仓库主链路与本地脚本消费即可。
- 不要为了“未来也许会多工具共享”而把当前设计做得过抽象。

## Proposed Contract System Shape For Our Repo

### 定义

`contract` 应被定义为：

- 位于 `final_prd` 之后的独立正式系统
- 以 batch 为推进单位的结构化实现协议层
- 面向前端、后端、AI、脚本共同消费的真相源
- 比 PRD 更硬、更明确、更可校验的约束载体

它至少承载：

- 模块/资源边界
- 字段与字段语义
- 查询/列表/详情/编辑/动作视图
- 状态机与枚举
- 权限与租户边界
- 接口动作与输入输出形状
- 错误语义与关键校验约束
- 对其他 contract 模块的依赖引用

它不承载：

- 自然语言 PRD 叙述
- 宏观排期与执行计划
- step-by-step coding checklist
- 具体页面像素级交互设计

### 从“输入索引”进化成“正式系统”的路径

建议分三层演进：

1. `final_prd` 继续只做 `contract intake index`
2. 新建 `contract workflow`
3. 在 `contract workflow` 之后再生成各类派生输出

也就是说：

- 现在的 `final_prd.contract_execution`、`ready_batches`、`contract_handoff` 保留
- 但它们只负责告诉 `contract` “这批可以开始了、范围是什么、不能假设什么”
- 真正的资源结构、引用关系、冻结版本、消费视图，移入正式 `contract` artifacts

## Proposed Contract Workflow MVP

MVP 建议拆成 4 个正式步骤。

### 1. `contract-01 scope_intake`

目标：

- 接收单个 ready batch 的 handoff
- 明确本批范围、依赖、禁止越界项
- 确认哪些上游问题已解决，哪些仍阻塞

输入：

- `prd-04.final_prd.yaml`
- 目标 `batch_id`
- 相关 clarification / execution_plan / final_prd rendered views

输出：

- 单 batch 的 `scope_intake.yaml`

### 2. `contract-02 domain_mapping`

目标：

- 把 batch 范围转成资源/模块/共享对象/状态/依赖图
- 明确跨模块引用点
- 明确哪些定义应复用已有 contract，哪些是本批新增

输出：

- `domain_mapping.yaml`

### 3. `contract-03 contract_spec`

目标：

- 产出正式 `contract artifact`
- 这是后续生成前端/后端派生输入的唯一正式来源

输出：

- `contract_spec.yaml`
- 可选 rendered markdown view

### 4. `contract-04 review_and_freeze`

目标：

- 独立 reviewer 检查完整性、一致性、可消费性
- 通过后写入 freeze metadata
- 只有 frozen contract 才能进入 downstream generation

输出：

- `review.yaml`
- `freeze.yaml` 或等价冻结元数据

### 为什么建议拆成 4 步

因为我们当前最大的风险不是“写不出 contract”，而是：

- 把输入索引和正式协议混写
- 把资源映射和最终 spec 混写
- 没有 freeze gate
- 下游消费时不知道哪个版本才可信

ECC 的启发是：不要把不同职责硬塞进一个文件或一步完成。

## Proposed Directory / Artifact Strategy

建议先采用类似下面的目录策略。

```text
docs/contract/
  README.md
  WORKFLOW_GUIDE.md
  rules/
    CONTRACT_SCOPE_RULE.md
    DOMAIN_MAPPING_RULE.md
    CONTRACT_SPEC_RULE.md
    CONTRACT_REVIEWER_RULE.md
    CONTRACT_REFERENCE_RULE.md
  prompts/
    scope_intake/
    domain_mapping/
    contract_spec/
    review/
  reviewer/
    README.md
    checklists/
  templates/
    structured/
      scope_intake.template.yaml
      domain_mapping.template.yaml
      contract_spec.template.yaml
      review.template.yaml
      freeze.template.yaml
  references/
    naming.md
    module-boundary.md
    consumer-views.md
scripts/contract/
  workflow_manifest.rb
  init_artifact.rb
  validate_artifact.rb
  render_artifact.rb
  init_review_context.rb
  review_complete.rb
  freeze_artifact.rb
  lookup_reference.rb
docs/contract/generated/
  frontend/
  backend/
  shared/
```

运行态建议像 PRD 一样以 run 为单位：

```text
runs/<run-id>/contract/
  contract-01.scope_intake.yaml
  contract-02.domain_mapping.yaml
  contract-03.contract_spec.yaml
  contract-04.review.yaml
  contract-04.freeze.yaml
  rendered/
```

长期沉淀态建议有一个正式归档面，例如：

```text
contracts/
  modules/
    <module-id>/
      current/
      versions/
      generated/
```

这里的核心原则是：

- `runs/` 存过程态
- `contracts/` 存冻结态
- `docs/contract/generated/` 或 `contracts/.../generated/` 存派生物

## Cross-Module Reference Strategy

如果未来按模块拆分 contract，建议不要只靠自然语言“本模块依赖用户模块”。

### 1. 引入稳定引用 ID

每个正式 contract 模块至少有：

- `contract_module_id`
- `version`
- `resource_ids`
- `exported_types`
- `exported_enums`
- `exported_actions`

### 2. 引用分两层

第一层：模块依赖

- 例：`depends_on_modules: [iam.user, iam.role]`

第二层：具体符号引用

- 例：`references:`
- `type_ref: iam.user/UserSummary@v1`
- `enum_ref: shared.lifecycle/PublishStatus@v1`
- `action_ref: iam.role/AssignRole@v1`

### 3. 建立 lookup 入口

不要要求下游 agent 自己 grep 全仓。

建议未来提供：

- `lookup_reference.rb --symbol shared.lifecycle/PublishStatus`
- 或 manifest/index 文件

这样一个 batch 的 contract 可以稳定引用另一个冻结模块，而不是复制定义。

### 4. 依赖规则

建议强约束：

- 只允许引用 frozen contract
- 禁止引用另一个 run 中尚未 freeze 的临时 spec
- 共享对象优先收敛到 shared/common contract 模块
- 一旦被其他模块引用，破坏性修改必须走新版本，而不是就地重写

## Open Questions

1. `contract` 正式颗粒度第一版到底按“模块”还是按“资源组”更稳？
2. `contract_spec` 第一版是否同时覆盖前端视图字段与后端接口字段，还是先做共享核心层，再派生不同 consumer views？
3. 冻结后的 contract 版本号策略要不要一开始就引入，还是先用 run-scoped freeze id？
4. 跨模块共享定义是否需要单独的 `shared` contract lane？
5. `generated outputs` 是放到 `runs/` 下更合适，还是随冻结 contract 一起归档更合适？
6. `final_prd.contract_handoff.required_contract_views` 未来是否要和正式 `contract_spec.consumer_views` 建立一一映射？

## Recommended Next Step

下一步不应开始实现模板、脚本或 schema。

最合适的下一步是先在本仓库补出一份 `contract workflow skeleton` 设计文档，最少明确三件事：

1. `contract-01` 到 `contract-04` 的正式步骤编号、输入、输出、门禁
2. `contract_spec` 的章节级字段分区
3. `runs/` 过程态与 `contracts/` 冻结态的目录关系

建议产物：

- `docs/contract/WORKFLOW_GUIDE.md` 草案
- `docs/contract/STRUCTURED_OUTPUT_GUIDE.md` 草案
- `docs/contract/README.md` 草案

本次结论的核心收束如下。

源码确认的事实：

- ECC 的强点不在某个单独 prompt，而在明确分层、manifest 化、脚本化、review 化、可测试化。

基于事实的推断：

- 我们的 `contract` 也应从“final_prd 的输入索引后续动作”升级成“独立 artifact 体系 + 独立步骤 + 独立 review/freeze gate + 独立索引/引用策略”的正式系统。
- 但不应照搬 ECC 的大而全 harness 面、多模型编排复杂度和重 hook 自动化。
- 对我们最有价值的迁移，不是规模，而是结构纪律。
