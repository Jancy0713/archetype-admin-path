# PRD 工作流文档

这个目录用于沉淀当前正式版本的 `PRD 2.1.0` 流程、规则、模板和执行入口。

当前正式流程：

1. `prd-01 analysis`
2. `prd-02 clarification`
3. `prd-03 execution_plan`
4. `prd-04 final_prd`
5. `contract`

推荐阅读顺序：

1. [流程指南](/Users/wangwenjie/project/archetype-admin-path/docs/prd/WORKFLOW_GUIDE.md)
2. [步骤编号指南](/Users/wangwenjie/project/archetype-admin-path/docs/prd/STEP_NAMING_GUIDE.md)
3. [结构化产物指南](/Users/wangwenjie/project/archetype-admin-path/docs/prd/STRUCTURED_OUTPUT_GUIDE.md)
4. [Prompt 指南](/Users/wangwenjie/project/archetype-admin-path/docs/prd/PROMPTS_GUIDE.md)
5. [Prompt 索引](/Users/wangwenjie/project/archetype-admin-path/docs/prd/prompts/README.md)
6. [主模型 Prompt](/Users/wangwenjie/project/archetype-admin-path/docs/prd/prompts/MASTER_PROMPT.md)
7. [Reviewer Prompt](/Users/wangwenjie/project/archetype-admin-path/docs/prd/prompts/REVIEWER_PROMPT.md)
8. [执行清单](/Users/wangwenjie/project/archetype-admin-path/docs/prd/prompts/EXECUTION_CHECKLIST.md)
9. [步骤材料索引](/Users/wangwenjie/project/archetype-admin-path/docs/prd/steps/README.md)
10. [reviewer 材料](/Users/wangwenjie/project/archetype-admin-path/docs/prd/reviewer/README.md)
11. [模板目录](/Users/wangwenjie/project/archetype-admin-path/docs/prd/templates/structured)
12. [PRD 2.0 迭代规划](/Users/wangwenjie/project/archetype-admin-path/docs/prd/PRD_WORKFLOW_V2_PLAN.md)
13. [skill 选型说明](/Users/wangwenjie/project/archetype-admin-path/docs/prd/references/SKILL_SELECTION.md)
14. [to-prd adapter](/Users/wangwenjie/project/archetype-admin-path/docs/prd/references/TO_PRD_SKILL_ADAPTER.md)
15. [grill-me adapter](/Users/wangwenjie/project/archetype-admin-path/docs/prd/references/GRILL_ME_SKILL_ADAPTER.md)
16. [to-issues adapter](/Users/wangwenjie/project/archetype-admin-path/docs/prd/references/TO_ISSUES_SKILL_ADAPTER.md)
17. [总流程图](/Users/wangwenjie/project/archetype-admin-path/docs/WORKFLOW_FLOW_OVERVIEW.md)
18. [PRD workflow manifest](/Users/wangwenjie/project/archetype-admin-path/scripts/prd/workflow_manifest.rb)

底层规则与模板：

19. [需求分析规则](/Users/wangwenjie/project/archetype-admin-path/docs/prd/rules/ANALYSIS_RULE.md)
20. [需求澄清规则](/Users/wangwenjie/project/archetype-admin-path/docs/prd/rules/REQUIREMENT_CLARIFICATION_RULE.md)
21. [执行计划规则](/Users/wangwenjie/project/archetype-admin-path/docs/prd/rules/EXECUTION_PLAN_RULE.md)
22. [最终 PRD 规则](/Users/wangwenjie/project/archetype-admin-path/docs/prd/rules/FINAL_PRD_RULE.md)
23. [Reviewer 规则](/Users/wangwenjie/project/archetype-admin-path/docs/prd/rules/REVIEWER_RULE.md)
24. [analysis 模板](/Users/wangwenjie/project/archetype-admin-path/docs/prd/templates/structured/analysis.template.yaml)
25. [clarification 模板](/Users/wangwenjie/project/archetype-admin-path/docs/prd/templates/structured/clarification.template.yaml)
26. [execution_plan 模板](/Users/wangwenjie/project/archetype-admin-path/docs/prd/templates/structured/execution_plan.template.yaml)
27. [final_prd 模板](/Users/wangwenjie/project/archetype-admin-path/docs/prd/templates/structured/final_prd.template.yaml)
28. [review 模板](/Users/wangwenjie/project/archetype-admin-path/docs/prd/templates/structured/review.template.yaml)

当前统一约束：

- AI 主产物只写 YAML
- Markdown 只作为渲染给人看的视图层
- 每个关口最大 retry 为 `2`
- 不保留 `brief / decomposition` 的旧协议
- 结构化产物默认采用 `2.1.0` 模板，同时兼容读取 `2.0.0` 历史样例
- reviewer 必须由独立 reviewer 子 agent 或独立新上下文执行，主 agent 不得自己兼任 reviewer
- `2.1.0` 开始按步骤组织 prompt / reviewer / step materials，避免继续堆大文件
- `create_run`、首步产物、review step、render 路径等运行信息统一从 PRD workflow manifest 读取
- 已接入的外部 skill 只作为步骤内辅助参考，不替代当前 YAML、校验器、render 和 handoff 协议
