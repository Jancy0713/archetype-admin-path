# 待定与后续补充

这个文档用于集中记录当前已识别、但暂时不作为高优先级推进的补充项。

原则：

- 只记录明确知道后续要补的内容
- 不在当前主流程里展开实现
- 等主链路稳定后再逐项处理

## Init Flow

### 初始化题库补充

- 补充 `project_profile` 四阶段的常见行业化补充题
- 补充更常见的初始化推荐选项生成参考
- 补充特殊场景下允许出现的 `adaptive_questions` 参考边界

### Baseline / Change Tracking

- 让 `change_request` 显式引用受影响的 baseline 字段路径
- 让 `change_request` 关联对应 `field_sources`，便于基线变更追踪
- 明确 baseline 变更前后 diff 的结构化表达方式

## PRD Flow

- 补充常用 PRD 问题清单
- 补充更稳定的业务功能澄清题模板
- 评估是否需要把高频 PRD 问题也做成可校验结构

