# Autonomous Run Guide

这份文档定义 `init` 和 `prd` 流程的推荐运行模式：

- 用户只负责启动一轮 run
- AI 在同一个对话里自主推进流程
- 只有到达必须人工确认的关口时才停下来

## 总原则

流程产物不能省，但用户操作可以减少。

也就是：

- YAML 产物不能省
- 脚本校验不能省
- reviewer 审查不能省
- render 不能省
- 进度板更新不能省
- 用户逐步手工推动可以省

## 职责划分

### 用户负责

- 创建 run
- 把原始需求放进 `raw/`
- 在 Human Confirmation Gate 做确认
- 对 blocker 或升级问题做最终判断

### AI 负责

- 读取当前 run 目录
- 判断当前应该推进哪个 step
- 生成或更新 YAML
- 运行 `validate`
- 校验失败时自修
- 生成 reviewer YAML
- 调用独立 reviewer 子 agent 或独立新上下文完成 reviewer 审查
- 根据 reviewer 结果返工
- 渲染 Markdown
- 更新 `progress/workflow-progress.md`
- 直到需要人工确认时再停

## 停点规则

AI 不是每一步都要停，只在下面情况停：

1. 到达 Human Confirmation Gate
2. 超过 retry 上限仍无法通过
3. 原始输入严重缺失，无法继续推进
4. 需要用户对关键决策做明确选择

除此之外，AI 应默认继续向前推进。

## Human Confirmation Gate 输出格式

停在人工确认点时，AI 不应机械重复 Markdown 全文，而应根据阶段类型给出适合决策的确认方式。

### `init-01` 到 `init-04`

这四步仍按问卷式确认输出。

推荐格式：

```md
完整待确认内容见 `rendered/init-01.project_profile.md`，请先通读。

问题1：本轮初始化范围【可多选】
编号：init-01-01
a. 商家端后台
b. 运营后台
c. 平台管理后台
推荐：a
说明：当前需求与原型都只覆盖商家侧流程。
```

要求：

- 先提示用户完整待确认内容在哪个 Markdown 文件
- 每个问题都必须有明确编号，建议使用 `init-01-01`、`init-02-01` 这种稳定格式
- 每个问题都必须有明确选项
- 选项通常控制在 2-5 个，不要为了形式硬凑 3 个
- 如果情况过多，应拆成多个问题，而不是把一个问题塞进太多选项
- 必须标出推荐项
- 推荐理由要短，聚焦为什么当前阶段这样收敛
- 即使有选项，也应允许用户回复自定义答案
- 只列真正还不确定、且会影响下一步推进的问题
- 如果材料已经足够明确，不应为了走流程而重复提问
- 次要确认项可以展示“当前按推荐收敛、但用户如有异议仍可改”的内容，但不能和重点确认项重复表达同一个问题
- 如果存在没有默认值的开放问题，必须单独标为“必须回复项”
- 没有额外关键确认项时，应明确告诉用户只需通读 Markdown，并回复 `按推荐继续` 或按编号提出修改
- 输出里应引用本轮渲染好的 Markdown，而不是把 YAML 原样展开给用户

### `init-05 baseline`

这一步不再重复 01-04 的问卷格式。

要求：

- 明确提示用户先通读 `rendered/init-05.baseline.md`
- 对话里只说明“请确认 baseline 是否可以作为后续默认输入”
- 如果没有额外争议点，不要再拆“必须回复项 / 重点确认项 / 次要确认项”
- 默认回复方式应简化为：
  - `baseline 确认，继续`
  - 或直接指出“把 xxx 改成 yyy”

### `init-07 bootstrap_plan`

这一步应把 `design_seed` 和 `bootstrap_plan` 一起给用户看，但只在 `bootstrap_plan` 关口停一次。

要求：

- 明确提示用户先通读 `rendered/init-06.design_seed.md`
- 明确提示用户通读 `rendered/init-07.bootstrap_plan.md`
- 在进入人工确认前，还应先生成并提示用户通读：
  - `rendered/init-07.project-conventions.md`
  - `rendered/init-07.prd-bootstrap-context.md`
  - `rendered/init-07.init-execution-scope.md`
- `rendered/init-07.bootstrap_plan.md` 应保持为索引页，并直接包含“执行参数确认”段落，写出项目名称候选、目录 slug 候选与默认初始化位置
- 对话里重点说明：请确认这份 bootstrap plan 是否足够具体、是否能直接指导初始化基座实现
- 这一步必须额外询问一个固定问题：项目名称是什么
- 项目名称必须提供 3 个候选，并默认推荐 `a`
- 若用户未对项目名称提出异议，则默认采用 `a`
- 这一步还必须额外询问：本地目录名称是什么；目录名称不等于项目名称，默认应给出英文/slug 候选
- 同时固定告知 `init-08` 默认执行参数：
  - 初始化位置：当前工作区根目录下创建目录 `<目录名称>`，且该目录本身就是项目根目录
  - git 处理：默认删除现有 `.git`
  - 可选修改：
    - `项目名称改为 [b]`
    - `项目名称改为 [自定义: xxx]`
    - `目录名称改为 [b]`
    - `目录名称改为 [自定义: xxx]`
    - `初始化目录改为 /abs/path`
    - `保留 git`
    - `保留 git，remote-url 改为 https://...`
- 不要再套用 01-04 的编号问答格式，除非当前真的有尚未收敛的明确选项题
- 默认回复方式应简化为：
  - `bootstrap_plan 确认，继续`
  - 或直接指出“把 xxx 改成 yyy”

### `init-08 execution`

`init-08` 不再是 `change_request`。

它的职责是：

- 按 `Init Execution Scope` 初始化项目
- 先基于用户在 `init-07` 已确认的项目名称、目录名称和初始化位置，生成 run 内专用 `prompts/init-08-execution-prompt.md`
- 由新的执行代理或新上下文完成工程初始化命令和 AI 补强，不要继续复用已经堆叠 `init-01` 到 `init-07` 的长上下文
- 初始化完成后，先交给独立 reviewer 子 agent / 新上下文审查；reviewer 通过后，再执行 `post_init_to_prd.rb`
- 自动创建新的 `prd` run
- 自动把拆分后的干净 PRD 输入注入新的 PRD run，包括：
  - `raw/attachments/confirmed-foundation.md`
  - `raw/attachments/base-modules-prd.md`
- 自动预填新的 `raw/request.md`
- 自动生成明确引用规则文档的 PRD 启动提示词
- 这一步只负责拆分并注入已清洗的 `prd-bootstrap-context`，不在 `init-08` 再承担二次去味或兼容旧脏内容

## Init 停点

`init` 默认在下面关口停：

1. `init-01` reviewer 通过后，等待人工确认 `foundation_context`
2. `init-02` reviewer 通过后，等待人工确认 `tenant_governance`
3. `init-03` reviewer 通过后，等待人工确认 `identity_access`
4. `init-04` reviewer 通过后，等待人工确认 `experience_platform`
5. `init-05 baseline` 生成并通过校验后，等待人工确认基线定稿
6. `init-06 design_seed` 生成后，先经脚本校验与 reviewer 审查，不单独停给人；通过后在 `init-07` 前渲染 Markdown，供用户和 `bootstrap_plan` 一起通读
7. `init-07 bootstrap_plan` 生成后，先经脚本校验与 reviewer 审查；通过后连同 `rendered/init-07.project-conventions.md`、`rendered/init-07.prd-bootstrap-context.md`、`rendered/init-07.init-execution-scope.md` 一起等待人工确认初始化底座计划
8. `init-08 execution` 在用户确认后应先生成新的执行 prompt，再由新的执行代理执行初始化，并自动启动新的 PRD run

也就是说，`init` 是“阶段内自动跑通，阶段末停给人确认”。

## PRD 停点

`prd` 默认策略更激进：

- `prd-01 analysis`、`prd-02 clarification`、`prd-03 execution_plan` 之间允许 AI 连续推进
- `prd-02 clarification` 默认要停在 Human Confirmation Gate
- `prd-04 final_prd` reviewer 通过后，才允许进入 contract
- 如果 reviewer 发现阻塞问题、关键业务事实缺失或必须用户明确决策，才停给用户
- 如果没有阻塞问题，AI 可以直接推进到最近的人工作业点或 `prd-04.review` 结束

## reviewer 规则

reviewer 在 autonomous run 中也必须保留，但它属于 AI 内部流程，不默认暴露给用户操作。

要求：

- reviewer 产物仍然落盘
- reviewer 仍然使用结构化 YAML
- reviewer 的判断仍然决定是否返工
- 用户不需要手动触发 reviewer
- reviewer 必须由独立 reviewer 子 agent 或独立新上下文完成，主 agent 不得自己兼任 reviewer
- 主 agent 只能准备 reviewer 输入、调用 reviewer 子 agent、读取 reviewer 结果并据此返工
- 主 agent 不得在同一个上下文里自写主产物再自写 reviewer 结论，这类自审视为无效 reviewer

## 进度板规则

AI 每推进一个显著状态变化，都要更新：

- `progress/workflow-progress.md`

至少包括：

- 当前 step 是否进入 `doing`
- 是否已 `validating`
- 是否进入 `review`
- 是否 `blocked`
- 是否 `confirmed` 或 `done`
- 当前下一步是什么

## 失败处理

### 脚本校验失败

- 不进入 reviewer
- AI 直接修正同一步 YAML
- `status.attempt` 递增
- 更新进度板

### reviewer 不通过

- AI 直接返工同一步主产物
- 再次脚本校验
- 重新 reviewer
- 达到 retry 上限后才升级给用户

## 目录约束

运行目录规范见：

- [RUNS_WORKSPACE_GUIDE.md](/Users/wangwenjie/project/archetype-admin-path/docs/RUNS_WORKSPACE_GUIDE.md)

进度板模板见：

- [workflow-progress.template.md](/Users/wangwenjie/project/archetype-admin-path/docs/templates/workflow-progress.template.md)

## 建议运行方式

1. 先执行：

```bash
ruby scripts/create_run.rb
```

2. 把原始输入放进：

- `raw/request.md`
- `raw/attachments/`

3. 把生成出来的总控提示词交给 AI

4. AI 自动推进，直到停在人工确认点
