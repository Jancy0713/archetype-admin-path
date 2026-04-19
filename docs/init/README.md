# 项目初始化工作流文档

这个目录用于沉淀和 `项目初始化基座` 直接相关的流程、规则和结构化模板。

这里处理的不是普通功能 PRD，而是整个系统一开始就应尽量定清楚的基线：

- 项目画像
- 地区与语言
- 登录方式
- 账号体系
- 权限模型
- 租户模型
- UI 风格方案与主题
- 通用平台能力

当前 `init` 建议拆成三层，而不是 `baseline` 后直接进入普通 PRD：

1. `init-01` 到 `init-04`：阶段化问卷确认
2. `init-05`：整体 baseline 定稿
3. `init-06` 到 `init-07`：把 baseline 收敛成后续默认继承的设计约束与初始化计划

其中 `project_profile` 已改成按阶段推进的初始化画像，不再是一张平铺的大表。推荐至少按下面顺序确认：

1. 地区、语言、系统类型、主要使用端
2. 租户模型、平台级 / 租户级管理结构
3. 登录方式、账号体系、权限模型
4. UI 风格方案、主题、通用平台能力

每个阶段都要单独走：

- AI 产出
- 脚本校验
- reviewer 审查
- Human Confirmation Gate

确认后才能进入下一阶段。

每个阶段内部还有两类问题：

- 固定题：必须完整出现，且 AI 应先给一轮建议值
- 额外题：默认不出现，只有特殊项目场景下才允许少量补充

其中 `experience_platform` 阶段的 `ui_style_recipe` 应按“顾问式推荐”处理：

- AI 先根据系统类型给推荐风格组合
- 再给 2-4 个可替代候选
- 每个候选都附带简短文字化预览
- 用户仍可自定义组合

但用户只需要选择整体风格方向，不需要拍脑袋确认圆角、阴影、spacing token 这类具体数值。
这些具体参数应在后续 `design_seed` 中由 AI 基于选中的风格和参考 skill 自动收敛。

## 当前推荐 init 顺序

1. `init-01` `foundation_context`
2. `init-02` `tenant_governance`
3. `init-03` `identity_access`
4. `init-04` `experience_platform`
5. `init-05` `baseline`
6. `init-06` `design_seed`
7. `init-07` `bootstrap_plan`
8. `init-08` `execution`

说明：

- `init-01` 到 `init-04` 是问卷式确认阶段，均需要人工确认
- `init-05` 是对问卷结果的整体收口，仍需要人工确认
- `init-06` 不单独要求人工确认，由 AI 基于已确认 baseline 继续补强并收敛；脚本只负责骨架初始化与格式校验
- `init-07` 用于确认“哪些初始化底座工作应该先做”，结尾需要再次人工确认
- `init-08` 在 `bootstrap_plan` 确认后执行初始化，并自动创建新的 PRD run

`init-08` 完成后，再进入自动创建的 `prd-01`

当前状态说明：

- 本轮已先把 `init-06` / `init-07` 正式纳入流程定义
- `design_seed / bootstrap_plan` 已接入独立 YAML 模板、脚本初始化、校验和 Markdown 渲染
- `bootstrap_plan` 下的 `project_conventions` 是项目内长期规则文件；`init_execution_scope` 和 `prd_bootstrap_context` 则是 init / prd 流程的执行依据
- `scripts/init/prefill_from_upstream.rb` 已支持从上游产物预填 06/07 初稿
- 脚本负责结构约束、骨架初始化和格式校验；05-07 的内容增强、细节补全和语义收敛应由 AI 完成

当前推荐阅读顺序：

0. [待定与后续补充](/Users/wangwenjie/project/archetype-admin-path/docs/PENDING_ITEMS.md)
1. [流程指南](/Users/wangwenjie/project/archetype-admin-path/docs/init/WORKFLOW_GUIDE.md)
2. [步骤编号指南](/Users/wangwenjie/project/archetype-admin-path/docs/init/STEP_NAMING_GUIDE.md)
3. [Prompt 指南](/Users/wangwenjie/project/archetype-admin-path/docs/init/PROMPTS_GUIDE.md)
4. [主模型 Prompt](/Users/wangwenjie/project/archetype-admin-path/docs/init/prompts/MASTER_PROMPT.md)
5. [Design Seed Prompt](/Users/wangwenjie/project/archetype-admin-path/docs/init/prompts/DESIGN_SEED_PROMPT.md)
6. [Bootstrap Plan Prompt](/Users/wangwenjie/project/archetype-admin-path/docs/init/prompts/BOOTSTRAP_PLAN_PROMPT.md)
7. [PRD Bootstrap Context Prompt](/Users/wangwenjie/project/archetype-admin-path/docs/init/prompts/PRD_BOOTSTRAP_CONTEXT_PROMPT.md)
8. [Reviewer Prompt](/Users/wangwenjie/project/archetype-admin-path/docs/init/prompts/REVIEWER_PROMPT.md)
9. [执行清单](/Users/wangwenjie/project/archetype-admin-path/docs/init/prompts/EXECUTION_CHECKLIST.md)
10. [结构化产物指南](/Users/wangwenjie/project/archetype-admin-path/docs/init/STRUCTURED_OUTPUT_GUIDE.md)
11. [总流程图](/Users/wangwenjie/project/archetype-admin-path/docs/WORKFLOW_FLOW_OVERVIEW.md)
12. [测试进度板模板](/Users/wangwenjie/project/archetype-admin-path/docs/WORKFLOW_PROGRESS_BOARD.md)
13. [运行目录规范](/Users/wangwenjie/project/archetype-admin-path/docs/RUNS_WORKSPACE_GUIDE.md)
14. [Run 初始化脚本](/Users/wangwenjie/project/archetype-admin-path/scripts/create_run.rb)
15. [自动运行指南](/Users/wangwenjie/project/archetype-admin-path/docs/AUTONOMOUS_RUN_GUIDE.md)
16. [版本规则](/Users/wangwenjie/project/archetype-admin-path/docs/VERSIONING.md)

如果要继续看底层规则和模板，再看：

14. [项目画像规则](/Users/wangwenjie/project/archetype-admin-path/docs/init/rules/PROJECT_PROFILE_RULE.md)
15. [基线汇总规则](/Users/wangwenjie/project/archetype-admin-path/docs/init/rules/BASELINE_RULE.md)
16. [初始化 Reviewer 规则](/Users/wangwenjie/project/archetype-admin-path/docs/init/rules/REVIEWER_RULE.md)
17. [初始化变更规则](/Users/wangwenjie/project/archetype-admin-path/docs/init/rules/CHANGE_REQUEST_RULE.md)
18. [项目画像 YAML 模板](/Users/wangwenjie/project/archetype-admin-path/docs/init/templates/structured/project_profile.template.yaml)
19. [Reviewer YAML 模板](/Users/wangwenjie/project/archetype-admin-path/docs/init/templates/structured/review.template.yaml)
20. [初始化基线 YAML 模板](/Users/wangwenjie/project/archetype-admin-path/docs/init/templates/structured/baseline.template.yaml)
21. [设计约束基线 YAML 模板](/Users/wangwenjie/project/archetype-admin-path/docs/init/templates/structured/design_seed.template.yaml)
22. [初始化底座计划 YAML 模板](/Users/wangwenjie/project/archetype-admin-path/docs/init/templates/structured/bootstrap_plan.template.yaml)
23. [初始化变更 YAML 模板](/Users/wangwenjie/project/archetype-admin-path/docs/init/templates/structured/change_request.template.yaml)
24. [归档目录](/Users/wangwenjie/project/archetype-admin-path/docs/init/archive/README.md)

当前默认执行约束：

- AI 主产物直接写 YAML
- 主模型产出后先过脚本校验，再进入 reviewer
- reviewer 默认只审内容质量和基线推进决策
- 初始化变更和普通功能需求分开处理
- 推荐在文件名和 YAML 内同时使用 `init-01` 这种步骤编号

TODO：

- 统一转移到 [docs/PENDING_ITEMS.md](/Users/wangwenjie/project/archetype-admin-path/docs/PENDING_ITEMS.md)
