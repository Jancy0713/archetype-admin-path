# Phase 3A Structure Cleanup Decision

这份文档用于记录 `Phase 3A` 的结构收口结果。

目标不是删光历史资产，而是把下面三件事一次写清楚：

1. 哪些资产仍保留
2. 哪些资产只保留为历史记录
3. 哪些资产后续必须迁到 bridge 语义，不能再挂在 generation 正式入口名义下

## 决策结论

一句话结论：

当前正式入口已统一收口到 `docs/development_progress/generation/`。

当前唯一正式入口固定为：

- [03_CONTRACT_TO_GENERATION_BRIDGE_DEFINITION.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/generation/03_CONTRACT_TO_GENERATION_BRIDGE_DEFINITION.md)
- [03_CONTRACT_TO_GENERATION_BRIDGE_WORKPLAN.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/generation/03_CONTRACT_TO_GENERATION_BRIDGE_WORKPLAN.md)
- [03_CONTRACT_TO_GENERATION_BRIDGE_PROMPT.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/generation/03_CONTRACT_TO_GENERATION_BRIDGE_PROMPT.md)

## 保留 / 迁移 / 删除清单

### 保留为底层能力

1. `scripts/contract/published_contract.rb`
   - 保留
   - 原因：published contract 解析与校验仍是 bridge 底层能力
2. `scripts/contract/generation_input.rb`
   - 保留
   - 原因：可继续作为“单 contract 输入单元”解析器
3. `scripts/contract/generation_materials.rb`
   - 保留
   - 原因：可继续作为单 contract materials 提取器

### 已从正式入口移除

1. `docs/contract/examples/1.0/mainline-path-run/generation/`
   - 后续已从 examples 中删除
2. `docs/contract/examples/1.0/mainline-path-run/generation-run/`
   - 后续已从 examples 中删除

### 已删除的旧执行入口

下面资产已经不再保留，避免继续暗示旧 generation 主路径：

1. `scripts/contract/generation_kickoff.rb`
   - 原因：它是单 contract kickoff，不符合当前正式入口
2. `scripts/generation/consume_manifest.rb`
   - 原因：它消费的是单 contract manifest
3. `scripts/generation/bootstrap_run.rb`
   - 原因：它对应的是旧 nested generation run bootstrap
4. `scripts/generation/emit_consumer_outputs.rb`
   - 原因：它对应的是旧 consumer output handoff 叙事
5. `scripts/generation/manifest_utils.rb`
   - 原因：只服务于上述旧主路径
6. `scripts/generation/*smoke*.rb`
   - 原因：只验证上述旧主路径

当前已经补上的 bridge 正式脚本骨架是：

1. [scripts/contract/generation_bridge.rb](/Users/wangwenjie/project/archetype-admin-path/scripts/contract/generation_bridge.rb)
2. [scripts/contract/generation_bridge_index.rb](/Users/wangwenjie/project/archetype-admin-path/scripts/contract/generation_bridge_index.rb)
3. [scripts/contract/generation_bridge_kickoff.rb](/Users/wangwenjie/project/archetype-admin-path/scripts/contract/generation_bridge_kickoff.rb)
4. [scripts/contract/generation_bridge_smoke.rb](/Users/wangwenjie/project/archetype-admin-path/scripts/contract/generation_bridge_smoke.rb)

这些脚本属于 `03` 正式补上的最小 bridge 可执行骨架，不属于 generation 内部实现。

### 后续执行结果

后续 `03.6/04` 已经把上述旧执行入口从仓库里移除，并同步更新了 workflow guide、README 与 bridge smoke 口径。

## 已移除内容

此前会误导入口判断的旧 generation 文档与旧 generation 进度记录，已经从正式入口中移除。

## 旧 scripts/generation/* 的处置方式

当前统一处置如下：

1. 不迁目录
2. 不继续保留执行脚本
3. 文档层明确标注它们已退出仓库与正式入口
4. 正式主链只围绕 bridge + standalone generation runs 继续推进

## 当前正式路径

从这一轮结束开始，后续必须按下面顺序继续：

1. 完成 `03` bridge 定义
2. 调整现有 `runs/` 产物以匹配新 bridge 入口
3. 验证 `contract => bridge => generation` 主链
4. 再进入 generation 内部开发

在此之前，不得把错误入口当成正式起跑入口。
