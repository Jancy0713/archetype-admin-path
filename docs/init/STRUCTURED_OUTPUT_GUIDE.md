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
- `key_decisions` 与 `open_questions.p0` 的候选项应尽量控制在 2-5 个；如果情况太多，应拆成多个问题
- 候选项不需要硬凑 3 个，2 个足够时直接给 2 个
- 即使给了候选项，也应允许用户补充自定义答案
- `baseline` 的核心字段应通过 `field_sources` 记录来源，便于后续做基线变更追踪
- 建议同时维护 `meta.flow_id`、`meta.step_id`、`meta.artifact_id`
- 优先使用判断题、单选题、多选题，少用开放题
- 每个阶段都需要单独的 `confirmation` 记录人工确认结果
- 未进入的阶段只保留固定题骨架和必要空白位，不做大而全题库
- 专业术语首次出现时应附短解释

推荐配套阅读：

- [STEP_NAMING_GUIDE.md](/Users/wangwenjie/project/archetype-admin-path/docs/init/STEP_NAMING_GUIDE.md)
- [WORKFLOW_PROGRESS_BOARD.md](/Users/wangwenjie/project/archetype-admin-path/docs/WORKFLOW_PROGRESS_BOARD.md)

结构示例：

```yaml
key_decisions:
  - topic: 首期终端
    question: 一期主交付终端是什么？
    explanation: 这会影响后续导航、上传和导出能力设计。
    recommended: pc_web
    options:
      - value: pc_web
        label: PC Web
        description: 以桌面后台为主。
      - value: pc_web_and_mobile
        label: PC Web + Mobile
        description: 同步考虑移动端入口。
    allow_multiple: false
    allow_custom_answer: true
    default_if_no_answer: pc_web
    must_confirm: true

open_questions:
  p0:
    - topic: 地区范围
      question: 首期是否只覆盖中国大陆？
      explanation: 该项没有安全默认值，未明确前不能进入下一阶段。
      recommended: mainland_only
      options:
        - value: mainland_only
          label: 仅中国大陆
          description: 暂不覆盖跨境与多地区合规。
        - value: mainland_then_global
          label: 中国大陆优先，预留扩展
          description: 首期国内，后续再扩地区。
      allow_multiple: false
      allow_custom_answer: true
      must_answer: true
  p1: []
  p2: []
```

### 3. 校验 YAML

```bash
ruby scripts/init/validate_artifact.rb project_profile path/to/project_profile.yaml
```

### 4. 渲染为 Markdown

```bash
ruby scripts/init/render_artifact.rb project_profile path/to/project_profile.yaml path/to/project_profile.md
```

`project_profile.md` 的定位不是 YAML 备份，也不是简单格式化输出，而是给人工确认环节直接阅读的视图层。

当前对 `project_profile` 的渲染目标应是：

- 先给项目概览，快速说明这次初始化在做什么
- 聚焦当前阶段，只展开本阶段结论与待确认问题
- 把 `key_decisions` 渲染成“问题 + 选项 + 推荐项 + 说明”
- 给待确认项生成稳定编号，便于用户按编号回复修改
- 把 `recommended_defaults` 渲染成可直接沿用的默认建议
- 如果有无默认值的开放问题，要单独渲染成“必须回复项”，并保留候选项与自定义补充入口
- 对后续阶段只给预览，不提前把完整结构铺开

可以把它理解成：

- YAML 是结构化数据源
- Markdown 是面向人工确认的展示层

也就是更接近“把 JSON 渲染成前端表单/确认卡片”，而不是“把 JSON 漂亮打印一遍”

## 当前限制

这仍然是第一版，暂时没有做到：

- 常见初始化题库自动推荐
- 更细粒度的行业化初始化规则
- 初始化变更和普通 PRD 的自动联动
