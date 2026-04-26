# Contract 工作流文档

这个目录现在只表达 `contract-new` 第一轮清理后的正式入口口径。

当前唯一正式主链是：

```text
init -> prd -> contract_handoff -> contract -> openapi/swagger -> develop
```

## 当前定位

`contract` 是 `contract_handoff` 之后的独立正式阶段。

它负责：

- 消费单个 contract flow 的 handoff 输入
- 把该 flow 收口成稳定实现协议
- 产出该 flow 对应的独立 `openapi/swagger`

它不再默认负责：

- `contract -> generation` 主链
- 把 `freeze/publish` 当正式终点
- 把 published contracts 当新版正式入口
- 把 generation bridge 当新版正式入口

## 与上游下游的关系

- 上游正式入口是 `prd` 完成后的 `contract_handoff`
- `contract_handoff` 必须显式表达 flow 拆分、顺序、依赖和当前推荐入口
- `contract` 的正式工作单位是单个 contract flow
- 单个 flow 的正式终点是独立 `openapi/swagger`
- `develop` 是消费该正式产物的下游阶段

当前最小 run 形态：

```text
runs/YYYY-MM-DD-contract-<flow-id>/
  intake/
  contract/
    working/
    release/
```

其中：

- `intake/` 持有 handoff snapshot
- `contract/working/` 持有过程态
- `contract/release/` 持有正式 release 包

## 当前阅读顺序

1. [docs/prd/WORKFLOW_GUIDE.md](/Users/wangwenjie/project/archetype-admin-path/docs/prd/WORKFLOW_GUIDE.md)
2. [docs/contract/WORKFLOW_GUIDE.md](/Users/wangwenjie/project/archetype-admin-path/docs/contract/WORKFLOW_GUIDE.md)
3. [docs/development_progress/contract-new/README.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/contract-new/README.md)

## Legacy 说明

- **物理清理已完成**：旧版 `freeze/publish`、`published contract`、`generation bridge` 相关入口脚本已物理删除。
- **产物隔离**：`runs/` 下带日期前缀的旧 contract 目录仅供历史参考，不再参与任何新版脚本测试与执行。
- **历史文档**：[docs/development_progress/contract/README.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/contract/README.md) 与 [docs/development_progress/generation/README.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/generation/README.md) 现在都只应按历史记录阅读。
