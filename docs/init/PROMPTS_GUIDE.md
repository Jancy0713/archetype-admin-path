# 初始化流程 Prompt 指南

## 目标

这份文档把当前项目初始化流程变成一套可直接执行的 prompt 组合。

## 当前流程

当前流程覆盖：

1. 项目画像
2. reviewer 审查
3. 初始化基线
4. 初始化变更

当前统一最大 retry 次数：

- `2`

## 最小执行顺序

1. 用 `scripts/init/init_artifact.rb` 初始化当前步骤的 YAML 骨架
2. 把项目描述或 PRD 提供给主模型
3. 使用 `主模型 Prompt` 直接填写 YAML
4. 运行 `validate_artifact.rb` 做结构和引用校验
5. 如果脚本校验失败，直接返给主模型修正，不进入 reviewer
6. 只有脚本通过后，才把结果交给 reviewer
7. 先用 `init_artifact.rb --step ... review ...` 初始化 reviewer 骨架
8. 使用 `Reviewer Prompt` 直接填写 review YAML
9. 如需返工，最多返工 2 轮；每次返工后都要先重新过脚本校验
10. 通过后生成 `baseline`
11. 如需调整系统基线，再走 `change_request`

## 注意事项

1. 初始化流程先处理系统级基座，不处理普通功能细节。
2. reviewer 默认只审内容与推进决策，格式合法性由脚本先做门禁。
3. `project_profile` 必须按阶段推进，不再一次性平铺所有基线问题。
4. 每个阶段的固定题不能少，且应优先由 AI 给出推荐值和候选项。
5. `project_profile` 和 `baseline` 都应尽量少开放题，多使用推荐选项和推荐默认值。
5. 地区、租户、登录、账号、权限、UI 主题是高优先级基线。
6. 每个阶段都必须经过独立的人类确认，才能进入下一阶段。
7. `adaptive_questions` 默认不出现，只有当前阶段固定题不足以支撑判断时才允许补 1-2 题。

## Prompt 列表

- [MASTER_PROMPT.md](/Users/wangwenjie/project/archetype-admin-path/docs/init/prompts/MASTER_PROMPT.md)
- [REVIEWER_PROMPT.md](/Users/wangwenjie/project/archetype-admin-path/docs/init/prompts/REVIEWER_PROMPT.md)
- [EXECUTION_CHECKLIST.md](/Users/wangwenjie/project/archetype-admin-path/docs/init/prompts/EXECUTION_CHECKLIST.md)

## 结构化配套

- [STRUCTURED_OUTPUT_GUIDE.md](/Users/wangwenjie/project/archetype-admin-path/docs/init/STRUCTURED_OUTPUT_GUIDE.md)
- [templates/structured](/Users/wangwenjie/project/archetype-admin-path/docs/init/templates/structured)
- [scripts/init](/Users/wangwenjie/project/archetype-admin-path/scripts/init)
