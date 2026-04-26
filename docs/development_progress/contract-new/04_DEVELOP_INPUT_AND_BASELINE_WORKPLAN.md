# Contract New Step 4 Workplan

这份文档只服务第四步执行：

- `develop` 入口对齐与实现后基线 (`baseline`) 落地

这一步不负责改造旧的 `runs/` 目录，也不负责把旧代码生成逻辑迁到新版。

## 这一步的唯一目标

让后续执行链条明确：

- `develop` 阶段正式吃什么、从哪吃。
- 实现验证通过后，正式真相源 (`source of truth`) 沉淀到哪里。
- 业务需求变更时，从哪一个层级回切（PRD / Handoff / Flow / Baseline）。

## 这一步完成后必须成立的事实

1.  `develop` 阶段的正式输入路径已锁定为 `contract/release/`，不再直接读取 `contract` 过程态。
2.  `baselines/` 目录结构已落地，用于持久化“被实现验证过”的稳定合同。
3.  回改决策矩阵（Re-entry Matrix）已文档化并进入核心规则。
4.  旧产物隔离：明确 **`runs/` 内的旧产物（带日期前缀的旧 contract runs）不用于新流程测试，也不需要针对新脚本做兼容性修改**。

## 这一步必须坚持的原则

1.  **不兼容旧数据**：不修改或适配旧的 `runs/` 目录；如果测试需要 Run 目录，必须用 `init_flow_run.rb` 重新生成。
2.  **基线以 Flow 为单位**：基线沉淀优先按 flow-id 组织，不强求过早聚合成整项目大包。
3.  **输入防泄露**：`develop` 严禁读取 `contract/working/` 下的任何草稿。
4.  **不做旧 generation 桥接**：不再连接到旧的 `freeze/publish` 逻辑。

## 这一步的处理范围

### A. `develop` 入口定义

明确 `develop` 入口至少包含：

- `runs/YYYY-MM-DD-contract-<flow-id>/contract/release/openapi.yaml`
- `runs/YYYY-MM-DD-contract-<flow-id>/contract/release/openapi.summary.md`
- `runs/YYYY-MM-DD-contract-<flow-id>/contract/release/develop-handoff.md`

### B. `baselines/` 目录形态

目标形态应接近：

```text
baselines/
  <flow-id>/
    current/
      openapi.yaml
      openapi.summary.md
      implementation-settlement.md # 实现结算说明
      develop-verified-handoff.md  # 经由实现验证过的交付说明
    history/
      <run-id>/
        ...
```

### C. 回改决策矩阵 (Re-entry Matrix)

| 变更类型 | 影响范围 | 回切入口 | 必须重走阶段 |
| :--- | :--- | :--- | :--- |
| **全局需求变更** | 业务目标、模块边界、跨 flow 逻辑 | `prd/` (final_prd) | 全部 (Handoff -> Contract -> Develop) |
| **Flow 逻辑变更** | 拆分策略、Flow 依赖顺序 | `contract_handoff/` | 该 flow 及其受影响下游的所有 contract/develop |
| **局部协议变更** | 单个 Flow 内的字段、接口形态调整 (未开始实现) | `contract-<flow-id>/` | 该 flow 的 contract 收口与 develop |
| **已上线/已实现变更**| 已在 baseline 沉淀且涉及多版本共存或稳定基线修改 | `baselines/` | 基于 baseline 的增量修改流 |

### D. 脚本与工具支持

本轮需要补齐/更新：

- `scripts/contract/settle_baseline.rb`: 将 `contract/release` 下的内容沉淀到 `baselines/`。
- 修改 `develop` 相关的启动说明文档，将其输入路径写死。

## 执行顺序

### Phase 4A: 锁定 develop 输入路径

更新文档和脚本，确保 `develop` 入口唯一从 `release/` 获取输入。

### Phase 4B: 定义基线落盘规则

创建 `baselines/` 结构示例，并编写 `settle_baseline.rb` 脚本初稿。

### Phase 4C: 落地回改决策文档

在 `docs/contract/WORKFLOW_GUIDE.md` 中补齐“修改需求从哪里回切”的正式说明。

### Phase 4D: 旧产物隔离标注

在 `runs/README.md`（新建）中显式标注：**带日期前缀的旧 contract 目录仅供历史参考，不再参与任何新版脚本测试与执行。**

## 完成标准

1.  `develop` 输入边界清晰，不再混用开发草稿。
2.  `baselines/` 目录已建立。
3.  回改决策矩阵已在 `WORKFLOW_GUIDE` 中体现。
4.  旧产物隔离规则已在 `runs/README.md` 中明示。

## 建议交给 AI 的一句话任务

只做第四步：落地 develop 输入路径锁定、baselines 目录定义以及回改决策矩阵，并明确标注隔离 runs 内的旧产物，不做兼容改造。
