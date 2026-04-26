# Legacy Convergence Workplan

这份文档用于指导下一上下文中的 AI，在 `03.5` 已完成后，进入 `03.6`：把旧 generation 资产直接收敛到当前正式方案，尽量不留历史包袱。

注意：

- `03.6` 不是进入 generation 内部开发
- `03.6` 也不是直接开始 `04` 的 runs/examples 对齐
- `03.6` 的目标是先决定旧代码哪些直接改、哪些改名、哪些删除
- 这一轮优先处理“正式入口语义”和“旧资产去历史包袱”的问题

## 当前已确认前提

1. `03.5` 已定稿：当前正式入口是 multi generation entry，而不是聚合成一个 generation。
2. 一个 published contract 对应一个 generation 起点。
3. `request.md` 应自动生成。
4. 单 contract `generation_manifest.yaml`、`generation_input.rb`、`generation_materials.rb` 仍可作为底层能力存在。
5. 旧的单 kickoff / consumer / bootstrap 路径，已经不应再作为正式桥接入口继续扩写。

## 本轮总目标

把“旧 generation 代码如何直接更新到最新”收敛为明确执行策略，避免后续实现时出现：

- 新旧两套路并行长期共存
- 旧文件继续挂着正式入口名义
- 为了兼容历史而保留过多中间层
- 实现层不知道哪些应该直接改，哪些应该删

一句话目标：

- 保留对的底层能力
- 直接改掉错的正式入口
- 不让旧路径继续作为产品级主路径存活

## 本轮应完成

### Phase 3.6A: Legacy Asset Classification

status: completed

目标：

- 把现有 generation 相关旧资产按“保留 / 直接改造 / 删除”三类分清

应完成：

- 逐项列出旧 scripts、examples、docs 的当前角色
- 明确哪些是仍有价值的底层能力
- 明确哪些是错误正式入口
- 明确哪些只是历史样例或临时骨架

完成标准：

- 后续实现前，不再对旧资产角色有歧义

### Phase 3.6B: Convergence Strategy

status: completed

目标：

- 定清楚旧资产如何直接并到当前正式方案，而不是长期挂 legacy 包袱

应完成：

- 明确哪些文件直接原地重写
- 明确哪些文件应迁名到更准确语义
- 明确哪些文件应在实现时删除
- 明确哪些兼容层不值得保留

完成标准：

- 下一轮实现时，工程策略是“收敛到一条主路径”，而不是“继续并行维护多条旧路径”

### Phase 3.6C: Implementation Handoff Basis

status: completed

目标：

- 给 `04/05` 和下一轮真实代码调整提供明确依据

应完成：

- 写出旧脚本清理与迁移清单
- 写出目录与命名调整原则
- 写出 examples/runs 在 `04` 中应如何跟随收敛
- 写出哪些验证脚本需要同步改断言

完成标准：

- 进入 `04` 时，不需要再临时讨论“旧代码到底怎么处理”

## 收敛原则

本轮默认遵守下面原则：

1. 能直接并入当前正式方案的旧能力，优先直接改，不额外套一层过渡壳。
2. 已经与正式方向冲突的旧入口，不继续保留“正式可用”身份。
3. 只有确实承担底层解析、校验、材料提取职责的旧能力，才允许保留。
4. 如需保留历史样例，必须降级为明确历史记录，不能再出现在正式入口说明中。
5. 不为了“兼容旧命名”而长期保留错误主路径。
6. 不在 `03.6` 里直接展开 generation 内部生成器实现。

## 当前重点判断对象

本轮至少应覆盖下面这些对象：

1. `scripts/contract/generation_kickoff.rb`
2. `scripts/generation/consume_manifest.rb`
3. `scripts/generation/bootstrap_run.rb`
4. `scripts/generation/emit_consumer_outputs.rb`
5. `scripts/contract/generation_input.rb`
6. `scripts/contract/generation_materials.rb`
8. `docs/contract/examples/1.0/mainline-path-run/generation/`
9. `docs/contract/examples/1.0/mainline-path-run/generation-run/`
10. 与上述路径绑定的 smoke / guide / README 说明

## 预期产出

本轮优先产出应是文档，不是代码实现：

1. 旧资产分类清单
2. 直接改造与删除策略
3. 命名与目录收敛规则
4. 给 `04/05` 使用的正式迁移依据

## 本轮已落地

- [03_6_LEGACY_CONVERGENCE_DEFINITION.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/generation/03_6_LEGACY_CONVERGENCE_DEFINITION.md)
- 更新 [README.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/generation/README.md) 中的阶段状态与推荐入口

## 当前边界

本轮不应直接展开：

- generation 内部后端接口定义生成器
- generation 内部前端代码生成器
- generation GUI
- 长期兼容层设计

## 下一步顺序

`03.6` 完成后，后续才能进入：

1. `04` runs/examples 对齐
2. `05` 主链验证
3. generation 内部开发

## 执行日志

### 2026-04-24

- 完成 `Phase 3.6A: Legacy Asset Classification`
  - 按“底层能力 / 直接改造对象 / 历史样例”三类完成旧资产盘点
  - 明确 `generation_input.rb`、`generation_materials.rb`、`generation_manifest.yaml` 继续保留
  - 明确 `generation_kickoff.rb` 与 `scripts/generation/*` 主路径语义已过时，后续应直接移除
- 完成 `Phase 3.6B: Convergence Strategy`
  - 定稿“保留对的底层能力，直接改掉错的正式入口”的收敛原则
  - 定稿删除旧执行入口、仅保留单 contract 输入能力的处理方式
- 完成 `Phase 3.6C: Implementation Handoff Basis`
  - 定稿给 `04` 的 examples/runs 对齐策略
  - 定稿给 `05` 的 smoke / mainline 断言调整方向
  - 停在文档定稿处，不进入实际代码调整
