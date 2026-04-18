# PRD 结构化产物指南

## 目标

这份文档定义 PRD 阶段的结构化产物格式。

当前目标不是让 AI 自由写 markdown，而是尽可能让它在一个预设框内填内容，再通过脚本：

1. 生成空白骨架
2. 校验必填字段
3. 渲染成人更容易阅读的 markdown

## 当前原则

1. 机器主格式使用 `YAML`
2. 人类阅读格式使用 `Markdown`
3. AI 优先填写 YAML，不直接手写长篇 markdown
4. reviewer 和人工审核也尽量使用固定结构
5. 能用脚本检查的内容，不交给模型自由发挥

## 当前产物类型

当前先覆盖 4 类：

1. `clarification`
2. `review`
3. `brief`
4. `decomposition`

## 文件结构

模板放在：

- [templates/structured](/Users/wangwenjie/project/archetype-admin-path/docs/prd/templates/structured)

脚本放在：

- [scripts/prd](/Users/wangwenjie/project/archetype-admin-path/scripts/prd)

## 推荐工作方式

### 1. 初始化产物

使用脚本生成空白 yaml：

```bash
ruby scripts/prd/init_artifact.rb clarification path/to/clarification.yaml
```

如果你想把测试过程做成显式步骤流，建议直接补上 `step_id`：

```bash
ruby scripts/prd/init_artifact.rb --step-id prd-01 clarification runs/demo/prd-01.clarification.yaml
```

如果是 reviewer 产物，建议显式带上当前关口：

```bash
ruby scripts/prd/init_artifact.rb --step requirement_clarification review path/to/review.yaml
```

配合步骤编号时建议写成：

```bash
ruby scripts/prd/init_artifact.rb --step requirement_clarification --step-id prd-01 review runs/demo/prd-01.review.yaml
```

### 2. 让 AI 填写 yaml

让主模型或 reviewer 在既有 yaml 结构里填写字段，而不是自由改格式。

注意：

- `brief` 和 `decomposition` 里的核心列表字段现在是对象数组，不是纯字符串数组
- `clarification` 和 `brief` 现在增加了两类新字段：
  - `decision_candidates`：需要用户明确选择的结构化问题
  - `proposed_defaults`：用户不明确反对时可沿用的推荐默认值
- 建议同时维护 `meta.flow_id`、`meta.step_id`、`meta.artifact_id`
- reviewer 当前只允许审查 `requirement_clarification` 和 `prd_decomposition` 两个关口
- 初始化后的模板可能仍无法直接通过校验，必须把占位对象补全或删掉
- `validate_artifact.rb` 现在会检查跨文件引用，例如 `source_paths` 是否存在、`decomposition` 是否真实引用了 `brief`、`review` 是否真实指向当前关口对应的产物

推荐配套阅读：

- [STEP_NAMING_GUIDE.md](/Users/wangwenjie/project/archetype-admin-path/docs/prd/STEP_NAMING_GUIDE.md)
- [WORKFLOW_PROGRESS_BOARD.md](/Users/wangwenjie/project/archetype-admin-path/docs/WORKFLOW_PROGRESS_BOARD.md)

### 3. 校验 yaml

```bash
ruby scripts/prd/validate_artifact.rb clarification path/to/clarification.yaml
```

如果校验失败，优先检查：

- 当前 YAML 是否补全了必填字段
- `meta.source_paths` 或 `meta.subject_path` 指向的文件是否真实存在
- 当前产物是否引用了正确的上一阶段产物类型
- reviewer 的 `status.step` 是否和被审产物的真实步骤一致
- `decision_candidates.recommended` 和 `default_if_no_answer` 是否落在 `options.value` 里

### 4. 渲染为 markdown 供人工审核

```bash
ruby scripts/prd/render_artifact.rb clarification path/to/clarification.yaml path/to/clarification.md
```

## 为什么这样做

如果只靠 prompt 约束格式，随着流程变长，模型依从性会下降。

引入结构化产物后：

- AI 主要是在填表
- reviewer 主要是在挑错
- 脚本负责格式控制
- 人只审内容，不反复审格式

## 当前限制

这仍然是第一版，暂时没有做到：

- 更细粒度的对象级业务规则
- 自动状态机流转与步骤推进
- 更完整的跨阶段自动编排

但已经可以先把“格式漂移”和“错误放行”压下来。
