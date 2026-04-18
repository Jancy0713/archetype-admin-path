# 项目初始化工作流文档

这个目录用于沉淀和 `项目初始化基座` 直接相关的流程、规则和结构化模板。

这里处理的不是普通功能 PRD，而是整个系统一开始就应尽量定清楚的基线：

- 项目画像
- 地区与语言
- 登录方式
- 账号体系
- 权限模型
- 租户模型
- UI 风格与主题
- 通用平台能力

当前 `project_profile` 已改成按阶段推进的初始化画像，不再是一张平铺的大表。推荐至少按下面顺序确认：

1. 地区、语言、系统类型、主要使用端
2. 租户模型、平台级 / 租户级管理结构
3. 登录方式、账号体系、权限模型
4. UI 风格、主题、通用平台能力

每个阶段都要单独走：

- AI 产出
- 脚本校验
- reviewer 审查
- Human Confirmation Gate

确认后才能进入下一阶段。

每个阶段内部还有两类问题：

- 固定题：必须完整出现，且 AI 应先给一轮建议值
- 额外题：默认不出现，只有特殊项目场景下才允许少量补充

当前推荐阅读顺序：

0. [待定与后续补充](/Users/wangwenjie/project/archetype-admin-path/docs/PENDING_ITEMS.md)
1. [流程指南](/Users/wangwenjie/project/archetype-admin-path/docs/init/WORKFLOW_GUIDE.md)
2. [步骤编号指南](/Users/wangwenjie/project/archetype-admin-path/docs/init/STEP_NAMING_GUIDE.md)
3. [Prompt 指南](/Users/wangwenjie/project/archetype-admin-path/docs/init/PROMPTS_GUIDE.md)
4. [主模型 Prompt](/Users/wangwenjie/project/archetype-admin-path/docs/init/prompts/MASTER_PROMPT.md)
5. [Reviewer Prompt](/Users/wangwenjie/project/archetype-admin-path/docs/init/prompts/REVIEWER_PROMPT.md)
6. [执行清单](/Users/wangwenjie/project/archetype-admin-path/docs/init/prompts/EXECUTION_CHECKLIST.md)
7. [结构化产物指南](/Users/wangwenjie/project/archetype-admin-path/docs/init/STRUCTURED_OUTPUT_GUIDE.md)
8. [总流程图](/Users/wangwenjie/project/archetype-admin-path/docs/WORKFLOW_FLOW_OVERVIEW.md)
9. [测试进度板模板](/Users/wangwenjie/project/archetype-admin-path/docs/WORKFLOW_PROGRESS_BOARD.md)
10. [运行目录规范](/Users/wangwenjie/project/archetype-admin-path/docs/RUNS_WORKSPACE_GUIDE.md)
11. [Run 初始化脚本](/Users/wangwenjie/project/archetype-admin-path/scripts/create_run.rb)
12. [自动运行指南](/Users/wangwenjie/project/archetype-admin-path/docs/AUTONOMOUS_RUN_GUIDE.md)
13. [版本规则](/Users/wangwenjie/project/archetype-admin-path/docs/VERSIONING.md)

如果要继续看底层规则和模板，再看：

14. [项目画像规则](/Users/wangwenjie/project/archetype-admin-path/docs/init/rules/PROJECT_PROFILE_RULE.md)
15. [基线汇总规则](/Users/wangwenjie/project/archetype-admin-path/docs/init/rules/BASELINE_RULE.md)
16. [初始化 Reviewer 规则](/Users/wangwenjie/project/archetype-admin-path/docs/init/rules/REVIEWER_RULE.md)
17. [初始化变更规则](/Users/wangwenjie/project/archetype-admin-path/docs/init/rules/CHANGE_REQUEST_RULE.md)
18. [项目画像 YAML 模板](/Users/wangwenjie/project/archetype-admin-path/docs/init/templates/structured/project_profile.template.yaml)
19. [Reviewer YAML 模板](/Users/wangwenjie/project/archetype-admin-path/docs/init/templates/structured/review.template.yaml)
20. [初始化基线 YAML 模板](/Users/wangwenjie/project/archetype-admin-path/docs/init/templates/structured/baseline.template.yaml)
21. [初始化变更 YAML 模板](/Users/wangwenjie/project/archetype-admin-path/docs/init/templates/structured/change_request.template.yaml)
22. [归档目录](/Users/wangwenjie/project/archetype-admin-path/docs/init/archive/README.md)

当前默认执行约束：

- AI 主产物直接写 YAML
- 主模型产出后先过脚本校验，再进入 reviewer
- reviewer 默认只审内容质量和基线推进决策
- 初始化变更和普通功能需求分开处理
- 推荐在文件名和 YAML 内同时使用 `init-01` 这种步骤编号

TODO：

- 统一转移到 [docs/PENDING_ITEMS.md](/Users/wangwenjie/project/archetype-admin-path/docs/PENDING_ITEMS.md)
