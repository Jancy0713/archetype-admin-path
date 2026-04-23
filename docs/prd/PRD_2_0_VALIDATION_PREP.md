# PRD 2.0 首轮验证准备清单

## 目标

这份文档用于在不改写旧 `runs/` 的前提下，准备 `PRD 2.0.0` 的首轮真实验证。

当前定位：

- 只做验证准备
- 不直接启动新 run
- 不修改历史 run
- 等准备项确认后，再开始首轮真实验证

## 验证范围

首轮验证只验证当前正式主链路：

1. `prd-01 analysis`
2. `prd-02 clarification`
3. `Human Confirmation Gate`
4. `prd-03 execution_plan`
5. `prd-04 final_prd`
6. `contract handoff readiness`

不纳入这轮验证的内容：

1. 外部 `skill` 接入
2. 旧 `runs/` 迁移
3. 更多自动化增强
4. 仍未完成收口的 `2.1.0` 补强项

说明：

- 本文保留的是 `2.0.0` 阶段的验证准备语境
- 当前实际推进顺序应以 [PRD_VERSION_ROADMAP.md](/Users/wangwenjie/project/archetype-admin-path/docs/prd/PRD_VERSION_ROADMAP.md) 和 [PRD_2_1_SCOPE.md](/Users/wangwenjie/project/archetype-admin-path/docs/prd/PRD_2_1_SCOPE.md) 为准：先完成 `2.1.0` 收口，再做第一轮真实验证

## 验证前必须确认的准备项

### A. 正式入口一致性

当前应确认下面入口已经全部对齐：

- [docs/prd/README.md](/Users/wangwenjie/project/archetype-admin-path/docs/prd/README.md)
- [docs/prd/WORKFLOW_GUIDE.md](/Users/wangwenjie/project/archetype-admin-path/docs/prd/WORKFLOW_GUIDE.md)
- [docs/prd/STEP_NAMING_GUIDE.md](/Users/wangwenjie/project/archetype-admin-path/docs/prd/STEP_NAMING_GUIDE.md)
- [docs/prd/STRUCTURED_OUTPUT_GUIDE.md](/Users/wangwenjie/project/archetype-admin-path/docs/prd/STRUCTURED_OUTPUT_GUIDE.md)
- [docs/prd/PROMPTS_GUIDE.md](/Users/wangwenjie/project/archetype-admin-path/docs/prd/PROMPTS_GUIDE.md)
- [docs/templates/autonomous-run-prompt.prd.template.md](/Users/wangwenjie/project/archetype-admin-path/docs/templates/autonomous-run-prompt.prd.template.md)
- [docs/templates/workflow-progress.template.md](/Users/wangwenjie/project/archetype-admin-path/docs/templates/workflow-progress.template.md)
- [docs/WORKFLOW_FLOW_OVERVIEW.md](/Users/wangwenjie/project/archetype-admin-path/docs/WORKFLOW_FLOW_OVERVIEW.md)
- [docs/WORKFLOW_PROGRESS_BOARD.md](/Users/wangwenjie/project/archetype-admin-path/docs/WORKFLOW_PROGRESS_BOARD.md)
- [docs/RUNS_WORKSPACE_GUIDE.md](/Users/wangwenjie/project/archetype-admin-path/docs/RUNS_WORKSPACE_GUIDE.md)

当前状态：

- 已完成静态对齐

### B. 脚本可用性

当前应确认下面脚本可正常工作：

- [scripts/prd/init_artifact.rb](/Users/wangwenjie/project/archetype-admin-path/scripts/prd/init_artifact.rb)
- [scripts/prd/validate_artifact.rb](/Users/wangwenjie/project/archetype-admin-path/scripts/prd/validate_artifact.rb)
- [scripts/prd/render_artifact.rb](/Users/wangwenjie/project/archetype-admin-path/scripts/prd/render_artifact.rb)
- [scripts/prd/artifact_utils.rb](/Users/wangwenjie/project/archetype-admin-path/scripts/prd/artifact_utils.rb)
- [scripts/create_run.rb](/Users/wangwenjie/project/archetype-admin-path/scripts/create_run.rb)

当前状态：

- 语法检查已通过
- `analysis` 最小样例已验证过 `init -> validate -> render` 基本链路

### C. reviewer 独立性

验证前必须明确：

1. reviewer 必须由独立 reviewer 子 agent 或独立新上下文执行
2. 主 agent 不得自己兼任 reviewer
3. 验证时要实际按这个规则执行，而不是只在文档里声明

当前状态：

- 规则已写入正式文档和 prompt

### D. Human Confirmation Gate

验证前要明确本轮如何处理 `clarification` 的人工确认：

1. 默认在 `prd-02 clarification` 后停
2. 用户看到的是渲染后的 Markdown，而不是 YAML 原文
3. 人工确认完成前，不得推进到 `execution_plan`

当前状态：

- 流程层规则已明确
- 首轮验证时需要真实走一遍

## 首轮验证建议输入

建议优先选择：

1. 输入边界明确，但仍有少量待确认项的需求
2. 有 `init` 交接上下文的需求
3. 不要选过于庞大或跨太多业务域的 PRD

不建议首轮就选：

1. 需要大量领域知识补完的需求
2. 输入极度残缺的需求
3. 明显超出当前 `contract` 边界定义能力的复杂项目

## 首轮验证时重点观察什么

### 1. analysis

- 是否真的先分析、先拆分，而不是一上来就开始提问
- 是否能沉淀出合理的 `clarification_candidates`

### 2. clarification

- `confirmation_items` 是否真的收敛
- 是否只问真正需要用户确认的问题
- Human Gate 是否清楚

### 3. execution_plan

- 是否能给出明确推进顺序
- 是否能表达 contract 优先级和依赖关系

### 4. final_prd

- 是否足够给 contract 使用
- ready batch 的 `contract_handoff` 是否清楚
- `prd_batches` 是否拆分合理
- 是否还有遗漏的 P0

### 5. reviewer

- 是否确实由独立 reviewer 执行
- 是否能发现真实阻塞项，而不是只做形式审查

## 验证完成后的动作

如果首轮验证通过，下一步应做：

1. 更新 [CHANGELOG.md](/Users/wangwenjie/project/archetype-admin-path/CHANGELOG.md)
2. 记录验证结论和遗留问题
3. 再决定是否直接进入下一轮补强版本

如果首轮验证未通过，下一步应做：

1. 只修 `2.0.0` 主链路问题
2. 不提前进入后续能力扩展
3. 修完后重新跑下一轮验证
