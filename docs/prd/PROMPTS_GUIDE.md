# PRD 流程 Prompt 指南

## 目标

这份文档把当前 PRD 拆解流程变成一套可直接执行的 prompt 组合。

也就是说，你不只是有规则和模板，还可以直接把这里的内容复制给主模型和 reviewer 使用。

## 当前流程

当前流程只覆盖到：

1. 需求补充提问
2. reviewer 审查
3. 澄清版 brief
4. PRD 结构化拆解
5. reviewer 再审查

当前统一最大 retry 次数：

- `2`

当前也开始引入结构化产物：

- 优先让 AI 填 `YAML`
- 再通过脚本渲染成 `Markdown`
- reviewer 与人工审核也尽量走固定结构
- 对未明确的信息优先给“推荐选项”或“推荐默认值”，尽量少用开放题

## 最小执行顺序

1. 用 `scripts/prd/init_artifact.rb` 初始化当前步骤的 YAML 骨架
2. 把原始输入和对应 YAML 模板提供给主模型
3. 使用 `主模型 Prompt` 直接填写 YAML
4. 运行 `validate_artifact.rb` 做结构和引用校验
5. 如果脚本校验失败，直接返给主模型修正，不进入 reviewer
6. 只有脚本通过后，才把 YAML 结果交给 reviewer
7. 先用 `init_artifact.rb --step ... review ...` 初始化 reviewer 骨架
8. 使用 `Reviewer Prompt` 直接填写 review YAML
9. 如需返工，最多返工 2 轮；每次返工后都要先重新过脚本校验
10. 通过后进入 `brief` 和 `decomposition` 的下一步 YAML 产出
11. 如需人工阅读，再用 `render_artifact.rb` 渲染 Markdown

## 注意事项

1. reviewer 只负责审查，不重写正文。
2. 超过最大 retry 次数后，必须升级给人。
3. 如果原始输入本身缺失严重，允许 reviewer 直接打回，不进入下一步。
4. YAML 是唯一主输出，Markdown 只是展示层。
5. `brief` 必须引用 `clarification`，`decomposition` 必须引用 `brief`，`review` 必须指向真实被审 YAML。
6. reviewer 默认只审内容与推进决策，格式合法性由脚本先做门禁。
7. `decision_candidates` 用于用户必须明确选择的关键问题，`proposed_defaults` 用于常规项的推荐默认值。

## Prompt 列表

- [MASTER_PROMPT.md](/Users/wangwenjie/project/archetype-admin-path/docs/prd/prompts/MASTER_PROMPT.md)
- [REVIEWER_PROMPT.md](/Users/wangwenjie/project/archetype-admin-path/docs/prd/prompts/REVIEWER_PROMPT.md)
- [EXECUTION_CHECKLIST.md](/Users/wangwenjie/project/archetype-admin-path/docs/prd/prompts/EXECUTION_CHECKLIST.md)

## 结构化配套

- [STRUCTURED_OUTPUT_GUIDE.md](/Users/wangwenjie/project/archetype-admin-path/docs/prd/STRUCTURED_OUTPUT_GUIDE.md)
- [templates/structured](/Users/wangwenjie/project/archetype-admin-path/docs/prd/templates/structured)
- [scripts/prd](/Users/wangwenjie/project/archetype-admin-path/scripts/prd)
