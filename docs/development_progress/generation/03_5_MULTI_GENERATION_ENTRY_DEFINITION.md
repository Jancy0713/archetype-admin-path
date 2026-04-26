# Multi Generation Entry Definition

这份文档用于完成 `03.5`，把 `contract => generation` 的当前正式方案收敛为“批量准备多个独立 generation run”。

注意：

- 本文是当前正式依据
- `03.0` 的 bridge 收口与脚本抓手继续保留
- 本文只定义 `contract => generation` 入口，不进入 generation 内部实现

## 正式定位

正式主链仍然是：

```text
init -> prd -> contract -> bridge -> generation
```

其中当前口径改为：

- `contract` 负责把每个 batch 收敛为已 review、已 freeze、已 publish 的正式输入单元
- `bridge` 负责扫描已 publish contracts，并为每个 contract 创建一个独立 generation run
- `generation` 负责在某个 generation run 内继续推进对应 contract 的正式生成工作

关键约束：

1. `bridge` 不是 generation 内部开发。
2. `bridge` 不是把全部 contracts 聚合成唯一 generation。
3. 一个 published contract 对应一个独立 generation run。
4. generation run 应直接落在 `runs/` 下，不再嵌套在源 run 的 `generation/<contract_id>/` 或 `generation/entries/<contract_id>/` 中。
5. AI 可以给推荐顺序，但不能把用户锁死在唯一顺序上。

## 进入条件

只要某个 contract 已 publish，就允许为它创建 generation run。

bridge 在批量准备 generation runs 时，仍必须补齐下面信息：

1. 当前已 publish 的 contract 列表
2. 尚未 publish 的 contract 列表
3. 每个 generation run 的依赖关系
4. 每个 generation run 当前是否可独立开始
5. 推荐顺序只是推荐，不是强制

## 单个 generation run 的正式定义

一个 generation run，本质上是“围绕一个 published contract 准备好的独立运行目录”。

它至少要回答清楚下面几件事：

1. 这个 run 对应哪个 `contract_id`
2. 它的 `run_id` 是什么
3. 它当前建议做什么 generation 工作
4. 它依赖哪些其他 contract 或上游产物
5. 它已经自动带上了哪些正式输入材料
6. 用户如果现在就要开始，应该从哪里读、从哪里继续

## 正式目录结构

当前推荐结构如下：

```text
runs/<source-run-id>/
  bridge/
    generation-bridge-index.yaml
    generation-bridge-kickoff.yaml
    generation-bridge-summary.md
    generation-run-overview.yaml
    generation-run-overview.md

runs/generation-<contract_id>/
  run.yaml
  README.md
  request.md
  inputs/
    generation-manifest.snapshot.yaml
    publish-manifest.snapshot.yaml
    freeze.snapshot.yaml
    contract-spec.snapshot.yaml
    review.snapshot.yaml
    rendered/
  outputs/
  handoffs/
  state/
```

目录职责：

### `runs/<source-run-id>/bridge/`

- 放本次 bridge 的批量准备结果
- 告诉用户这次一共生成了哪些 generation runs
- 告诉用户推荐顺序、依赖关系和未就绪项

### `runs/generation-<contract_id>/`

- 对应一个 published contract 的独立 generation run
- 这是后续 generation 正式继续推进的运行目录

### `run.yaml`

- 该 generation run 的结构化真相源
- 供脚本、后续 agent 和回归消费

### `README.md`

- 该 run 的人类阅读入口
- 告诉用户这个 run 是什么、依赖什么、建议先看什么

### `request.md`

- 自动生成
- 不是让用户从零重写需求
- 而是把该 contract 对应的 generation 启动请求预填好，作为该 run 的直接入口

### `inputs/`

- 固化从 published contract 注入过来的正式输入材料快照
- 只允许引用或快照正式发布态，不允许回读 run 内 contract 过程态

## `request.md` 规则

`request.md` 必须自动生成，且必须预填。

原因：

1. generation run 应自动准备初始化材料
2. 用户不应在 contract 已 publish 后，再手工重写一次起始请求
3. generation run 仍需要一个最小自然语言入口，帮助 agent 快速进入任务

建议至少包含：

1. `Generation Target`
2. `Contract Source`
3. `Recommended Scope`
4. `Dependencies`
5. `Parallel Runs`
6. `Prepared Inputs`
7. `Execution Notes`

## contract 输入材料注入规则

每个 generation run 都必须自动注入该 contract 的正式输入材料。

当前最小注入集固定为：

1. `generation_manifest.yaml`
2. `publish_manifest.yaml`
3. `freeze.yaml`
4. `contract-03.contract_spec.yaml`
5. `contract-04.review.yaml`
6. `rendered/*.md`

要求：

1. 结构化入口要写进 `run.yaml`
2. 人类可读说明要写进 `README.md`
3. 运行时直接消费材料要落到 `inputs/`
4. 不能要求用户自己再去 `contracts/<contract_id>/current/` 手工拼路径
5. 不能把 contract run 内过程态材料混进来

## bridge 总览文档应包含什么

bridge 总览文档是“批量准备多个 generation runs”后给用户看的第一入口。

它至少应包含：

1. 本次已生成哪些 generation runs
2. 哪些 contract 尚未 publish，因此还没有 generation run
3. 推荐顺序
4. 明确的依赖关系
5. 明确的平行关系
6. 哪些 run 当前可立即开始
7. 每个 run 对应目录在哪里

## 批量创建 workflow

正式 workflow 收敛为下面三步：

1. 扫描当前已 publish contracts
2. 为每个已 publish contract 创建一个独立 generation run
3. 生成 bridge 总览文件，向用户解释推荐顺序、依赖关系、平行关系和未就绪项

## 当前稳定结论

`03.5` 当前正式结论是：

- `one published contract = one generation run`
- generation run 直接落在 `runs/` 下
- 源 run 只保留 bridge 总览，不再容纳 `generation/<contract_id>/` 子目录
- 后续 `04/05` 应围绕这个 run 级结构继续收敛和验证
