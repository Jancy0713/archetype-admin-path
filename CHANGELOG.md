# Changelog

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
