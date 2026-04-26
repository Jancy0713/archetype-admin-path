# Changelog

## 2.1.0 - 2026-04-27

本版本把仓库从 `init -> prd` 的需求生成链路，推进到可执行的 `init -> prd -> contract_handoff -> contract -> openapi/swagger -> develop` 主链。

### Added

- 新增 `contract` 正式流程文档、结构化模板、规则、step prompts、reviewer prompts、reviewer checklists 和 workflow guide。
- 新增 `scripts/contract/*` 执行脚本，覆盖 artifact 初始化、校验、渲染、continue/finalize、review complete、release 构建、handoff 生成、baseline settlement 和分层 smoke。
- 新增 `prd-05 contract_handoff` 主链接点：`prd-04 final_prd` review 通过后，可拆分多个独立 contract flows，并初始化标准 contract run。
- 新增标准 contract run 结构：`raw/`、`prompts/`、`progress/`、`intake/`、`contract/working/`、`contract/release/`、`rendered/` 和 `archive/`。
- 新增 contract release 包：`contract.yaml`、`contract.summary.md`、`openapi.yaml`、`openapi.summary.md` 和 `develop-handoff.md`。
- 新增独立 review gate：主 contract agent 只能执行到 `contract-03`，`contract-04.review.yaml` 必须由独立 reviewer 子 agent 生成，review 通过后才能 release。
- 新增日期化 contract run 命名：`runs/YYYY-MM-DD-contract-<flow-id>`，并在 `prd-05` 输出中暴露实际工作区和启动提示词。
- 新增 `baselines/` 说明和 `settle_baseline.rb`，为 develop 验证后的稳定合同沉淀预留正式位置。
- 新增 `docs/development_progress/` 统一承载开发推进记录、pending items、contract-new 01-09 计划和历史 contract/generation 材料。
- 新增 `merchant-ai-video-admin` 前端基础项目，包括 React/Vite 基座、主题 token、基础组件、应用壳层、平台能力占位和项目约定文档。
- 新增 contract-new Step 8 / Step 9+ 规划：后续补强 OpenAPI schema 完整性、multi-flow develop input index 和 mock 策略。

### Changed

- `create_run.rb` 支持 `contract` flow，交互菜单、目录结构、progress board、run prompt 和 handoff notes 会按 flow 类型生成。
- PRD 流程补齐步骤化入口：`analysis / clarification / execution_plan / final_prd` 拆出独立 step prompt、reviewer 材料和 manifest。
- PRD run 新增 `prompts/materials/` 快照，固定每个 run 使用的 artifact/review 材料入口。
- `scripts/prd/review_complete.rb` 接入 `contract_handoff` 生成，并把 `prd-05` 完成回报固定为“下一步建议 -> 功能批次 -> 关键材料 -> 异常偏差”。
- `docs/contract/WORKFLOW_GUIDE.md` 明确 develop 只消费 `contract/release/`，不得读取 `contract/working/` 过程态。
- `docs/development_progress/README.md`、`PENDING_ITEMS.md` 和 `DEVELOPMENT_CONTEXT_PRINCIPLES.md` 替代旧的散落式进度材料。

### Fixed

- 修正 `contract` 旧文案中“Reviewer 或快速 release”的误导，明确必须启动独立 reviewer 子 agent。
- 修正 `project-conventions.md` 从 PRD 到 contract handoff 的路径继承，避免 contract 执行时靠 AI 自己猜真实项目路径。
- 禁止 contract release 回写上游 PRD run；PRD run 在 `prd-05` 后作为只读事实来源。
- 清理旧 `generation` 主链残留口径，当前正式主链统一为 `contract -> openapi/swagger -> develop`。
- 修正 contract run 的 handoff notes，避免混入 `init-07/init-08` 旧流程说明。

### Known Follow-ups

- Step 8 计划补强 OpenAPI schema 完整性，避免 `components.schemas` 只是空 object 壳。
- Step 9+ 计划补 multi-flow develop input index，并在后续测试/mock 阶段设计 OpenAPI 驱动的 mock 数据与 mock/real API 切换方案。

## 1.0.3

- 修正 `scripts/create_run.rb` 的模板选择逻辑，`prd` run 改为固定使用 `docs/templates/autonomous-run-prompt.prd.template.md`，避免把 `init` 的 Human Gate 规则混入新的 PRD 启动 prompt
- 调整 `scripts/init/post_init_to_prd.rb` 生成的新 PRD run 输入格式：`raw/request.md` 不再暴露“基于 init 结果继续”这类上游流程来源，而是直接面向下游 PRD 描述目标项目、基础模块范围和规则文件路径
- 重写 PRD 启动输入引用方式：从单一 `init-prd-context.md` 拆为 `raw/attachments/confirmed-foundation.md` 与 `raw/attachments/base-modules-prd.md`，分别承载已确认项目级前提与基础模块需求，减少语义混杂
- 收紧 `base-modules-prd.md` 的关注点，只保留“聚焦基础模块页面范围 / 状态流转 / 数据对象 / 接口边界”与“不要补入具体业务前提”两条执行约束
- 明确 `init-07` 默认推荐的初始化目录语义：AI 需要推荐目录名 slug，默认初始化位置是“当前项目根目录下的该子目录”，而不是直接把工程铺到当前仓库根目录
- 统一 `init-07 / init-08` 边界：`init-07` 必须提前生成 `rendered/init-07.init-execution-scope.md` 供 Human Gate 确认；`init-08` 才基于已确认的项目名称、目录名称和初始化位置生成 `prompts/init-08-execution-prompt.md` 并执行初始化
- 补齐 `init-07` 的正式渲染链路：除 `bootstrap_plan.md` 外，还会实际生成 `rendered/init-07.project-conventions.md`、`rendered/init-07.prd-bootstrap-context.md`、`rendered/init-07.init-execution-scope.md`，让用户在 Human Gate 一次确认完整 5 份材料（含 `init-06.design_seed.md`）
- 为 `scripts/init/continue_run.rb`、`scripts/init/execute_init_scope.rb`、`scripts/init/render_init_execution_prompt.rb` 增加一致的目录解析规则；未显式传入 `--project-dir-name` 时，也不再默认把仓库根目录直接当成初始化落点
- 清理并回退测试产物：删除临时验证 run 与生成项目目录，将 `runs/2026-04-18-init-1.0.3` 回退到 `init-06` 已完成、等待从 `init-07 bootstrap_plan` 重新开始的状态
- 本次变更重点是修正 `init -> prd` 交接协议和 `init-07/08` 默认行为，不改动 `1.0.1`、`1.0.2` 的既有产物
## 1.0.2

- 将 `init` 的阶段确认数据从多桶结构收敛为单一 `confirmation_items`，统一承载所有需要人工确认的内容
- 明确 `confirmation_items.level` 只允许 `secondary / primary / required`，由展示层分组，而不是在 YAML 层拆成不同数据源
- 移除 `required_questions / adaptive_questions / key_decisions / recommended_defaults / open_questions` 作为 `init project_profile` 的主确认协议
- 同步调整 `baseline`，如仍需人工确认，也统一使用 `confirmation_items`
- 收紧 `scripts/init/artifact_utils.rb` 校验逻辑，使 `init` 主流程只能接受 `confirmation_items` 新结构
- 重写 `scripts/init/render_artifact.rb`，使 `project_profile.md` 与 `baseline.md` 直接从统一确认项协议渲染
- 重写 `docs/init/templates/structured/project_profile.template.yaml` 与 `baseline.template.yaml`，固定输出 `confirmation_items` 骨架
- 同步更新 `MASTER_PROMPT`、规则文档、结构化输出指南与 autonomous run 提示词，避免模型继续生成旧字段
- 补齐 `init-05` 专用的 [BASELINE_PROMPT](/Users/wangwenjie/project/archetype-admin-path/docs/init/prompts/BASELINE_PROMPT.md)，明确 `baseline` 不是摘要整合，而是从 `init-01` 到 `init-04` 已确认结果收敛出的后续默认输入
- 强化 `DESIGN_SEED_PROMPT` 与 `BOOTSTRAP_PLAN_PROMPT`，明确脚本只负责骨架初始化和格式约束，`init-05` 到 `init-07` 的内容增强、细节补全和语义收敛必须由 AI 完成
- 调整 Human Confirmation Gate 规则：`init-01` 到 `init-04` 继续使用问卷式确认，`init-05 baseline` 与 `init-07 bootstrap_plan` 改为文档通读确认，不再复用“必须回复项 / 重点确认项 / 次要确认项 / 回复格式示例”格式
- 更新 autonomous run 模板、运行指南和当前测试 run 提示词，要求 `init-05` 到 `init-07` 不能把脚本预填初稿直接当成最终结果
- 新增 `scripts/init/continue_run.rb`，支持基于已有 run 从 `init-05` / `init-06` / `init-07` 继续推进，便于从 `init-04` 的已确认结果续跑后半段
- 调整 `prefill_from_upstream.rb` 的 `bootstrap_plan` 预填逻辑，使其回读 `baseline` / `design_seed` / `project_profile`，补入页面壳层、认证租户权限接线位、平台能力边界和后续 PRD 继承关系，减少通用后台空壳感
- 调整 `render_artifact.rb`：`baseline.md` 移除来源追踪类正文展示，聚焦 01-04 的收口和适度细化；`design_seed.md` 将 token、页面模式、组件原则和禁止项改为逐条可读输出，减少“通用 token 列表”观感
- 回写 `docs/USER_CONTEXT_DELTAS_2026-04-18.md`：补充“脚本负责结构约束，AI 负责内容增强”的抽象原则，作为后续 `init` / `prd` 统一参考
- 本次变更是 `init` 协议层的收敛，目的是减少数据源重复、避免同一问题在 YAML 中多次表达，并为后续迭代 `prd` 提供统一参考

## 1.0.1

- 调整 `init` 流程的 Human Confirmation Gate 输出规范，要求使用“问题 + 选项 + 推荐项 + 说明”的确认格式
- 重写 `scripts/init/render_artifact.rb` 中 `project_profile` 的 Markdown 渲染逻辑，使其聚焦人工确认阅读体验而不是平铺 YAML
- 将 `project_profile.md` 改为按“项目概览 / 当前阶段结论 / 待确认问题 / 推荐默认项 / 后续阶段预览”输出
- 为待确认项引入稳定编号，并补充固定回复格式，便于用户按编号反馈修改
- 收紧 Human Confirmation Gate，只允许提出真正待确认的问题；已足够明确的结论不再机械重复追问
- 对没有安全默认值的开放问题，要求单独列为必须回复项，未明确前不得继续推进
- 收紧 `project_profile` 的 YAML 校验规则：`open_questions` 改为结构化对象，关键确认项支持 `allow_custom_answer`
- 为待确认问题增加选项数量约束，默认 2-5 个；如果情况过多，要求拆题而不是堆长选项列表
- 调整 `create_run.rb` 生成的初始化输入模板，将 `Background / Scope` 改为 `One-line Requirement / Details / Notes`
- 更新 autonomous run prompt 与 `init` 配套文档，统一强调 Markdown 是展示层，YAML 是结构化数据源
- 本次只调整 `init` 流程，不涉及 `prd` 流程

## 1.0.0

- 建立 `init` / `prd` 双流程文档骨架
- 建立结构化 YAML 模板、校验脚本、渲染脚本
- 引入 `step_id` / `artifact_id` / `flow_id` 追踪规则
- 统一 `runs/` 运行目录规范
- 引入独立进度板模板
- 提供 `scripts/create_run.rb` 初始化 run 目录
- 提供 autonomous run 总控提示词与运行指南
