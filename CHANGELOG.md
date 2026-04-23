# Changelog

## 2.1.0 (in progress)

- 为 `prd` 流程补齐 `2.1.0` 结构治理入口：新增按步骤组织的 prompt 索引、reviewer 材料索引与 step materials 索引，并将 `README / PROMPTS_GUIDE / WORKFLOW_GUIDE` 切到步骤化入口
- 新增 `analysis / clarification / execution_plan / final_prd` 各自独立的 `STEP_PROMPT.md`，避免继续把主流程约束堆在单一总 prompt 中
- 新增 reviewer 分拆资料：`reviewer/common/REVIEWER_WORKFLOW.md` 与 4 份阶段 checklist 独立落盘，使 reviewer 输入组织和阶段专项检查项可直接复用
- 新增 `scripts/prd/materials.rb` 与 `artifact_utils.rb` 中的材料映射，支持按 `artifact` 或 `review_step` 查询正式 step prompt、rule、template、reviewer workflow 与 checklist
- 为 `create_run.rb` 补充 PRD run 内的 `prompts/materials/` 快照，固定当前 run 使用的 artifact/review 材料入口，减少运行时手工查找全局路径
- 为 reviewer 初始化补充包装脚本 `scripts/prd/init_review_context.rb`，可一次性生成 `review.yaml`、回填 `meta.subject_path` 并落 reviewer 材料快照，支持 `--force` 重建同一路径
- 为 PRD 流程补充 `scripts/prd/workflow_manifest.rb`，统一维护 4 个正式步骤的 artifact、review step、render 路径、command cheat sheet 和初始进度元信息，并让 `create_run.rb` 改为从 manifest 读取运行信息
- 新增 `scripts/prd/continue_run.rb`，支持按 `artifact / review / render` 三种模式继续推进 PRD run，并同步更新进度板
- 新增 `scripts/prd/finalize_step.rb`，把单步收口固定为 `validate -> init_review_context -> render`，并将当前步骤状态推进到 `review`
- 新增 `scripts/prd/review_complete.rb`，消费独立 reviewer 产物，根据 `allow_next_step / has_blocking_issue / need_human_escalation` 自动把步骤写成 `done / confirmed / blocked`
- 新增 `scripts/prd/confirm_clarification.rb`，把 Human Confirmation Gate 正式脚本化：回写 `human_confirmation`、基于 `open_questions.p0` 决定 `allow_execution_plan`，并把 `prd-02` 状态推进为 `confirmed` 或 `blocked`
- 收紧 `final_prd -> contract` 门禁：当 `decision.allow_contract_design=true` 时，`contract_handoff.contract_scope / priority_modules / required_contract_views / do_not_assume` 现在都必须非空且不得重复
- 重写 `scripts/prd/render_artifact.rb` 的 Markdown 呈现方式，使 `analysis / clarification / execution_plan / final_prd / review` 更适合人工通读；同时修正对当前 Ruby 版本的兼容性问题
- 新增 `docs/prd/examples/2.0/happy-path-run` 正式样例，覆盖四步主产物和 review 样例，并已用于 `validate / render` 回归
- 当前 `2.1.0` 仍处于 in progress：主链路脚手架与 run 执行能力已补齐，但完整真实 run 冒烟验证与最终版本切换尚未完成，因此仓库版本暂不从 `2.0.0` 升级

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
