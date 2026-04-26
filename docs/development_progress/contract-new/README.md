# Contract New Development Progress

这个目录现在保留三类东西：

- 方向定义
- 可直接执行的实施计划
- 已经明确需要执行的分步 prompt / workplan

## 当前定位

这次改造当前要统一写死的主链是：

```text
init -> prd -> contract_handoff -> contract -> openapi/swagger -> develop
```

也就是：

- `final_prd` 后显式增加 `05 Contract Handoff`
- 一份 PRD 可以拆成多个独立 contract flows
- 一个 contract flow 的正式终点是一个独立 `swagger/openapi`
- 前端代码生成和实现返工进入后续 `develop`

## 当前推荐入口

1. [CONTRACT_NEW_FULL_DIRECTION.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/contract-new/CONTRACT_NEW_FULL_DIRECTION.md)
2. [CONTRACT_NEW_IMPLEMENTATION_PLAN.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/contract-new/CONTRACT_NEW_IMPLEMENTATION_PLAN.md)
3. [CONTRACT_NEW_EXECUTION_RUNBOOK.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/contract-new/CONTRACT_NEW_EXECUTION_RUNBOOK.md)
4. [01_ENTRY_CLEANUP_AND_ALIGNMENT_WORKPLAN.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/contract-new/01_ENTRY_CLEANUP_AND_ALIGNMENT_WORKPLAN.md)
5. [02_CONTRACT_HANDOFF_DROP_WORKPLAN.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/contract-new/02_CONTRACT_HANDOFF_DROP_WORKPLAN.md)
6. [02_CONTRACT_HANDOFF_DROP_PROMPT.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/contract-new/02_CONTRACT_HANDOFF_DROP_PROMPT.md)
7. [03_SINGLE_FLOW_CONTRACT_RUN_WORKPLAN.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/contract-new/03_SINGLE_FLOW_CONTRACT_RUN_WORKPLAN.md)
8. [03_SINGLE_FLOW_CONTRACT_RUN_PROMPT.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/contract-new/03_SINGLE_FLOW_CONTRACT_RUN_PROMPT.md)
9. [04_DEVELOP_INPUT_AND_BASELINE_WORKPLAN.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/contract-new/04_DEVELOP_INPUT_AND_BASELINE_WORKPLAN.md)
10. [04_DEVELOP_INPUT_AND_BASELINE_PROMPT.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/contract-new/04_DEVELOP_INPUT_AND_BASELINE_PROMPT.md)
11. [05_EXAMPLES_SMOKE_CLEANUP_WORKPLAN.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/contract-new/05_EXAMPLES_SMOKE_CLEANUP_WORKPLAN.md)
12. [05_EXAMPLES_SMOKE_CLEANUP_PROMPT.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/contract-new/05_EXAMPLES_SMOKE_CLEANUP_PROMPT.md)
13. [06_CONTRACT_RUN_STANDARDIZATION_AND_HUMAN_OUTPUT_WORKPLAN.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/contract-new/06_CONTRACT_RUN_STANDARDIZATION_AND_HUMAN_OUTPUT_WORKPLAN.md)
14. [06_CONTRACT_RUN_STANDARDIZATION_AND_HUMAN_OUTPUT_PROMPT.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/contract-new/06_CONTRACT_RUN_STANDARDIZATION_AND_HUMAN_OUTPUT_PROMPT.md)
15. [07_CONTRACT_RELEASE_ARTIFACTS_AND_RUN_BOUNDARIES_WORKPLAN.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/contract-new/07_CONTRACT_RELEASE_ARTIFACTS_AND_RUN_BOUNDARIES_WORKPLAN.md)
16. [07_CONTRACT_RELEASE_ARTIFACTS_AND_RUN_BOUNDARIES_PROMPT.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/contract-new/07_CONTRACT_RELEASE_ARTIFACTS_AND_RUN_BOUNDARIES_PROMPT.md)
17. [08_CONTRACT_OPENAPI_SCHEMA_COMPLETENESS_WORKPLAN.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/contract-new/08_CONTRACT_OPENAPI_SCHEMA_COMPLETENESS_WORKPLAN.md)
18. [08_CONTRACT_OPENAPI_SCHEMA_COMPLETENESS_PROMPT.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/contract-new/08_CONTRACT_OPENAPI_SCHEMA_COMPLETENESS_PROMPT.md)
19. [09_PLUS_DEVELOP_INPUT_INDEX_AND_MOCK_STRATEGY.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/contract-new/09_PLUS_DEVELOP_INPUT_INDEX_AND_MOCK_STRATEGY.md)

## 怎么用

- 先看 `FULL_DIRECTION`，确认方向没有跑偏。
- 再看 `IMPLEMENTATION_PLAN`，确认整体施工顺序。
- 真正开工时只按 `EXECUTION_RUNBOOK` 一批一批执行，不要再拆探索性文档步骤。
- 如果当前只做第一步，直接看 `01_ENTRY_CLEANUP_AND_ALIGNMENT_WORKPLAN.md`。
- 如果当前做第二步，直接看 `02_CONTRACT_HANDOFF_DROP_WORKPLAN.md` 和 `02_CONTRACT_HANDOFF_DROP_PROMPT.md`。
- 如果当前做第三步，直接看 `03_SINGLE_FLOW_CONTRACT_RUN_WORKPLAN.md` 和 `03_SINGLE_FLOW_CONTRACT_RUN_PROMPT.md`。
- 如果当前做第四步，直接看 `04_DEVELOP_INPUT_AND_BASELINE_WORKPLAN.md` 和 `04_DEVELOP_INPUT_AND_BASELINE_PROMPT.md`。
- 如果当前做第五步，直接看 `05_EXAMPLES_SMOKE_CLEANUP_WORKPLAN.md` 和 `05_EXAMPLES_SMOKE_CLEANUP_PROMPT.md`。
- 如果当前做第六步，直接看 `06_CONTRACT_RUN_STANDARDIZATION_AND_HUMAN_OUTPUT_WORKPLAN.md` 和 `06_CONTRACT_RUN_STANDARDIZATION_AND_HUMAN_OUTPUT_PROMPT.md`。
- 如果当前做第七步，直接看 `07_CONTRACT_RELEASE_ARTIFACTS_AND_RUN_BOUNDARIES_WORKPLAN.md` 和 `07_CONTRACT_RELEASE_ARTIFACTS_AND_RUN_BOUNDARIES_PROMPT.md`。
- 如果当前做第八步，直接看 `08_CONTRACT_OPENAPI_SCHEMA_COMPLETENESS_WORKPLAN.md` 和 `08_CONTRACT_OPENAPI_SCHEMA_COMPLETENESS_PROMPT.md`。

## 当前状态

- 状态：planned_step_08
- 说明：第七步已完成并验证。第八步用于补强 OpenAPI schema 完整性，避免 Swagger 虽然非空但 `components.schemas` 只是空 object 壳。

## 后续规划

- Step 9+ 暂不执行，只记录方向：[09_PLUS_DEVELOP_INPUT_INDEX_AND_MOCK_STRATEGY.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/contract-new/09_PLUS_DEVELOP_INPUT_INDEX_AND_MOCK_STRATEGY.md)
- Step 9 推荐先做 multi-flow develop input index，正常顺序按 handoff 固定顺序一个一个 develop。
- Mock / API 切换 / 测试流程建议放到 Step 10+，但 Step 8 的 schema 应先保留 `example` / `examples` 钩子。
