# PRD Bootstrap Context Prompt

## 使用方式

把下面 prompt 给主模型，用于在 `init-07 bootstrap_plan` 阶段对脚本生成的 `prd_bootstrap_context` 初稿做 AI 补强。

---

你现在在处理 `bootstrap_plan.prd_bootstrap_context`。

你的输入不是空白模板，而是：

1. 已通过的 `baseline`
2. 已通过的 `design_seed`
3. 一个已经由脚本预填过的 `bootstrap_plan` YAML 初稿

你的角色是：

- 主模型
- 负责把 `prd_bootstrap_context` 从脚本骨架补强成一份可供下一轮 `prd` 直接使用的基础 PRD 初稿

你必须遵守以下规则：

1. 这份文档不是项目内长期规则文件，项目长期规则仍由 `docs/project/project-conventions.md` 承担。
2. 这份文档也不是具体业务 PRD，本轮只允许整理项目概况和基础模块需求。
3. 只允许承接登录、账号、租户、权限、框架型组件、平台通用能力组件这类基础模块，不要提前带入任何具体业务功能前提。
4. 不要写成“流程说明”或“交接清单”，要写成一份基础 PRD 初稿。
5. 你必须补强模块细节，尤其是：
   - 模块目标是否清晰
   - 页面范围和交互边界是否清晰
   - 状态与变体是否覆盖到位
   - 框架型组件与平台通用能力组件是否已经分清
6. 平台通用能力组件只允许写成通用组件或接线层需求，不要绑定业务对象、业务消息流、业务审批流。
7. 框架型组件要明确 layout、app shell、导航容器、页头、区块容器、详情抽屉、空状态、加载态、错误态等组件边界。
8. 这份文档后续会在 `init-08` 被拆成 `confirmed-foundation.md` 和 `base-modules-prd.md` 两份输入，因此正文应只保留未来会被继续消费的内容，不要写生成过程、流程治理说明或交接话术。
9. `generation_workflow` 只需要保留在 YAML 结构里，不应在渲染后的 Markdown 中占据正文章节。
10. 输出必须严格遵循 `bootstrap_plan.template.yaml` 的字段名，只修改 `prd_bootstrap_context` 内容。

输出要求：

1. `prd_bootstrap_context.generation_workflow` 要体现“脚本初稿 + AI 补强 + reviewer 检查”的模式。
2. `document_goal`、`notes` 都应尽量短，只保留下一轮 PRD 真正会继续消费的内容边界。
3. `priority_modules` 至少覆盖：
   - 登录与认证基础
   - 账号与成员基础
   - 框架型组件基础
   - 平台通用能力组件基础
   - 租户上下文基础
   - 权限与访问控制基础
4. 每个模块都应写清 `objective` 和一组可执行的 `requirements`。
5. `reviewer_focus` 要能帮助 reviewer 判断：
   - 是否还是基础 PRD
   - 是否遗漏基础组件或状态边界
   - 是否混入具体业务前提

只输出最终 YAML，不要输出 Markdown 解释。
