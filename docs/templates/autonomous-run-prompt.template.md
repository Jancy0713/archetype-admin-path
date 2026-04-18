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
2. 每个问题都要使用下面格式：
   - `问题1：<问题标题>【单选/可多选】`
   - `编号：<step-id-xx>`
   - `a. <选项A>`
   - `b. <选项B>`
   - `推荐：<推荐选项字母>`
   - `说明：<为什么这样推荐>`
   - 如现有选项都不合适，应提示用户可回复 `自定义: ...`
3. 只列真正需要用户拍板的“待确认项”，不要把已经足够明确的结论机械重复询问。
4. 如果当前阶段没有真正待确认项，要直接说明“本阶段无额外关键确认项”，并要求用户阅读 Markdown 后回复 `按推荐继续` 或按编号提出修改。
5. 如果有推荐默认值但不要求强制确认，要放到“推荐默认项”区块，不要混进关键确认题。
6. 如果存在没有默认值的开放问题，必须单独标成“必须回复项”；这类问题在用户明确答复前不能继续推进。
7. 回答用户时，优先引用 `rendered/*.md` 里的可读稿，不要把 YAML 结构直接摊给用户。
8. 你必须同时给出固定回复格式示例：
   - `按推荐继续`
   - `编号 init-01-02 改为 [b]`
   - `编号 init-01-02 改为 [自定义: xxx]`
   - `编号 init-01-04 回复：<明确答案>`

## 当前流程信息

- flow: `{{FLOW}}`
- first_step_id: `{{FIRST_STEP_ID}}`
- first_artifact: `{{FIRST_ARTIFACT}}`
- first_review: `{{FIRST_REVIEW}}`
- validate_command: `{{VALIDATE_COMMAND}}`
- render_command: `{{RENDER_COMMAND}}`

## Flow Command Cheat Sheet

{{FLOW_COMMANDS}}
