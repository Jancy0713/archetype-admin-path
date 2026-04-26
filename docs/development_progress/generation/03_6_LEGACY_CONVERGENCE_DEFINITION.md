# Legacy Convergence Definition

这份文档用于完成 `03.6`，把旧 generation 资产如何直接收敛到当前正式方案定清楚，避免继续保留历史包袱。

## 一句话结论

当前正式策略固定为：

1. 保留仍然正确的单 contract 输入能力
2. 直接改造错误正式入口，使其并入“一个 published contract = 一个独立 generation run”
3. 删除或降级只服务旧主路径叙事的样例、说明和回归
4. 不为了兼容旧入口而长期保留双路径

## 当前正式主路径

当前唯一应收敛到的正式主路径是：

```text
published contracts
  -> bridge prepares standalone generation runs
  -> runs/generation-<contract_id>/
  -> user/agent 选择某个 generation run 开始 generation
```

这意味着：

- 正式 bridge 入口不再是单 `contract_id` kickoff
- 正式 bridge 入口也不再是 `runs/<source-run>/generation/<contract_id>/`
- `generation_manifest.yaml` 仍保留，但只作为单 contract 底层输入单元
- 旧 consumer/bootstrap/output handoff 叙事不再是正式流程名义

## 旧资产分类结论

### A. 直接保留为底层能力

1. [scripts/contract/generation_input.rb](/Users/wangwenjie/project/archetype-admin-path/scripts/contract/generation_input.rb)
2. [scripts/contract/generation_materials.rb](/Users/wangwenjie/project/archetype-admin-path/scripts/contract/generation_materials.rb)
3. `contracts/<contract_id>/current/generation_manifest.yaml`

这些资产仍然正确，但只作为底层能力，不作为正式 workflow 入口。

### B. 直接移除旧正式入口

1. `scripts/contract/generation_kickoff.rb`
2. `scripts/generation/consume_manifest.rb`
3. `scripts/generation/bootstrap_run.rb`
4. `scripts/generation/emit_consumer_outputs.rb`
5. `scripts/generation/manifest_utils.rb`
6. `scripts/generation/*smoke*.rb`

这些旧入口和旧辅助脚本不再保留在仓库里，避免后续 AI 或人工继续沿着单 kickoff / 单 manifest / nested generation run 的旧主路径推进。

### C. 删除旧样例并只在历史文档中保留名称

下面这些旧样例已经从 examples 视图中移除：

1. `docs/contract/examples/1.0/mainline-path-run/generation/generation-kickoff.yaml`
2. `docs/contract/examples/1.0/mainline-path-run/generation-run/**`
3. 所有仍以单 `generation-run.yaml` / `generation-output-manifest.yaml` 表示正式主线的旧样例

## 命名与目录收敛规则

从 `03.6` 开始，后续实现应遵守：

1. 正式目录以独立 generation run 为单位，而不是 `entries/<contract_id>/`
2. run id 推荐直接采用 `generation-<contract_id>`
3. 源 run 只保留 bridge 总览与映射信息
4. 不再把 `runs/<source-run>/generation/` 当成正式 generation 工作区
5. examples 目录只保留“当前正式 run 级样例”

## 对 `04` 的正式 handoff

`04` 应直接按下面策略执行：

1. 先删除旧 kickoff / consumer / bootstrap / output handoff 脚本
2. 从 examples 里移除旧 `generation/` 与 `generation-run/` 样例
3. 把正式样例改成“源 run 的 bridge 总览 + 独立 generation run 目录”
4. 不再新增任何新的源 run 内嵌 generation 子目录样例
5. 更新 README，使推荐入口只指向 run 级 structure

## 对 `05` 的正式 handoff

`05` 应直接按下面策略改断言：

1. 不再以 `generation_kickoff.rb <contract_id>` 成功作为正式主链通过条件
2. 不再以旧 `generation-run.yaml` / `generation-output-manifest.yaml` 作为 bridge 主线核心断言
3. 改为验证：
   - 已 publish contracts 可被批量扫描
   - 每个 published contract 都能生成独立 generation run
   - `run.yaml`、`request.md`、`README.md`、`inputs/` 自动就位
   - bridge 总览正确写出推荐顺序、依赖、平行关系与未就绪项

## 本轮结论

`03.6` 当前正式结论是：

- 旧 generation 资产不应长期以 legacy 包袱形式并行存在
- 旧正式入口应直接从仓库中移除，而不是继续挂名保留
- 只有底层输入解析、材料提取值得继续保留
- examples、guides、smoke 都必须在 `04/05` 跟着一起收敛，否则口径会继续分裂
