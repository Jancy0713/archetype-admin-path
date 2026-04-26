# Generation Development Progress

这个目录现在只作为历史记录保留。

它记录的是旧 `generation` 方向、旧 bridge 定义和旧 run 方案的推进材料，不再是当前正式入口。

## 当前角色

- 这是 legacy / historical 目录
- 不能继续作为新版主链的正式推荐入口
- 不能继续把 `contract -> generation`、bridge 或 published contract 消费路径定义成当前默认下一步

当前正式主链请统一看：

```text
init -> prd -> contract_handoff -> contract -> openapi/swagger -> develop
```

如果当前目标是执行新版主链，请改看：

- [docs/development_progress/contract-new/README.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/contract-new/README.md)
- [docs/prd/WORKFLOW_GUIDE.md](/Users/wangwenjie/project/archetype-admin-path/docs/prd/WORKFLOW_GUIDE.md)
- [docs/contract/WORKFLOW_GUIDE.md](/Users/wangwenjie/project/archetype-admin-path/docs/contract/WORKFLOW_GUIDE.md)

## 历史索引

下面这些文件仅保留给历史追溯使用：

1. `01` Generation Direction
2. `02` Existing Generation Audit
3. `03` Contract To Generation Bridge
4. `03.5` Multi Generation Run
5. `03.6` Legacy Convergence
6. `04` Runs Alignment
7. `05` Mainline Validation
