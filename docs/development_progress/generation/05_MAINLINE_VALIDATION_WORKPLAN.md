# Mainline Validation Workplan

这份文档用于指导 `05`：验证 `contract => bridge => standalone generation runs` 当前正式主链是否已经收稳。

## 本轮目标

验证当前仓库已经只有一条正式 generation 入口叙事：

```text
published contracts
  -> bridge prepares standalone generation runs
  -> runs/generation-<contract_id>/
```

## 本轮验证清单

### Phase 5A: Bridge Artifact Validation

- `prepare_generation_bridge.rb` 能稳定生成 `bridge/` 与 generation run overview
- `verify_generation_bridge.rb` 能稳定校验 bridge 总览与生成结果
- bridge summary 不再把 generation 放进源 run 的子目录

### Phase 5B: Generation Run Structure Validation

- 每个已 publish contract 都有独立 generation run
- 每个 generation run 都有 `run.yaml`、`README.md`、`request.md`
- `inputs/` 自动带上 snapshot
- `outputs/`、`handoffs/`、`state/` 目录已就位

### Phase 5C: Dependency And Status Validation

- `recommended_run_order` 正确表达推荐顺序
- `ready / blocked / waiting_upstream_publish` 断言一致
- `depends_on` 与 `parallel_with` 口径一致

### Phase 5D: Regression Surface Validation

- 正式 smoke 只围绕 bridge 与 generation run 断言
- 已删除的旧 `generation_kickoff.rb` 与旧 `generation-run.yaml` 不再作为通过条件
- README、workflow guide、examples 没有把源 run 内嵌 generation 子目录写成正式入口

## 完成标准

本轮结束时，应达到：

1. `05` 可以明确证明当前正式入口只有独立 generation runs
2. 所有正式断言都不再依赖旧单 kickoff / 旧 nested generation 目录
3. 下一轮如果进入 generation 内部开发，不需要再猜 run 结构
