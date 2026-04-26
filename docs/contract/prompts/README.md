# Contract Prompt 索引

当前 `contract` 的 prompt 层应参考现有 `prd` 的组织方式。

目标形态应是：

1. 通用主 prompt
2. 当前步骤 step prompt
3. reviewer prompt
4. 必要时补执行清单

推荐后续结构：

```text
docs/contract/prompts/
  README.md
  MASTER_PROMPT.md
  REVIEWER_PROMPT.md
  EXECUTION_CHECKLIST.md
  scope_intake/
    STEP_PROMPT.md
  domain_mapping/
    STEP_PROMPT.md
  contract_spec/
    STEP_PROMPT.md
  review/
    STEP_PROMPT.md
```

这样设计的原因：

- 与 `docs/prd/prompts/` 的外层主 prompt + 分步骤 prompt 模式保持一致
- 方便后续步骤材料索引和脚本入口统一风格
- 避免 prompt 只存在于聊天框或零散 run 文件里

当前阶段已补第一批 prompt 骨架，当前先固定目录职责：

- `MASTER_PROMPT.md`
  - 承载 contract 全流程通用约束
- `REVIEWER_PROMPT.md`
  - 承载 reviewer 通用审查约束
- `EXECUTION_CHECKLIST.md`
  - 承载主 agent 的总执行清单
  - 当前聚焦单 flow run 的 working/release 边界与 review/release gate
- `*/STEP_PROMPT.md`
  - 承载每个步骤特有的输入、输出、重点和禁止事项
