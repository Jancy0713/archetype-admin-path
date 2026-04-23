# 待定与后续补充

这个文档用于集中记录当前已识别、但暂时不作为高优先级推进的补充项。

原则：

- 只记录明确知道后续要补的内容
- 不在当前主流程里展开实现
- 等主链路稳定后再逐项处理

## Init Flow

### Run Input UX

- [done] `raw/request.md` 已从 `Background / Scope` 改为 `One-line Requirement / Details / Notes`
- [done] `create_run.rb` 已同步生成新的初始化输入模板
- 待观察新的 `One-line Requirement / Details / Notes` 输入结构在真实测试中的填写成本
- 如用户仍频繁漏填关键信息，再考虑加入更强的填写引导或示例

### 初始化题库补充

- 补充 `project_profile` 四阶段的常见行业化补充题
- 补充更常见的初始化推荐选项生成参考
- 补充特殊场景下允许出现的 `adaptive_questions` 参考边界

### Baseline / Change Tracking

- 让 `change_request` 显式引用受影响的 baseline 字段路径
- 让 `change_request` 关联对应 `field_sources`，便于基线变更追踪
- 明确 baseline 变更前后 diff 的结构化表达方式

## PRD Flow

- 版本路线图见：[docs/prd/PRD_VERSION_ROADMAP.md](/Users/wangwenjie/project/archetype-admin-path/docs/prd/PRD_VERSION_ROADMAP.md)
- 当前 `2.0.0` 迭代规划见：[docs/prd/PRD_WORKFLOW_V2_PLAN.md](/Users/wangwenjie/project/archetype-admin-path/docs/prd/PRD_WORKFLOW_V2_PLAN.md)
- 首轮真实验证准备见：[docs/prd/PRD_2_0_VALIDATION_PREP.md](/Users/wangwenjie/project/archetype-admin-path/docs/prd/PRD_2_0_VALIDATION_PREP.md)
- `2.1.0` 范围定义见：[docs/prd/PRD_2_1_SCOPE.md](/Users/wangwenjie/project/archetype-admin-path/docs/prd/PRD_2_1_SCOPE.md)
- 优先保持 `prd/*.yaml` 的结构稳定和内容可交接；`rendered/*.md` 的人类可读性优化可以后置
- 明确区分 `yaml` 给 AI / 下游流程消费，`md` 给人阅读；避免为了可读性影响结构化 handoff 的稳定性
- 后续补强 `rendered/*.md` 的可读性表达，让 batch、依赖、后续步骤对人更直观
- 补充常用 PRD 问题清单
- 补充更稳定的业务功能澄清题模板
- 评估是否需要把高频 PRD 问题也做成可校验结构
- 推进 `confirmation_items` 在 `prd` 流程中的统一协议落地
- 明确 `final_prd -> contract` 的 handoff schema
