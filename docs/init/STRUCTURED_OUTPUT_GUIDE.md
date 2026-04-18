# 初始化结构化产物指南

## 目标

这份文档定义项目初始化阶段的结构化产物格式。

当前目标是让 AI 在固定 YAML 框架内填内容，再通过脚本：

1. 生成空白骨架
2. 校验结构和状态
3. 渲染成人类更容易读的 Markdown

## 当前产物类型

当前先覆盖 4 类：

1. `project_profile`
2. `review`
3. `baseline`
4. `change_request`

## 推荐工作方式

### 1. 初始化产物

```bash
ruby scripts/init/init_artifact.rb project_profile path/to/project_profile.yaml
```

如果你想让测试过程更容易追踪，建议初始化时直接补上步骤编号：

```bash
ruby scripts/init/init_artifact.rb --step-id init-01 project_profile runs/demo/init-01.project_profile.yaml
```

reviewer 产物建议显式带上当前关口：

```bash
ruby scripts/init/init_artifact.rb --step project_initialization review path/to/review.yaml
```

配合步骤编号时建议写成：

```bash
ruby scripts/init/init_artifact.rb --step project_initialization --step-id init-01 review runs/demo/init-01.review.yaml
```

### 2. 让 AI 填写 YAML

注意：

- 初始化流程优先处理系统基线，不处理普通页面细节
- `project_profile` 必须按阶段推进，同一个 YAML 会被多轮更新
- 每个阶段有一组固定 `required_questions`，不能缺漏
- 固定题默认应尽量带 `recommended`、`options`、`reason`
- `adaptive_questions` 默认为空，只有确有必要时才补 1-2 题
- 当前阶段的 `key_decisions` 用于需要用户明确选择的关键基线问题
- 当前阶段的 `recommended_defaults` 用于用户未明确反对时可沿用的推荐默认值
- `baseline` 的核心字段应通过 `field_sources` 记录来源，便于后续做基线变更追踪
- 建议同时维护 `meta.flow_id`、`meta.step_id`、`meta.artifact_id`
- 优先使用判断题、单选题、多选题，少用开放题
- 每个阶段都需要单独的 `confirmation` 记录人工确认结果
- 未进入的阶段只保留固定题骨架和必要空白位，不做大而全题库
- 专业术语首次出现时应附短解释

推荐配套阅读：

- [STEP_NAMING_GUIDE.md](/Users/wangwenjie/project/archetype-admin-path/docs/init/STEP_NAMING_GUIDE.md)
- [WORKFLOW_PROGRESS_BOARD.md](/Users/wangwenjie/project/archetype-admin-path/docs/WORKFLOW_PROGRESS_BOARD.md)

### 3. 校验 YAML

```bash
ruby scripts/init/validate_artifact.rb project_profile path/to/project_profile.yaml
```

### 4. 渲染为 Markdown

```bash
ruby scripts/init/render_artifact.rb project_profile path/to/project_profile.yaml path/to/project_profile.md
```

## 当前限制

这仍然是第一版，暂时没有做到：

- 常见初始化题库自动推荐
- 更细粒度的行业化初始化规则
- 初始化变更和普通 PRD 的自动联动
