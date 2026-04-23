# PRD Reviewer Materials

`2.1.0` 起，reviewer 材料从主流程规则中拆开，按“通用约束 + 阶段 checklist”组织。

## reviewer 读取顺序

1. [Reviewer Prompt](/Users/wangwenjie/project/archetype-admin-path/docs/prd/prompts/REVIEWER_PROMPT.md)
2. [reviewer workflow](/Users/wangwenjie/project/archetype-admin-path/docs/prd/reviewer/common/REVIEWER_WORKFLOW.md)
3. 当前阶段 checklist：
   - [prd_analysis](/Users/wangwenjie/project/archetype-admin-path/docs/prd/reviewer/checklists/prd_analysis.md)
   - [prd_clarification](/Users/wangwenjie/project/archetype-admin-path/docs/prd/reviewer/checklists/prd_clarification.md)
   - [prd_execution_plan](/Users/wangwenjie/project/archetype-admin-path/docs/prd/reviewer/checklists/prd_execution_plan.md)
   - [final_prd_ready](/Users/wangwenjie/project/archetype-admin-path/docs/prd/reviewer/checklists/final_prd_ready.md)
4. [review.template.yaml](/Users/wangwenjie/project/archetype-admin-path/docs/prd/templates/structured/review.template.yaml)

## 当前目标

1. reviewer 真正承担门禁角色，而不是泛泛挑错。
2. 每个阶段都能看到专项检查项。
3. reviewer 输入和输出格式保持稳定，便于主 agent 按结果返工。
