# PRD 2.0 结构化产物指南

## 目标

当前 PRD 流程只使用结构化 YAML 作为主产物。

原则：

1. AI 直接写 YAML
2. 脚本负责初始化、校验和渲染
3. Markdown 只作为人工阅读视图
4. reviewer 也使用固定结构

## 当前正式产物类型

1. `analysis`
2. `clarification`
3. `execution_plan`
4. `final_prd`
5. `review`

## 模板目录

- [analysis.template.yaml](/Users/wangwenjie/project/archetype-admin-path/docs/prd/templates/structured/analysis.template.yaml)
- [clarification.template.yaml](/Users/wangwenjie/project/archetype-admin-path/docs/prd/templates/structured/clarification.template.yaml)
- [execution_plan.template.yaml](/Users/wangwenjie/project/archetype-admin-path/docs/prd/templates/structured/execution_plan.template.yaml)
- [final_prd.template.yaml](/Users/wangwenjie/project/archetype-admin-path/docs/prd/templates/structured/final_prd.template.yaml)
- [review.template.yaml](/Users/wangwenjie/project/archetype-admin-path/docs/prd/templates/structured/review.template.yaml)

## 材料查询脚本

如果要快速定位某一步的正式材料，可以直接用：

```bash
ruby scripts/prd/materials.rb --artifact analysis
ruby scripts/prd/materials.rb --review-step prd_analysis
```

这个脚本会返回当前步骤对应的：

- step prompt
- rule
- template
- reviewer checklist / reviewer workflow

如果已经通过 `create_run` 新建 PRD run，优先看：

- `runs/<run-id>/prompts/materials/artifacts/*.yml`
- `runs/<run-id>/prompts/materials/reviews/*.yml`

这样可以固定住当前 run 的材料入口。

## reviewer 初始化包装脚本

可以直接用下面的包装脚本初始化 reviewer YAML 和 reviewer 材料快照：

```bash
ruby scripts/prd/init_review_context.rb --step prd_analysis --step-id prd-01 --subject runs/demo/prd/prd-01.analysis.yaml runs/demo/prd/prd-01.review.yaml
```

如果需要重建同一路径，可加 `--force`：

```bash
ruby scripts/prd/init_review_context.rb --force --step prd_analysis --step-id prd-01 --subject runs/demo/prd/prd-01.analysis.yaml runs/demo/prd/prd-01.review.yaml
```

它会同时生成：

- `review YAML`
- 同名 `.materials.yml` 快照

## 推荐工作方式

### 1. 初始化

```bash
ruby scripts/prd/init_artifact.rb --step-id prd-01 analysis runs/demo/prd-01.analysis.yaml
```

review 产物：

```bash
ruby scripts/prd/init_artifact.rb --step prd_analysis --step-id prd-01 review runs/demo/prd-01.review.yaml
```

### 2. 填写 YAML

主模型和 reviewer 都只在模板结构内填写，不扩顶层字段，不改字段名。

### 3. 校验

```bash
ruby scripts/prd/validate_artifact.rb analysis runs/demo/prd-01.analysis.yaml
```

### 4. 渲染

```bash
ruby scripts/prd/render_artifact.rb analysis runs/demo/prd-01.analysis.yaml runs/demo/prd-01.analysis.md
```

## 当前结构重点

### analysis

- 输入分析
- 范围拆分
- 模块 / 页面 / 资源 / 流程初步视图
- 风险与缺口
- 澄清候选项

### clarification

- `confirmation_items`
- `applied_defaults`
- `clarified_decisions`
- `human_confirmation`

补充约束：

- `confirmation_items.item_id` 使用稳定编号，例如 `prd-02-01`
- `required` 级确认项在确认完成后，应在 `clarified_decisions.item_id` 中留下对应收口结果

### execution_plan

- 工作流排序
- 依赖关系
- contract 优先级
- batching strategy
- 风险与观察点

### final_prd

- 范围
- 角色与权限
- 领域对象
- 页面与流程
- 约束
- blocking questions
- contract execution
- prd batches

## 当前校验重点

- `meta.source_paths` 必须真实存在
- `clarification` 必须引用 `analysis`
- `execution_plan` 必须引用 `clarification`
- `final_prd` 必须至少引用 `clarification` 和 `execution_plan`
- `review.meta.subject_path` 必须指向真实被审 YAML
- `confirmation_items.item_id` 必须与当前步骤编号一致

## 回归样例

当前提供了一组正式 happy-path 样例，可直接用于回归：

- [docs/prd/examples/2.0/README.md](/Users/wangwenjie/project/archetype-admin-path/docs/prd/examples/2.0/README.md)
