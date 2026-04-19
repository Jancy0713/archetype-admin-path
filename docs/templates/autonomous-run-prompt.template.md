# Autonomous Run Prompt

你现在负责执行一整轮 `{{FLOW}}` 流程。

你的目标不是只做当前一步，而是在同一个对话里持续推进，直到遇到必须人工确认的关口再停下。

## 运行目录

- `{{RUN_ROOT}}`

## 你必须先读取

- `{{RUN_ROOT}}/raw/request.md`
- `{{RUN_ROOT}}/raw/attachments/`
- `{{RUN_ROOT}}/progress/workflow-progress.md`
- `/Users/wangwenjie/project/archetype-admin-path/docs/AUTONOMOUS_RUN_GUIDE.md`
- `/Users/wangwenjie/project/archetype-admin-path/docs/RUNS_WORKSPACE_GUIDE.md`
- `{{FLOW_README}}`
- `{{FLOW_WORKFLOW_GUIDE}}`
- `{{FLOW_STEP_GUIDE}}`

## 你的运行原则

1. 你必须自己判断当前应该推进哪个 step。
2. 你必须把所有正式产物写入当前 run 目录，不要写到别处。
3. 你必须保留完整流程产物，包括主 YAML、review YAML、rendered Markdown。
4. 每次主产物生成后，必须先跑脚本校验。
5. 校验失败时，不进入 reviewer，直接修正当前 YAML。
6. reviewer 必须存在，但由你在同一个对话里内部完成。
7. reviewer 不通过时，你必须返工当前主产物，而不是跳步。
8. 每次状态变化后，你都必须更新 `progress/workflow-progress.md`。
9. 只有遇到 Human Confirmation Gate 或 blocker，才停下来向用户汇报。
10. 你不能假装运行了脚本；需要实际执行脚本并根据结果推进。
11. 对 `init-05`、`init-06`、`init-07`，脚本预填只代表骨架初始化；你必须主动补强项目细节、默认边界和后续可继承约束，不能把脚本初稿直接当成最终结果。

## 你当前的默认推进目标

- 从第一步开始，自动推进到第一个必须人工确认的关口

## 当你推进主产物时

你必须按下面顺序执行：

1. 找到当前 step 对应的正式 YAML
2. 如果文件还不存在，先初始化
3. 填写或修正 YAML
4. 运行 `validate`
5. 如果通过，生成 reviewer YAML
6. 完成 reviewer 审查
7. 如果 reviewer 通过，渲染 Markdown
8. 更新进度板
9. 判断是否继续推进下一步，或停在人工确认点

## 进度板要求

你必须维护：

- 当前 `current_step_id`
- `overall_status`
- 当前步骤所在行的 `status`
- `attempt`
- `output`
- `reviewer`
- `next`

## 停下来向用户汇报时，你的输出必须包含

1. 当前停在哪个 step
2. 为什么现在需要人工介入
3. 需要用户确认或回答什么
4. 当前 run 目录下的关键文件路径

如果当前停在 Human Confirmation Gate，你必须额外遵守：

1. 不要只给一段普通说明，必须先明确告知用户：完整待确认内容见对应 `rendered/*.md`，请先人工通读一遍。
2. 对 `init-01` 到 `init-04` 这类问卷式阶段，每个问题都要使用下面格式：
   - `问题1：<问题标题>【单选/可多选】`
   - `编号：<step-id-xx>`
   - `a. <选项A>`
   - `b. <选项B>`
   - `推荐：<推荐选项字母>`
   - `说明：<为什么这样推荐>`
   - 如现有选项都不合适，应提示用户可回复 `自定义: ...`
3. 对 `init-05 baseline`，不要再输出“必须回复项 / 重点确认项 / 次要确认项 / 回复格式示例”那套问卷结构；只需要告诉用户去通读 `rendered/init-05.baseline.md`，确认 baseline 是否可以作为后续默认输入。
4. 对 `init-07 bootstrap_plan`，默认同时提醒用户查看 `rendered/init-06.design_seed.md` 和 `rendered/init-07.bootstrap_plan.md`；重点是确认 bootstrap_plan 是否足够具体、是否能直接指导初始化基座实现。
5. 对 `init-07 bootstrap_plan`，在用户确认三份内容时，你还必须额外给出一个固定问题：`项目名称是什么？`
6. 项目名称必须提供 3 个候选：
   - `a. <主推荐名称>`
   - `b. <备选名称>`
   - `c. <备选名称>`
   - 默认推荐为 `a`
7. 如果用户只回复“bootstrap_plan 确认，继续”或未对项目名称提出异议，默认采用 `a`。
8. 你还必须同时告知 `init-08` 的默认执行参数：
   - 初始化目录：当前项目根目录
   - git 处理：默认删除现有 `.git`
   - 用户如需修改，可直接回复：
     - `项目名称改为 [b]`
     - `项目名称改为 [自定义: xxx]`
     - `初始化目录改为 /abs/path`
     - `保留 git`
     - `保留 git，remote-url 改为 https://...`
9. `init-07` 用户确认通过后，你应继续执行 `init-08`，按 `Init Execution Scope` 初始化项目。
10. 进入 `init-08` 后，你必须先运行脚本生成执行包，其中至少包括：
    - `rendered/init-08.init-execution-scope.md`
    - `docs/project/project-conventions.md`
    - `prompts/init-08-execution-prompt.md`
11. 你必须把 `prompts/init-08-execution-prompt.md` 交给执行代理，让其完成工程初始化命令与 AI 补强。
12. 执行代理完成初始化后，你必须先向用户汇报本次初始化完成了哪些工作，然后自动继续：
    - 执行 `post_init_to_prd.rb`
    - 基于项目 id 创建新的 `prd` run
    - 把干净版 `PRD Bootstrap Context` 注入到新的 PRD run
    - 预填 `raw/request.md`
    - 生成引用规则文档的 PRD 启动提示词
13. 已经足够明确、但仍允许用户改动的内容，应只放在“次要确认项”里展示，不要再作为“重点确认项”重复提问。
14. 如果存在 `level: required` 的确认项，必须单独标成“必须回复项”；这类问题在用户明确答复前不能继续推进。
15. 回答用户时，优先引用 `rendered/*.md` 里的可读稿，不要把 YAML 结构直接摊给用户。
16. 只有在 `init-01` 到 `init-04` 时，你才需要给出固定回复格式示例：
   - `按推荐继续`
   - `编号 init-01-02 改为 [b]`
   - `编号 init-01-02 改为 [自定义: xxx]`
   - `编号 init-01-04 回复：<明确答案>`
17. 对 `init-05` 和 `init-07`，默认引导用户直接回复：
   - `baseline 确认，继续`
   - `bootstrap_plan 确认，继续`
   - 或者直接写“把 xxx 改成 yyy”

## 当前流程信息

- flow: `{{FLOW}}`
- first_step_id: `{{FIRST_STEP_ID}}`
- first_artifact: `{{FIRST_ARTIFACT}}`
- first_review: `{{FIRST_REVIEW}}`
- validate_command: `{{VALIDATE_COMMAND}}`
- render_command: `{{RENDER_COMMAND}}`

## Flow Command Cheat Sheet

{{FLOW_COMMANDS}}
