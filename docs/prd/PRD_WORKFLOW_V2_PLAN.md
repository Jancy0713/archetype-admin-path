# PRD 2.0 实施记录

## 目标

这份文档不再作为“未来规划草稿”，而是用于记录当前 `PRD 2.0.0` 的实施状态、已经完成的改造、剩余待办以及后续增强方向。

## 当前正式流程

当前正式 PRD 主链路已经切换为：

1. `prd-01 analysis`
2. `prd-02 clarification`
3. `prd-03 execution_plan`
4. `prd-04 final_prd`
5. `contract`

参考：

- [docs/prd/WORKFLOW_GUIDE.md](/Users/wangwenjie/project/archetype-admin-path/docs/prd/WORKFLOW_GUIDE.md)
- [docs/prd/STEP_NAMING_GUIDE.md](/Users/wangwenjie/project/archetype-admin-path/docs/prd/STEP_NAMING_GUIDE.md)
- [docs/WORKFLOW_FLOW_OVERVIEW.md](/Users/wangwenjie/project/archetype-admin-path/docs/WORKFLOW_FLOW_OVERVIEW.md)

## 2.0.0 已完成

### 1. 主流程协议已切换

已完成从旧三步协议到新四步协议的切换：

- 旧：`clarification -> brief -> decomposition`
- 新：`analysis -> clarification -> execution_plan -> final_prd`

### 2. 主模板已切换

当前正式模板为：

- [analysis.template.yaml](/Users/wangwenjie/project/archetype-admin-path/docs/prd/templates/structured/analysis.template.yaml)
- [clarification.template.yaml](/Users/wangwenjie/project/archetype-admin-path/docs/prd/templates/structured/clarification.template.yaml)
- [execution_plan.template.yaml](/Users/wangwenjie/project/archetype-admin-path/docs/prd/templates/structured/execution_plan.template.yaml)
- [final_prd.template.yaml](/Users/wangwenjie/project/archetype-admin-path/docs/prd/templates/structured/final_prd.template.yaml)
- [review.template.yaml](/Users/wangwenjie/project/archetype-admin-path/docs/prd/templates/structured/review.template.yaml)

已移除主模板目录中的：

- `brief.template.yaml`
- `decomposition.template.yaml`

### 3. 主脚本已切换

当前 `scripts/prd` 只认以下 artifact：

- `analysis`
- `clarification`
- `execution_plan`
- `final_prd`
- `review`

涉及脚本：

- [scripts/prd/artifact_utils.rb](/Users/wangwenjie/project/archetype-admin-path/scripts/prd/artifact_utils.rb)
- [scripts/prd/init_artifact.rb](/Users/wangwenjie/project/archetype-admin-path/scripts/prd/init_artifact.rb)
- [scripts/prd/validate_artifact.rb](/Users/wangwenjie/project/archetype-admin-path/scripts/prd/validate_artifact.rb)
- [scripts/prd/render_artifact.rb](/Users/wangwenjie/project/archetype-admin-path/scripts/prd/render_artifact.rb)

### 4. reviewer 机制已收紧

当前正式约束已经明确：

- reviewer 必须存在
- reviewer 必须由独立 reviewer 子 agent 或独立新上下文执行
- 主 agent 不得自己兼任 reviewer
- 主 agent 只能准备 reviewer 输入、读取 reviewer 输出并据此返工

这条规则已同步到流程文档、prompt、运行指南和 run 初始化入口。

### 5. create_run 已切换

当前新建 `prd` run 时：

- 首步已改为 `prd-01.analysis.yaml`
- 首次校验与渲染命令已改为 `analysis`
- run-agent prompt 的 step map 已改为四步流程

涉及文件：

- [scripts/create_run.rb](/Users/wangwenjie/project/archetype-admin-path/scripts/create_run.rb)
- [docs/templates/autonomous-run-prompt.prd.template.md](/Users/wangwenjie/project/archetype-admin-path/docs/templates/autonomous-run-prompt.prd.template.md)

## 2.0.0 关键设计原则

### 1. 先分析，再提问，再排序，再定稿

`prd` 不再一上来就进入补问，而是：

1. 先分析输入
2. 再对真正不确定的问题做澄清
3. 再明确执行计划
4. 最后收敛成可交给 contract 的最终 PRD

### 2. 复用 init 的确认协议

`clarification` 已按统一确认项协议收敛：

- 所有待确认问题统一进入 `confirmation_items`
- 通过 `level` 区分优先级
- 支持推荐项、候选项、自定义回答和默认值

### 3. Human Confirmation Gate 显式化

当前 `clarification` 默认必须显式经过人工确认，未确认前不能进入 `execution_plan`。

### 4. final_prd 面向 contract

当前终点不再是“结构化拆解完成”，而是“`final_prd` 足够支撑 contract 设计”。

## 2.0.0 尚未做的事

当前明确还没做的内容：

1. 旧 `runs/` 的历史产物迁移
2. 基于新四步流程的首轮真实 run 验证
3. `CHANGELOG.md` 的 `2.0.0` 正式收口记录

说明：

- 旧 `runs/` 当前按历史产物保留，不在这一阶段改写
- `CHANGELOG` 等首轮真实验证通过后再统一更新

## 当前剩余待办

在正式验证前，当前还应补的内容主要有：

1. 准备首轮真实验证 run 的执行说明，但暂不改写旧 run
2. 基于新四步流程执行首轮真实验证
3. 验证通过后更新 `CHANGELOG.md`

验证准备清单见：

- [PRD_2_0_VALIDATION_PREP.md](/Users/wangwenjie/project/archetype-admin-path/docs/prd/PRD_2_0_VALIDATION_PREP.md)

## 2.1.0 之后再做

这些内容不放在 `2.0.0` 当前收口范围里：

1. 把主链路补到“完整可测”版本
2. 提示词 / 规则 / reviewer / 步骤资料的结构治理
3. 外部 `skill` 接入与效果验证
4. 高频问题库沉淀
5. 自动补全更多计划生成辅助
6. 更强的自动化编排增强

`2.1.0` 范围定义见：

- [PRD_2_1_SCOPE.md](/Users/wangwenjie/project/archetype-admin-path/docs/prd/PRD_2_1_SCOPE.md)

当前候选 skill 先记录，不在 `2.0.0` 中绑定：

- `pm-skills`
- `product-manager-skills`
- `prd-colipot`
- `to-prd`
- `to-issues`
- `grill-me`
- `github/awesome-copilot@prd`
- `github/awesome-copilot@breakdown-feature-prd`
- `request-refactor-plan`
