# Contract New Step 4 Prompt

你现在只负责 `contract-new` 的第四步执行。

这一轮不是继续改造 `contract` 内部逻辑，而是：

- **锁定 `develop` 入口与落地实现后基线 (`baseline`)**

## 本轮唯一目标

让系统具备“实现验证后沉淀真相源”的能力，并明确 `develop` 的输入边界。

## 开始前先确认

开始之前，先确认前三步已经满足：

1.  `contract` 已经实现单 flow 独立 run 结构（`intake/`, `working/`, `release/`）。
2.  `contract/release/` 下已经能产出 `openapi.yaml`, `openapi.summary.md` 和 `develop-handoff.md`。
3.  `scripts/contract/init_flow_run.rb` 等核心脚本已正常工作。

**特别说明：`runs/` 内现有的带日期前缀的旧产物（如 `2026-04-24-contract-...`）属于旧版逻辑，本轮严禁将其用于测试，也不需要对其进行兼容性修改。所有本轮测试必须基于 `init_flow_run.rb` 生成的新结构运行。**

## 你必须先读取这些文件

- /Users/wangwenjie/project/archetype-admin-path/docs/development_progress/contract-new/README.md
- /Users/wangwenjie/project/archetype-admin-path/docs/development_progress/contract-new/CONTRACT_NEW_FULL_DIRECTION.md
- /Users/wangwenjie/project/archetype-admin-path/docs/development_progress/contract-new/CONTRACT_NEW_EXECUTION_RUNBOOK.md
- /Users/wangwenjie/project/archetype-admin-path/docs/development_progress/contract-new/04_DEVELOP_INPUT_AND_BASELINE_WORKPLAN.md
- /Users/wangwenjie/project/archetype-admin-path/docs/contract/WORKFLOW_GUIDE.md

## 本轮硬约束

1.  不做旧数据兼容：不碰旧的 `runs/` 目录。
2.  `develop` 严禁读取 `contract/working/` 下的过程态草稿。
3.  `baselines/` 必须按 flow-id 组织。
4.  不做兼容层，不引入旧 `freeze/publish` 语义。

## 本轮必须完成的事情

### 1. 锁定 `develop` 入口

明确并落地：`develop` 阶段唯一合法的输入源是 `runs/YYYY-MM-DD-contract-<flow-id>/contract/release/`。更新相关的 README 或引导文档。

### 2. 定义并建立 `baselines/` 结构

目标形态：
- `baselines/<flow-id>/current/`: 存当前稳定、已验证的合同与结算说明。
- `baselines/<flow-id>/history/`: 存历史基线版本。

### 3. 实现 `settle_baseline.rb` 脚本

编写一个最小化脚本，支持将 `contract/release/` 内容迁移到 `baselines/<flow-id>/current/`，并生成结算说明 `implementation-settlement.md`。

### 4. 落地回改决策矩阵

更新 `docs/contract/WORKFLOW_GUIDE.md`，明确当业务变更时，如何判断回切到 PRD、Handoff、Flow 还是 Baseline。

### 5. 旧产物隔离声明

新建 `/Users/wangwenjie/project/archetype-admin-path/runs/README.md`，明确标注旧目录不参与新流程测试。

## 执行顺序

1.  新建 `runs/README.md` 实现旧产物隔离。
2.  更新 `WORKFLOW_GUIDE` 落地回改决策逻辑。
3.  定义 `baselines/` 目录结构。
4.  编写 `settle_baseline.rb` 脚本。
5.  对齐 `develop` 输入路径定义。

## 输出要求

本轮结束时必须明确汇报：
1.  `develop` 输入路径最终锁定在哪。
2.  `baselines/` 目录具体呈现什么样。
3.  回改决策矩阵具体内容。
4.  `settle_baseline.rb` 脚本实现了哪些功能。
