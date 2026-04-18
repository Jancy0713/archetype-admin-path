# 运行目录规范

这份文档定义 `init` 和 `prd` 流程在实际执行时的标准运行目录。

目标只有三个：

- 同一轮流程的所有文件放在一个地方
- 当前有效产物、历史返工产物、人工确认记录可以追踪
- 下一步 agent 能稳定拿到正确上下文

## 适用范围

这不是测试专用规范，而是正式运行规范。

测试流程和正式流程都使用同一套目录结构，只是运行名称不同。

## 推荐目录结构

```text
runs/
  2026-04-18-first-pass/
    raw/
      request.md
      attachments/
    init/
      init-01.project_profile.yaml
      init-01.review.yaml
      init-02.project_profile.yaml
      init-02.review.yaml
      init-03.project_profile.yaml
      init-03.review.yaml
      init-04.project_profile.yaml
      init-04.review.yaml
      init-05.baseline.yaml
    prd/
      prd-01.clarification.yaml
      prd-01.review.yaml
      prd-02.brief.yaml
      prd-03.decomposition.yaml
      prd-03.review.yaml
    rendered/
      init-01.project_profile.md
      prd-01.clarification.md
    progress/
      workflow-progress.md
      decisions.md
      handoff-notes.md
    prompts/
      run-agent-prompt.md
```

## 目录职责

### `raw/`

存放原始输入，不做结构化改写。

建议内容：

- `request.md`：本轮原始需求描述
- `attachments/`：原始 PRD、原型、截图、参考材料
- `README.md`：告诉使用者原始输入应该怎么放

规则：

- 原始输入只补充，不覆盖
- 不在这里放结构化 YAML
- 一句话需求优先写进 `raw/request.md`
- 完整 PRD、原型、截图放进 `raw/attachments/`

推荐格式：

- `md`
- `html`
- `txt`
- `png` / `jpg`

不太推荐直接作为主输入：

- `pdf`
- `doc` / `docx`
- `xlsx`
- `ppt` / `pptx`

建议：

- `Word` / `PDF` 优先转成 `md`
- 原件可以保留，但最好同时提供转写后的 `md`
- 表格类材料尽量改成 `md` 表格或文本摘要

### `init/`

存放初始化流程正式产物。

规则：

- 只放正式 YAML
- 文件名必须和 `meta.step_id` 对齐
- reviewer 产物与被审对象复用同一个 `step_id`

### `prd/`

存放 PRD 流程正式产物。

规则：

- 只放正式 YAML
- 下一步必须优先引用上一步正式 YAML，而不是聊天记录

### `rendered/`

存放给人阅读的 Markdown 渲染结果。

规则：

- Markdown 只是展示层，不是主数据源
- 不允许把渲染后的 Markdown 当成下一步唯一输入

### `progress/`

存放流程追踪文件。

建议至少保留：

- `workflow-progress.md`：主进度板
- `decisions.md`：人工确认结论
- `handoff-notes.md`：跨 agent 或跨轮次交接说明

### `prompts/`

存放这轮流程中准备直接喂给 AI 的提示词文件。

建议至少保留：

- `run-agent-prompt.md`：总控 agent 提示词

## 命名规则

运行目录建议使用：

```text
YYYY-MM-DD-主题短名
```

例如：

- `2026-04-18-first-pass`
- `2026-04-18-tenant-admin-test`
- `2026-04-19-jade-market-v1`

如果你要把 run 和仓库版本直接绑定，也可以使用更直接的命名：

- `init-1.0.0`
- `prd-1.0.1`

要求：

- 同一天允许多个目录
- 主题短名要能区分不同需求
- 不使用空格

## 正式产物规则

一份文件只有同时满足下面条件，才算“当前有效正式产物”：

1. 已经落在当前 run 目录内
2. 文件名符合步骤编号规则
3. YAML 内 `meta.step_id`、`meta.artifact_id` 已填写
4. 已通过脚本校验

如果是进入下一步前必须确认的关口，还需要：

5. reviewer 已完成
6. 人工确认已记录在 `progress/decisions.md` 或进度板中

## attempt 规则

同一步返工不新增 `step_id`。

例如：

- `prd-01` 第一次失败后返工，仍然是 `prd-01.clarification.yaml`
- 重试次数体现在 YAML 的 `status.attempt`
- 进度板只更新这一行，不新增新步骤

如果你确实需要保留中间失败稿，建议放在：

```text
runs/<run-id>/archive/
```

而不是占用正式入口文件名。

## 最小工作流

### Init

1. 把原始输入放进 `raw/`
2. 在 `init/` 初始化当前步骤 YAML
3. 让主模型填写 YAML
4. 跑脚本校验
5. 让 reviewer 产出同一步的 review YAML
6. 在 `progress/` 记录人工确认和当前状态
7. 再进入下一步

### PRD

1. 把原始输入放进 `raw/`
2. 在 `prd/` 初始化当前步骤 YAML
3. 让主模型填写 YAML
4. 跑脚本校验
5. reviewer 审查
6. 在 `progress/` 更新进度板
7. 进入下一步

## 进度板

标准模板在：

- [workflow-progress.template.md](/Users/wangwenjie/project/archetype-admin-path/docs/templates/workflow-progress.template.md)

总览说明在：

- [WORKFLOW_PROGRESS_BOARD.md](/Users/wangwenjie/project/archetype-admin-path/docs/WORKFLOW_PROGRESS_BOARD.md)

## 建议落地方式

当你开始一轮新流程时，先创建：

```text
runs/<run-id>/
  raw/
  init/
  prd/
  rendered/
  progress/
  prompts/
```

然后复制模板：

```text
docs/templates/workflow-progress.template.md
-> runs/<run-id>/progress/workflow-progress.md
```

这样这轮流程从第一步开始就是可追踪的。

## 推荐脚本

现在可以直接使用：

```bash
ruby scripts/create_run.rb
```

脚本会：

1. 询问你这轮跑 `init` 还是 `prd`
2. 询问本轮主题和 `run_id`
3. 创建完整目录结构
4. 复制标准进度板
5. 初始化第一份 YAML
6. 生成一条可直接喂给 AI 的总控提示词
