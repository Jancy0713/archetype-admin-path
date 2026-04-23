# PRD Prompt 索引

`2.1.0` 起，PRD prompt 材料按“通用 + 分步骤补充”组织，不再只靠单个总 prompt 文件承载全部上下文。

## 入口顺序

1. 通用主 prompt：
   - [MASTER_PROMPT.md](/Users/wangwenjie/project/archetype-admin-path/docs/prd/prompts/MASTER_PROMPT.md)
2. 当前步骤补充 prompt：
   - [analysis step prompt](/Users/wangwenjie/project/archetype-admin-path/docs/prd/prompts/analysis/STEP_PROMPT.md)
   - [clarification step prompt](/Users/wangwenjie/project/archetype-admin-path/docs/prd/prompts/clarification/STEP_PROMPT.md)
   - [execution_plan step prompt](/Users/wangwenjie/project/archetype-admin-path/docs/prd/prompts/execution_plan/STEP_PROMPT.md)
   - [final_prd step prompt](/Users/wangwenjie/project/archetype-admin-path/docs/prd/prompts/final_prd/STEP_PROMPT.md)
3. skill 参考：
   - [to-prd skill adapter](/Users/wangwenjie/project/archetype-admin-path/docs/prd/references/TO_PRD_SKILL_ADAPTER.md)
   - [grill-me skill adapter](/Users/wangwenjie/project/archetype-admin-path/docs/prd/references/GRILL_ME_SKILL_ADAPTER.md)
   - [to-issues skill adapter](/Users/wangwenjie/project/archetype-admin-path/docs/prd/references/TO_ISSUES_SKILL_ADAPTER.md)
   - [skill selection](/Users/wangwenjie/project/archetype-admin-path/docs/prd/references/SKILL_SELECTION.md)
4. reviewer 入口：
   - [REVIEWER_PROMPT.md](/Users/wangwenjie/project/archetype-admin-path/docs/prd/prompts/REVIEWER_PROMPT.md)
   - [reviewer materials](/Users/wangwenjie/project/archetype-admin-path/docs/prd/reviewer/README.md)
5. 执行总清单：
   - [EXECUTION_CHECKLIST.md](/Users/wangwenjie/project/archetype-admin-path/docs/prd/prompts/EXECUTION_CHECKLIST.md)

## 使用规则

1. 主模型至少同时读取：
   - 通用主 prompt
   - 当前步骤 step prompt
   - 当前步骤规则文档
   - 当前步骤 YAML 模板
2. 如果当前步骤材料提供了 skill adapter，可以额外读取，但它不是正式协议。
3. reviewer 至少同时读取：
   - reviewer prompt
   - reviewer 通用规则
   - 当前阶段 checklist
   - review YAML 模板
4. 如果当前只需要定位单一步骤材料，优先从 [steps index](/Users/wangwenjie/project/archetype-admin-path/docs/prd/steps/README.md) 进入。
