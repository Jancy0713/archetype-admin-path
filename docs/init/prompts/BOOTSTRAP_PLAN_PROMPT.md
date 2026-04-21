# Bootstrap Plan Prompt

## 使用方式

把下面 prompt 给主模型，用于在 `init-07 bootstrap_plan` 阶段对“脚本预填初稿”做收敛和增强。

---

你现在在执行项目初始化流程中的 `init-07 bootstrap_plan` 步骤。

你的输入不是空白模板，而是：

1. 已通过的 `design_seed`
2. 一个已经由脚本预填过的 `bootstrap_plan` YAML 初稿

你的角色是：

- 主模型
- 负责把初始化底座工作整理成可确认的计划

你必须遵守以下规则：

1. `bootstrap_plan` 只处理“纯工程初始化范围 + 项目长期规则 + 下一轮 PRD 交接”，不得展开具体业务模块设计。
2. 第8步允许做的内容只能是工程基座，不得写任何具体业务接口、具体业务 contract、真实业务页面实现。
3. `init_execution_scope` 要明确写出第8步允许做什么、不允许做什么、交付什么、做到什么程度算完成。
4. `project_conventions` 是项目内长期复用规则，主来源应是 `design_seed`，不要把 `init-01` 到 `init-04` 的一次性确认全部写成永久规范。
5. `prd_bootstrap_context` 要把 init 已确认的项目级前提交给下一轮 PRD，但不能替代模块级 PRD 本身。
6. 你的工作重点是在预填初稿基础上收敛，但脚本预填只是骨架；你必须把 baseline / design_seed 已确认的项目特征补进来，不要停留在通用后台空话。
7. 这一步是给人工确认初始化范围和长期规则的，不要写成纯技术实现细节清单。
8. `bootstrap_plan` 必须体现 design_seed 的结果，例如主题/密度/导航原则、页面模式、基础组件约束，而不是只写“design-system seed”几个字。
9. `bootstrap_plan.md` 应偏向“索引 + 简介 + 后续使用方式”，不要大段复述 `init_execution_scope`、`project_conventions`、`prd_bootstrap_context` 三份子文档的正文。
10. `bootstrap_plan.md` 里应明确区分“当前给人确认的 rendered 预览文件”和“后续真正写入项目内的固定路径”，不要把两者混写成同一种目标路径。
11. `bootstrap_plan.md` 还应补一小段“执行参数确认”，先给出项目名称候选、目录 slug 候选和默认初始化位置，并明确这些参数仍需 human gate 最终确认。
12. `project_conventions` 应清楚表达：规则文件固定落在项目相对路径 `docs/project/project-conventions.md`，后续所有 PRD 都直接读取这个文件。
13. `project_conventions.generation_workflow` 应明确：脚本只生成骨架，AI 必须基于当前项目的 `design_seed` 补强细节并自查。
14. `prd_bootstrap_context` 不是项目内长期规则文件，而是本次 `init -> prd` 的基础 PRD 输入文档。
15. `prd_bootstrap_context` 不要写成“交接清单”或“流程说明”，而要写成一份基础 PRD 初稿。
16. `prd_bootstrap_context` 只允许承接项目概况和基础模块方向，例如登录、账号、租户、权限，不要提前带入任何具体业务功能。
17. `prd_bootstrap_context.notes` 应写清它是流程执行依据，不是项目内长期规则文件；项目长期规则仍由 `docs/project/project-conventions.md` 承担。
18. 输出必须严格遵循 `bootstrap_plan.template.yaml` 字段名。
19. 只输出最终 YAML，不要输出 Markdown 解释。

输出要求：

1. `meta.source_paths` 至少应包含真实 `design_seed` 路径。
2. `init_execution_scope.allowed_work`、`excluded_work`、`deliverables`、`completion_criteria` 都应有内容。
3. `project_conventions` 至少应覆盖：
   - design_seed 的关键风格与主题结论
   - 组件封装与页面复用原则
   - 后续如何固化到项目内固定路径并被持续读取
   - 脚本 / AI / reviewer 的参与方式
4. `prd_bootstrap_context` 至少应覆盖：
   - 文档目标
   - 项目概况
   - 已确认的登录 / 账号 / 租户 / 权限等基础前提
   - 基础模块需求
   - 本轮 PRD 关注点
5. `decision.plan_confirmed` 默认应保持 `false`，因为这一步结尾需要人工确认。

收敛原则：

- 优先保留脚本已经预填的基础结构
- 重点补强“第8步到底能做什么”“哪些规则要长期写进项目内”“下一轮 PRD 拿到什么上下文就能开始”
- 让人读完后能直接把这份 bootstrap_plan 交给后续 AI 做初始化开发和 PRD 启动，而不是还要重新解释项目背景
- 不要把 bootstrap plan 写成开发任务拆解表
- 不要把普通功能页面、字段规则、业务流转塞进来

请开始。
