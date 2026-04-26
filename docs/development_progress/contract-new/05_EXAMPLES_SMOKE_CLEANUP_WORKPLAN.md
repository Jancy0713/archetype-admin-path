# [COMPLETED] Contract New Step 5 Workplan

这份文档已完成执行：
- 样例、Smoke、清旧入口与最终收尾

这一步是整个 `contract-new` 改造的最后一步，目标是把过程中的“梯子”撤掉，留下干净的主链。

## 这一步的唯一目标

完成全链路闭环验证，清理不再需要的旧脚本和说明，并确保所有文档入口已指向新标准。

## 这一步完成后必须成立的事实

1.  **Smoke 全覆盖**：存在一个覆盖从 `init_flow_run` 到 `settle_baseline` 的全链路 Smoke 测试。
2.  **遗留入口清空**：物理删除所有被标记为 `Legacy` 或 `Disabled` 的旧脚本（如 `expose_next_batch.rb`）。
3.  **样例对齐**：`docs/contract/examples/` 下有至少一个符合新版 Single Flow 结构的完整样例参考。
4.  **工程清理**：删除 `runs/` 下用于临时测试的垃圾目录，仅保留 `README.md` 隔离声明和真正有价值的 runs。

## 这一步必须坚持的原则

1.  **彻底性**：不再保留带 `warning` 的禁用脚本，直接物理删除，减少认知负担。
2.  **自解释性**：Smoke 测试应作为新版流程的“活文档”，展示标准执行序列。
3.  **不回头看**：不为旧版数据保留任何兼容性残留。

## 这一步的处理范围

### A. 全链路 Smoke 测试升级

将 `single_flow_release_smoke.rb` 升级为全链路测试，增加对 `settle_baseline.rb` 的调用验证。
确保它覆盖：
- `intake/` 有效性
- `contract/working/` 流程执行
- `review` 自动触发 `release` 逻辑
- `baseline` 正式落盘逻辑

### B. 物理清理旧脚本与旧文件

删除列表（初稿，需 AI 确认）：
- `scripts/contract/expose_next_batch.rb`
- `scripts/contract/generate_batch_handoffs.rb` (如已在 `handoff_generation.rb` 中包含)
- 其他冗余且不再维护的旧版 smoke 测试

### C. 建立新版标准样例 (Samples)

在 `docs/contract/examples/` 下，按 Single Flow 结构组织一个“黄金案例”：
- 包含 `01..03` 的典型 YAML 写法
- 包含对应的 `rendered/` Markdown 执行样板

### D. 文档终期审计

扫描 `docs/` 下的所有文档，确保没有任何地方在教人去 `contracts/` 下开工，或者教人使用 `freeze/publish` 命令。

## 执行顺序

### Phase 5A: 升级全链路 Smoke

让全链路测试跑通，作为“毕业”证明。

### Phase 5B: 建立黄金样例

为后续 AI 模仿提供高质量的 One-shot 样本。

### Phase 5C: 物理清理

删除所有 legacy 标注的脚本和废弃目录。

### Phase 5D: 终期验收

检查 `ProgressBoard` 和 `ExecutionSummary` 是否已完全工作在新主链下。

## 完成标准

1.  `ruby scripts/contract/single_flow_release_smoke.rb` 满血通过（包含 baseline 步骤）。
2.  `scripts/contract/` 下只有符合新版定义的“活着”的脚本。
3.  `docs/contract/examples/` 样例齐全。
4.  不再有任何旧版入口存留。

## 建议交给 AI 的一句话任务

完成第五步：升级全链路 Smoke 测试以包含基线沉淀验证，建立新版标准样例目录，并彻底物理清理所有 Legacy 标注的废弃脚本和冗余文件。
