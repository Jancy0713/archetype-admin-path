# 初始化流程 Prompt 指南

## 目标

这份文档把当前项目初始化流程变成一套可直接执行的 prompt 组合。

## 当前流程

当前流程覆盖：

1. 项目画像
2. reviewer 审查
3. 初始化基线
4. 设计约束基线
5. 初始化底座计划
6. 初始化执行
7. 初始化变更

当前统一最大 retry 次数：

- `2`

## 最小执行顺序

1. 用 `scripts/init/init_artifact.rb` 初始化当前步骤的 YAML 骨架
   `profile / foundation / bootstrap / execution` 已逐步增加 wrapper，优先使用分组 wrapper
2. 把项目描述或 PRD 提供给主模型
3. 使用 `主模型 Prompt` 直接填写 YAML
4. 运行 `validate_artifact.rb` 做结构和引用校验
5. 如果脚本校验失败，直接返给主模型修正，不进入 reviewer
6. 只有脚本通过后，才把结果交给 reviewer
7. 先用 `init_artifact.rb --step ... review ...` 初始化 reviewer 骨架
8. 使用 `Reviewer Prompt` 交给独立 reviewer 子 agent 填写 review YAML，主 agent 不得自己兼任 reviewer
9. 如需返工，最多返工 2 轮；每次返工后都要先重新过脚本校验
10. 通过后生成 `baseline`
11. `baseline` 确认后生成 `design_seed`
12. `design_seed` 通过脚本校验与 reviewer 后，再生成 `bootstrap_plan`
13. `bootstrap_plan` 通过脚本校验与 reviewer，并经人工确认后，进入 `init-08`
14. `init-08` 先生成 run 内专用执行 prompt、reviewer prompt 和待落位的项目规则文档，并明确要求用户新开干净上下文
15. 由新的执行代理完成工程初始化、规则文档落位与 AI 补强
16. 工程初始化完成后，必须交给独立 reviewer 子 agent / 新上下文审查；reviewer 通过后，执行代理再运行 `post_init_to_prd.rb` 生成新的 `prd` run
17. 新的 `prd` run 默认注入 `raw/attachments/confirmed-foundation.md`、`raw/attachments/base-modules-prd.md`，并补强 `prompts/run-agent-prompt.md`
18. 如需调整系统基线，再走 `change_request`

## 注意事项

1. 初始化流程先处理系统级基座，不处理普通功能细节。
2. reviewer 默认只审内容与推进决策，格式合法性由脚本先做门禁。
3. `project_profile` 必须按阶段推进，不再一次性平铺所有基线问题。
4. 每个阶段的固定确认项不能少，且应优先由 AI 给出推荐值和候选项。
5. 所有确认内容统一写进 `confirmation_items`，通过 `secondary / primary / required` 区分优先级，不再拆成多套结构。
6. 地区、租户、登录、账号、权限、UI 主题是高优先级基线。
7. 每个阶段都必须经过独立的人类确认，才能进入下一阶段。
8. `init-01` 到 `init-04` 的 Human Confirmation Gate 对外回复应使用“问题 + 选项 + 推荐项 + 说明”的确认格式。
9. 渲染出来的 `project_profile.md` 应是给人读的确认稿，而不是 YAML 的平铺转写。
10. Human Confirmation Gate 只应列真正待确认的问题；原始材料已足够明确的结论不应重复询问。
11. `confirmation_items` 内部不得语义重叠；同一件事不能拆成多个确认项重复表达。
12. 待确认项应带稳定编号，便于用户用固定格式回复修改意见。
13. `level: required` 的项必须持续追问，直到用户给出明确答复。
14. `init-05` 到 `init-07` 不能只依赖脚本预填；脚本负责骨架，主模型必须主动补强项目特征、默认边界和后续可继承细节。
15. `init-05 baseline` 当前默认不单独加 reviewer，先通过脚本校验并进入 human gate。
16. `init-06 design_seed` 与 `init-07 bootstrap_plan` 当前应保留 reviewer，但只在 `init-07` 统一停给用户确认。
17. `init-08 execution` 也必须补一轮独立 reviewer，但 reviewer 放在工程初始化完成之后执行，避免把主执行和审查职责混在同一个上下文中。

## Prompt 列表

分组入口：

- [prompts/README.md](/Users/wangwenjie/project/archetype-admin-path/docs/init/prompts/README.md)
- [profile](/Users/wangwenjie/project/archetype-admin-path/docs/init/prompts/profile/README.md)
- [foundation](/Users/wangwenjie/project/archetype-admin-path/docs/init/prompts/foundation/README.md)
- [bootstrap](/Users/wangwenjie/project/archetype-admin-path/docs/init/prompts/bootstrap/README.md)
- [execution](/Users/wangwenjie/project/archetype-admin-path/docs/init/prompts/execution/README.md)

- [MASTER_PROMPT.md](/Users/wangwenjie/project/archetype-admin-path/docs/init/prompts/MASTER_PROMPT.md)
- [BASELINE_PROMPT.md](/Users/wangwenjie/project/archetype-admin-path/docs/init/prompts/BASELINE_PROMPT.md)
- [DESIGN_SEED_PROMPT.md](/Users/wangwenjie/project/archetype-admin-path/docs/init/prompts/DESIGN_SEED_PROMPT.md)
- [BOOTSTRAP_PLAN_PROMPT.md](/Users/wangwenjie/project/archetype-admin-path/docs/init/prompts/BOOTSTRAP_PLAN_PROMPT.md)
- [PRD_BOOTSTRAP_CONTEXT_PROMPT.md](/Users/wangwenjie/project/archetype-admin-path/docs/init/prompts/PRD_BOOTSTRAP_CONTEXT_PROMPT.md)
- [INIT_EXECUTION_PROMPT.md](/Users/wangwenjie/project/archetype-admin-path/docs/init/prompts/INIT_EXECUTION_PROMPT.md)
- [REVIEWER_PROMPT.md](/Users/wangwenjie/project/archetype-admin-path/docs/init/prompts/REVIEWER_PROMPT.md)
- [EXECUTION_CHECKLIST.md](/Users/wangwenjie/project/archetype-admin-path/docs/init/prompts/EXECUTION_CHECKLIST.md)
- reviewer 示例：
  [init-06.review.sample.yaml](/Users/wangwenjie/project/archetype-admin-path/docs/init/archive/samples/init-06.review.sample.yaml) /
  [init-07.review.sample.yaml](/Users/wangwenjie/project/archetype-admin-path/docs/init/archive/samples/init-07.review.sample.yaml)

## 结构化配套

- [STRUCTURED_OUTPUT_GUIDE.md](/Users/wangwenjie/project/archetype-admin-path/docs/init/STRUCTURED_OUTPUT_GUIDE.md)
- [templates/structured](/Users/wangwenjie/project/archetype-admin-path/docs/init/templates/structured)
- [scripts/init](/Users/wangwenjie/project/archetype-admin-path/scripts/init)
- [scripts/init/README.md](/Users/wangwenjie/project/archetype-admin-path/scripts/init/README.md)
