# PRD 工作流文档

这个目录用于沉淀和 `PRD 拆解` 直接相关的核心流程、规则和可执行 prompt。

为了减少干扰，当前结构做了收束：

- 根目录：只放你日常最常看的核心入口
- `rules/`：规则文档
- `templates/`：输出模板
- `prompts/`：可直接执行的 prompt
- `archive/`：参考资料、测试样例、过程产物

如果你平时只想看最关键的内容，先看下面 5 个就够：

当前推荐阅读顺序：

1. [流程指南](/Users/wangwenjie/project/archetype-admin-path/docs/prd/WORKFLOW_GUIDE.md)
2. [步骤编号指南](/Users/wangwenjie/project/archetype-admin-path/docs/prd/STEP_NAMING_GUIDE.md)
3. [Prompt 指南](/Users/wangwenjie/project/archetype-admin-path/docs/prd/PROMPTS_GUIDE.md)
4. [主模型 Prompt](/Users/wangwenjie/project/archetype-admin-path/docs/prd/prompts/MASTER_PROMPT.md)
5. [Reviewer Prompt](/Users/wangwenjie/project/archetype-admin-path/docs/prd/prompts/REVIEWER_PROMPT.md)
6. [执行清单](/Users/wangwenjie/project/archetype-admin-path/docs/prd/prompts/EXECUTION_CHECKLIST.md)
7. [结构化产物指南](/Users/wangwenjie/project/archetype-admin-path/docs/prd/STRUCTURED_OUTPUT_GUIDE.md)
8. [总流程图](/Users/wangwenjie/project/archetype-admin-path/docs/WORKFLOW_FLOW_OVERVIEW.md)
9. [测试进度板模板](/Users/wangwenjie/project/archetype-admin-path/docs/WORKFLOW_PROGRESS_BOARD.md)
10. [运行目录规范](/Users/wangwenjie/project/archetype-admin-path/docs/RUNS_WORKSPACE_GUIDE.md)
11. [Run 初始化脚本](/Users/wangwenjie/project/archetype-admin-path/scripts/create_run.rb)
12. [自动运行指南](/Users/wangwenjie/project/archetype-admin-path/docs/AUTONOMOUS_RUN_GUIDE.md)
13. [版本规则](/Users/wangwenjie/project/archetype-admin-path/docs/VERSIONING.md)

如果要继续看底层规则和模板，再看：

14. [需求补充提问规则](/Users/wangwenjie/project/archetype-admin-path/docs/prd/rules/REQUIREMENT_CLARIFICATION_RULE.md)
15. [需求补充提问 YAML 模板](/Users/wangwenjie/project/archetype-admin-path/docs/prd/templates/structured/clarification.template.yaml)
16. [Reviewer 规则](/Users/wangwenjie/project/archetype-admin-path/docs/prd/rules/REVIEWER_RULE.md)
17. [Reviewer YAML 模板](/Users/wangwenjie/project/archetype-admin-path/docs/prd/templates/structured/review.template.yaml)
18. [澄清版 Brief YAML 模板](/Users/wangwenjie/project/archetype-admin-path/docs/prd/templates/structured/brief.template.yaml)
19. [PRD 结构化拆解规则](/Users/wangwenjie/project/archetype-admin-path/docs/prd/rules/PRD_DECOMPOSITION_RULE.md)
20. [PRD 结构化拆解 YAML 模板](/Users/wangwenjie/project/archetype-admin-path/docs/prd/templates/structured/decomposition.template.yaml)
21. [结构化 YAML 模板目录](/Users/wangwenjie/project/archetype-admin-path/docs/prd/templates/structured)
22. [归档目录](/Users/wangwenjie/project/archetype-admin-path/docs/prd/archive/README.md)

过程资料都放在：

- [archive/reference/README.md](/Users/wangwenjie/project/archetype-admin-path/docs/prd/archive/reference/README.md)
- [archive/samples/1.0](/Users/wangwenjie/project/archetype-admin-path/docs/prd/archive/samples/1.0)

当前阶段的 PRD 拆解流程为：

- 需求接收后
- 主模型先做补充提问
- reviewer 审查
- 形成澄清版 brief
- 主模型做正式 PRD 结构化拆解
- reviewer 再审查
- 通过后才进入 contract 设计

当前统一最大 retry 次数：

- `2`

当前默认执行约束：

- AI 主产物直接写 YAML
- Markdown 只通过脚本渲染给人看
- 推荐在文件名和 YAML 内同时使用 `prd-01` 这种步骤编号
