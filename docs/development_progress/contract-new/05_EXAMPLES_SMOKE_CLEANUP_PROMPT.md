# Contract New Step 5 Prompt

你现在只负责 `contract-new` 的第五步（最后一步）执行。

这一轮的目标是：

- **样例收口、Smoke 升级、以及物理清理所有旧入口**

## 本轮唯一目标

完成 `contract-new` 改造的最后收尾，确保流程闭合、文档对齐、且无死代码残留。

## 开始前先确认

1.  第四步 `develop` 入口锁定和 `baseline` 基线逻辑已落地。
2.  `settle_baseline.rb` 已经可以正常工作。
3.  前序所有 `contract/working/` 和 `contract/release/` 的分层逻辑已通过验证。

## 你必须先读取这些文件

- /Users/wangwenjie/project/archetype-admin-path/docs/development_progress/contract-new/README.md
- /Users/wangwenjie/project/archetype-admin-path/docs/development_progress/contract-new/CONTRACT_NEW_EXECUTION_RUNBOOK.md
- /Users/wangwenjie/project/archetype-admin-path/docs/development_progress/contract-new/04_DEVELOP_INPUT_AND_BASELINE_WORKPLAN.md
- /Users/wangwenjie/project/archetype-admin-path/docs/development_progress/contract-new/05_EXAMPLES_SMOKE_CLEANUP_WORKPLAN.md
- /Users/wangwenjie/project/archetype-admin-path/scripts/contract/single_flow_release_smoke.rb

## 本轮必须完成的事情

### 1. 升级全链路 Smoke 测试

修改 `scripts/contract/single_flow_release_smoke.rb`：
- 在 Review Passed 之后，增加调用 `ruby scripts/contract/settle_baseline.rb <flow-id>` 的逻辑。
- 验证 `baselines/<flow-id>/current/` 下确实产出了正确的文件。
- 确保测试中生成的临时 Run 路径是在 `/tmp` 下，不污染正式环境。

### 2. 建立新版黄金样例 (Standard Samples)

在 `docs/contract/examples/new-flow-sample/` 下建立一个标准的单 flow 范例结构：
- 包括 `intake/`, `contract/working/`, `contract/release/` 各层级的样例文件。
- 这个样例将作为后续 AI 模仿的“真理样本”。

### 3. 物理清理 Legacy 脚本

- 检查 `scripts/contract/` 下所有带 `Legacy` 标注或已废弃的脚本。
- **物理删除** 这些文件（不仅仅是空壳）。
- 确保所有的 `smoke_test` 文件要么被合并，要么不再引用这些旧脚本。

### 4. 终期文档审计与路径修正

- 扫描 `docs/contract/` 目录，确保所有提及“开工路径”的地方都已更新。
- 检查 `README.md` 等引导文件，删除所有不再有效的“旧版入口说明”。

## 本轮禁止做的事情

- 不要在收尾阶段引入任何新的业务功能逻辑。
- 不要尝试修复旧数据，直接删除即可。

## 执行顺序

1.  升级并跑通全链路 Smoke。
2.  建立 `docs/contract/examples` 下的黄金样例。
3.  删除旧脚本和废弃目录。
4.  最后巡查一遍所有文档路径，完成收官。

## 输出要求

本轮结束时必须明确汇报：
1.  全链路 Smoke 覆盖了哪些关键步骤。
2.  哪些 Legacy 脚本已被删除。
3.  展示新版黄金样例的目录结构。
4.  确认全项目是否还存在任何已废弃的 `contracts/` 或 `freeze/publish` 语义。
