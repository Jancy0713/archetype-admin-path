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
- 完成 reviewer 审查
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

停在人工确认点时，AI 不应只给一段自然语言总结，而应给出可直接决策的确认清单。

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
- 推荐默认项应单独成段，不和必须确认的问题混排
- 如果存在没有默认值的开放问题，必须单独标为“必须回复项”
- 没有额外关键确认项时，应明确告诉用户只需通读 Markdown，并回复 `按推荐继续` 或按编号提出修改
- 输出里应引用本轮渲染好的 Markdown，而不是把 YAML 原样展开给用户

## Init 停点

`init` 默认在下面关口停：

1. `init-01` reviewer 通过后，等待人工确认 `foundation_context`
2. `init-02` reviewer 通过后，等待人工确认 `tenant_governance`
3. `init-03` reviewer 通过后，等待人工确认 `identity_access`
4. `init-04` reviewer 通过后，等待人工确认 `experience_platform`
5. `init-05 baseline` 生成并通过校验后，等待人工确认基线定稿

也就是说，`init` 是“阶段内自动跑通，阶段末停给人确认”。

## PRD 停点

`prd` 默认策略更激进：

- `prd-01`、`prd-02`、`prd-03` 之间允许 AI 连续推进
- 如果 reviewer 发现阻塞问题、关键业务事实缺失或必须用户明确决策，才停给用户
- 如果没有阻塞问题，AI 可以直接推进到 `prd-03.review` 结束

## reviewer 规则

reviewer 在 autonomous run 中也必须保留，但它属于 AI 内部流程，不默认暴露给用户操作。

要求：

- reviewer 产物仍然落盘
- reviewer 仍然使用结构化 YAML
- reviewer 的判断仍然决定是否返工
- 用户不需要手动触发 reviewer

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
