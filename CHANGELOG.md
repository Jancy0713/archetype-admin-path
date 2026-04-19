# Changelog

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
