# Contract 步骤与命名指南

> Legacy note: 本文中残留的 `freeze` 命名说明属于旧术语；当前正式交付统一收口到 `contract/release/`。

## 目标

这份文档用于统一 `contract` 流程中的：

- 步骤编号
- artifact 名称
- review / freeze 命名
- run 内文件命名
- batch 启动交付文件命名

当前阶段先统一命名约定，不展开脚本实现细节。

## 步骤编号约定

当前建议的正式步骤编号为：

1. `contract-01` -> `scope_intake`
2. `contract-02` -> `domain_mapping`
3. `contract-03` -> `contract_spec`
4. `contract-04` -> `review`

说明：

- `contract-01` 到 `contract-04` 是流程顺序编号
- `scope_intake` / `domain_mapping` / `contract_spec` / `review` 是步骤语义名
- 对外说明时可以同时写编号和名称

例如：

- `contract-01 scope_intake`
- `contract-03 contract_spec`

## Artifact 名称约定

建议当前正式 artifact 名称保持如下：

- `scope_intake`
- `domain_mapping`
- `contract_spec`
- `review`
- `freeze`

说明：

- `freeze` 不是独立 step_id，对应的是 `review` 通过后的冻结动作产物

## Run 内文件命名约定

假设当前 run 为：

```text
runs/<run-id>/
```

假设当前 batch 为：

```text
batch-foundation-access
```

建议 run 内 contract 文件按下面方式命名：

```text
runs/YYYY-MM-DD-contract-<flow-id>/
  raw/
    request.md
    attachments/
  prompts/
    run-agent-prompt.md
  progress/
    workflow-progress.md
  intake/
    contract-handoff.snapshot.yaml
    contract-handoff.snapshot.md
  contract/
    working/
      contract-01.scope_intake.yaml
      contract-02.domain_mapping.yaml
      contract-03.contract_spec.yaml
      contract-04.review.yaml
    release/
      openapi.yaml
      openapi.summary.md
      develop-handoff.md
  rendered/
    contract-01.scope_intake.md
    contract-02.domain_mapping.md
    contract-03.contract_spec.md
    contract-04.review.md
```

这样设计的目的：

- 每个 batch 一个独立目录
- 每一步文件名前缀与步骤编号一一对应
- 只看文件名就能知道顺序和 artifact 类型

## 为什么推荐“每个 batch 一个目录”

不推荐把所有 batch 的文件都直接平铺到：

```text
runs/<run-id>/contract/
```

原因：

- 多 batch 时会迅速混乱
- review / freeze / rendered 文件很容易串批次
- 不利于独立重跑某一个 batch

因此建议采用：

```text
runs/<run-id>/contract/<batch-id>/
```

作为最小隔离单位。

## Contract Handoff 文件命名约定

在 `final_prd` 完成后，系统内部会先为每个 ready flow 生成正式 `contract_handoff` 文件。

建议命名为：

```text
runs/<run-id>/contract_handoff/flows/
  <order>.<flow-id>.handoff.yaml
  <order>.<flow-id>.handoff.md
```

例如：

```text
runs/2026-04-21-ai-init-prd/contract_handoff/flows/
  01.batch-foundation-access.handoff.yaml
  01.batch-foundation-access.handoff.md
  02.batch-account-access.handoff.yaml
  02.batch-account-access.handoff.md
  03.batch-capability-components.handoff.yaml
  03.batch-capability-components.handoff.md
```

这样设计的目的：

- 文件名里同时保留顺序和 flow 标识
- 结构化 handoff 与可读 handoff 并列存在，不需要二选一
- 后续脚本排序更稳定

## Contract Handoff 总览文件命名约定

建议在 run 内保留一份用户侧交付说明：

```text
runs/<run-id>/contract_handoff/contract-handoff.md
```

这份文件用于说明：

- 本次一共拆成几个 flows
- 当前推荐入口 flow 是什么
- 后续 flows 的依赖关系是什么
- 如果需要改需求，应回到哪里

聊天框不需要完整展开它，但可以在需要时引用它。

## Contract Handoff 索引文件命名约定

建议保留一个系统可读索引文件：

```text
runs/<run-id>/contract_handoff/contract-handoff.index.yaml
```

建议它至少承担：

- 记录 flows 列表
- 记录推荐顺序
- 记录每个 flow 的依赖
- 记录每个 flow 的 handoff 文件路径
- 记录当前推荐入口 flow

## 正式交付命名约定

旧版这里曾把 `freeze` 后的 `contracts/` 归档目录当成正式终点。

当前新版不再沿用这套目录语义。当前应统一理解为：

- run 内目录可以存过程态
- 单个 flow 的正式交付，应进入该 flow 自己的 release 层
- 正式终点应收口到独立 `openapi/swagger` 交付，而不是根目录 `contracts/`

如果后续需要补正式交付命名规则，应直接围绕新版 `contract_handoff -> contract -> openapi/swagger -> develop` 主链补充，不再回到旧 `contracts/` 结构。

## Rendered 文件命名约定

rendered 文件建议直接沿用主 YAML 名称，只改扩展名：

- `contract-01.scope_intake.yaml` -> `contract-01.scope_intake.md`
- `contract-03.contract_spec.yaml` -> `contract-03.contract_spec.md`

这样最直观，且容易建立脚本对应关系。

## Review Step 命名约定

当前建议 review 相关语义区分为两层：

### 步骤层

- `contract-04 review`

### artifact 层

- `review`
- `freeze`

不要混用成：

- `contract-04.review_and_freeze.yaml`

因为这会把 reviewer 判断和冻结声明混在一起。

## 命名时应避免的做法

### 1. 避免语义不稳定的简称

例如：

- `intake.yaml`
- `mapping.yaml`
- `spec.yaml`

这种命名太短，后续跨目录时容易混淆。

更推荐：

- `contract-01.scope_intake.yaml`
- `contract-02.domain_mapping.yaml`
- `contract-03.contract_spec.yaml`

### 2. 避免把 batch 信息藏起来

如果是多 batch run，不应只写：

```text
runs/<run-id>/contract/contract-03.contract_spec.yaml
```

而应明确挂到 batch 目录下。

### 3. 避免 review / freeze 混成一个文件

review 是判断，freeze 是声明。

命名上也应保持拆开。

## 当前建议的最小命名骨架

当前建议最小骨架如下：

```text
docs/contract/
  README.md
  WORKFLOW_GUIDE.md
  STRUCTURED_OUTPUT_GUIDE.md
  STEP_NAMING_GUIDE.md
  handoffs/
  steps/
  reviewer/

runs/<prd-run-id>/contract_handoff/
  contract-handoff.index.yaml
  contract-handoff.md
  flows/
    01.<flow-id>.handoff.yaml
    01.<flow-id>.handoff.md

runs/YYYY-MM-DD-contract-<flow-id>/
  prompts/
    run-agent-prompt.md
  intake/
    contract-handoff.snapshot.yaml
  contract/
    working/
      ...
    release/
      ...
```

## 后续文档关系

建议结合阅读：

1. [Contract README](/Users/wangwenjie/project/archetype-admin-path/docs/contract/README.md)
2. [Contract Workflow Guide](/Users/wangwenjie/project/archetype-admin-path/docs/contract/WORKFLOW_GUIDE.md)
3. [Contract Structured Output Guide](/Users/wangwenjie/project/archetype-admin-path/docs/contract/STRUCTURED_OUTPUT_GUIDE.md)
4. [Contract 步骤说明](/Users/wangwenjie/project/archetype-admin-path/docs/contract/steps/README.md)
5. [Contract Reviewer 文档](/Users/wangwenjie/project/archetype-admin-path/docs/contract/reviewer/README.md)
