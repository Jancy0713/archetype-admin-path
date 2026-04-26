# Contract 流程指南

这份文档只保留当前正式入口定义。

当前唯一正式主链是：

```text
init -> prd -> contract_handoff -> contract -> openapi/swagger -> develop
```

## 正式边界

`contract` 是 `contract_handoff` 之后的独立正式阶段。

输入：

- 单个 contract flow 的 handoff
- 该 flow 的范围、依赖、约束和禁止假设项

责任：

- 把单个 flow 收口成稳定实现协议
- 明确接口、字段、约束和依赖

输出：

- 该 flow 对应的独立 `openapi/swagger`

## `contract_handoff` 的职责

`contract_handoff` 是显式主链步骤，不是附带说明。

它必须负责：

- 把 `final_prd` 拆成多个 contract flows
- 给出 flow 顺序和依赖关系
- 明确当前推荐入口 flow
- 为后续 `contract` 执行提供正式交接输入

当前最小正式落盘结构至少应包含：

```text
runs/<prd-run-id>/
  contract_handoff/
    contract-handoff.index.yaml
    contract-handoff.md
    flows/
      01.<flow-id>.handoff.yaml
      01.<flow-id>.handoff.md
```

后续 `contract` 默认消费单个 flow handoff，不直接把整份 `final_prd` 当作单一启动输入。

## 单 Flow Run 目录

当前 `contract` 的正式执行单位是单个 flow 独立 run：

```text
runs/YYYY-MM-DD-contract-<flow-id>/
  raw/
    request.md (标记本批次来源)
    attachments/ (存放上游 PRD/Handoff 相关快照)
  prompts/
    run-agent-prompt.md (人类启动本批次的正式入口)
  progress/
    workflow-progress.md (统一进度板)
  intake/
    contract-handoff.snapshot.yaml
    contract-handoff.snapshot.md
  contract/
    working/
      ...
    release/
      openapi.yaml
      openapi.summary.md
      develop-handoff.md
  rendered/
  archive/
```

目录边界固定如下：

- `intake/` 只存 handoff 快照
- `contract/working/` 只存过程态，不作为下游正式输入
- `contract/release/` 只存当前 flow 的正式交付

## 不再作为正式入口的内容

下面这些内容如果仍暂时存在，只能按 legacy 理解：

- 旧 `contract -> generation` 叙事
- 把 `freeze/publish` 当正式终点
- 把 published contracts 当新版正式入口
- 把 generation bridge 当新版默认下一步

它们不能继续出现在正式 README 或 workflow guide 的默认推荐里。

## Develop 输入边界

`develop` 阶段负责承接 contract 进行最终的实现和代码生成。
- **正式输入路径已被严格锁定为：** `runs/YYYY-MM-DD-contract-<flow-id>/contract/release/`
- `develop` 严禁直接读取 `contract/working/` 下的过程态草稿，以防止过程信息泄露到下游。
- 必须只能基于 `release/` 暴露的正式包 (`openapi.yaml`, `openapi.summary.md`, `develop-handoff.md`) 进行实现验证。

## 需求变更与回改决策矩阵 (Re-entry Matrix)

当需求或协议发生变更时，不再盲目回到起点，而是按照以下层级决定回切入口：

| 变更类型 | 影响范围 | 回切入口 | 必须重走阶段 |
| :--- | :--- | :--- | :--- |
| **全局需求变更** | 业务目标、模块边界、跨 flow 逻辑 | `prd/` (final_prd) | 全部 (Handoff -> Contract -> Develop) |
| **Flow 逻辑变更** | 拆分策略、Flow 依赖顺序 | `contract_handoff/` | 该 flow 及其受影响下游的所有 contract/develop |
| **局部协议变更** | 单个 Flow 内的字段、接口形态调整 (未开始实现) | `contract-<flow-id>/` | 该 flow 的 contract 收口与 develop |
| **实现后基线变更**| 已在 baseline 沉淀且涉及多版本共存或稳态修改 | `baselines/` | 基于 baseline 的增量修改流 |

## 稳定基线沉淀 (Baselines)

- 实现前：`contract/release/` 负责把协议交给 `develop`。
- 实现验证后：使用 `settle_baseline.rb` 脚本，将 `release/` 内部的内容正式沉淀至 `baselines/<flow-id>/current/`。这将作为本 flow 被实现验证过的真相源 (Source of Truth)。

## 当前阅读顺序

1. [docs/prd/WORKFLOW_GUIDE.md](/Users/wangwenjie/project/archetype-admin-path/docs/prd/WORKFLOW_GUIDE.md)
2. [docs/development_progress/contract-new/CONTRACT_NEW_FULL_DIRECTION.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/contract-new/CONTRACT_NEW_FULL_DIRECTION.md)
3. [docs/development_progress/contract-new/01_ENTRY_CLEANUP_AND_ALIGNMENT_WORKPLAN.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/contract-new/01_ENTRY_CLEANUP_AND_ALIGNMENT_WORKPLAN.md)

## Legacy 说明

- **物理清理已完成**：旧版 `freeze/publish`、`published contract`、`generation bridge` 相关入口脚本已物理删除。
- **产物隔离**：`runs/` 下带日期前缀的旧 contract 目录仅供历史参考，不再参与任何新版脚本测试与执行。
- **历史记录**：所有关于旧版主链的推进记录见 [docs/development_progress/contract/README.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/contract/README.md) 和 [docs/development_progress/generation/README.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/generation/README.md)。
