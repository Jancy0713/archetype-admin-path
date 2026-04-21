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
- `{{FLOW_PROMPTS_INDEX}}`
- `{{FLOW_REFACTOR_GUIDE}}`

## 你的运行原则

1. 你必须自己判断当前应该推进哪个 step。
2. 你必须把所有正式产物写入当前 run 目录，不要写到别处。
3. 你必须保留完整流程产物，包括主 YAML、review YAML、rendered Markdown。
4. 每次主产物生成后，必须先跑脚本校验。
5. 校验失败时，不进入 reviewer，直接修正当前 YAML。
6. reviewer 必须存在，且必须由独立 reviewer 子 agent 或独立新上下文完成；主 agent 只能准备 reviewer 输入、读取 reviewer 结果并据此返工，不能自己兼任 reviewer。
7. reviewer 不通过时，你必须返工当前主产物，而不是跳步。
8. 每次状态变化后，你都必须更新 `progress/workflow-progress.md`。
9. 只有遇到 Human Confirmation Gate 或 blocker，才停下来向用户汇报。
10. 你不能假装运行了脚本；需要实际执行脚本并根据结果推进。
11. 如果 `init` 的分组 checklist、wrapper 脚本与旧总览文档出现表述差异，优先遵循分组 checklist 与实际脚本入口。
12. 对 `init-05`、`init-06`、`init-07`，脚本预填只代表骨架初始化；你必须主动补强项目细节、默认边界和后续可继承约束，不能把脚本初稿直接当成最终结果。
13. `init-05 baseline` 当前默认不单独加 reviewer；应在脚本校验通过并渲染后直接进入 human gate。
14. `init-06 design_seed` 与 `init-07 bootstrap_plan` 当前都应保留 reviewer，但 `init-06` 不单独停给人，而是在 `init-07` 一并给用户确认。
15. `init-08 execution` 也必须在工程初始化完成后补一轮独立 reviewer；主执行 agent 不得兼任 reviewer。

`init` 分组检查清单：

- `profile`：`/Users/wangwenjie/project/archetype-admin-path/docs/init/prompts/profile/EXECUTION_CHECKLIST.md`
- `foundation`：`/Users/wangwenjie/project/archetype-admin-path/docs/init/prompts/foundation/EXECUTION_CHECKLIST.md`
- `bootstrap`：`/Users/wangwenjie/project/archetype-admin-path/docs/init/prompts/bootstrap/EXECUTION_CHECKLIST.md`
- `execution`：`/Users/wangwenjie/project/archetype-admin-path/docs/init/prompts/execution/EXECUTION_CHECKLIST.md`

## 你当前的默认推进目标

- 从第一步开始，自动推进到第一个必须人工确认的关口

## 当你推进主产物时

你必须按下面顺序执行：

1. 找到当前 step 对应的正式 YAML
2. 如果文件还不存在，先初始化
3. 填写或修正 YAML
4. 运行 `validate`
5. 如果通过，生成 reviewer YAML
6. 调用 reviewer 子 agent 完成 reviewer 审查
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
4. 对 `init-07 bootstrap_plan`，默认同时提醒用户查看 `rendered/init-06.design_seed.md`、`rendered/init-07.bootstrap_plan.md`、`rendered/init-07.project-conventions.md`、`rendered/init-07.prd-bootstrap-context.md` 和 `rendered/init-07.init-execution-scope.md`；重点是确认 bootstrap_plan、长期项目规则、PRD 交接输入和 execution scope 是否都足够具体、是否能直接指导初始化基座实现。
5. 对 `init-07 bootstrap_plan`，在用户确认三份内容时，你还必须额外给出一个固定问题：`项目名称是什么？`
6. 你还必须额外确认：本地初始化目录名称是什么；这是目录名，不等于项目名称，默认应给出英文/slug 形式候选。
7. 项目名称必须提供 3 个候选：
   - `a. <主推荐名称>`
   - `b. <备选名称>`
   - `c. <备选名称>`
   - 默认推荐为 `a`
8. 目录名称也必须提供 2 到 3 个候选，优先使用适合本地目录的英文、小写、连字符 slug；默认推荐第一个。
9. 如果用户只回复“bootstrap_plan 确认，继续”或未对项目名称、目录名称提出异议，默认采用推荐项。
10. 你还必须同时告知 `init-08` 的默认执行参数：
   - 初始化位置：当前工作区根目录下创建目录 `<目录名称>`，该目录本身就是项目根目录
   - git 处理：默认删除现有 `.git`
   - 用户如需修改，可直接回复：
     - `项目名称改为 [b]`
     - `项目名称改为 [自定义: xxx]`
     - `目录名称改为 [b]`
     - `目录名称改为 [自定义: xxx]`
     - `初始化目录改为 /abs/path`
     - `保留 git`
     - `保留 git，remote-url 改为 https://...`
11. `init-07` 结束前，你必须实际生成 `rendered/init-07.init-execution-scope.md`，把它作为 human gate 的待确认材料之一。
12. `init-07` 用户确认通过后，你不能继续在当前长上下文里直接执行 `init-08`；必须先生成新的执行 prompt，供用户开启一个干净上下文或新的执行 agent 去跑 `init-08`。
13. 进入 `init-08` 后，你必须先基于已确认的项目名称、目录名称、初始化位置和 git 参数生成执行包，其中至少包括：
    - `rendered/init-08.project-conventions.md`
    - `prompts/init-08-execution-prompt.md`
    - `prompts/init-08-reviewer-prompt.md`
14. 你必须明确告知用户：应新开一个上下文，把 `prompts/init-08-execution-prompt.md` 整段交给执行代理；不要让当前主 agent 继续在已堆叠 01-07 上下文的对话里直接执行。
15. 执行代理完成初始化后，必须先把 `prompts/init-08-reviewer-prompt.md` 交给独立 reviewer 子 agent 或独立新上下文。
16. reviewer 通过后，执行代理再自动继续：
    - 执行 `post_init_to_prd.rb`
    - 基于项目 id 创建新的 `prd` run
    - 写入 `raw/attachments/confirmed-foundation.md`
    - 写入 `raw/attachments/base-modules-prd.md`
    - 预填 `raw/request.md`
    - 正确生成并补强新的 PRD 启动提示词
17. 已经足够明确、但仍允许用户改动的内容，应只放在“次要确认项”里展示，不要再作为“重点确认项”重复提问。
18. 如果存在 `level: required` 的确认项，必须单独标成“必须回复项”；这类问题在用户明确答复前不能继续推进。
19. 回答用户时，优先引用 `rendered/*.md` 里的可读稿，不要把 YAML 结构直接摊给用户。
20. 只有在 `init-01` 到 `init-04` 时，你才需要给出固定回复格式示例：
   - `按推荐继续`
   - `编号 init-01-02 改为 [b]`
   - `编号 init-01-02 改为 [自定义: xxx]`
   - `编号 init-01-04 回复：<明确答案>`
21. 对 `init-05` 和 `init-07`，默认引导用户直接回复：
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
