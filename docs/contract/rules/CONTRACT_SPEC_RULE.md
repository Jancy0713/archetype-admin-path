# Contract Spec Rule

## 目标

`contract_spec` 是当前 batch 的正式实现协议主体，是前端、后端、AI 和脚本共同消费的真相源。

它必须足够明确，避免下游继续猜关键实现边界。

## 核心原则

1. 只在当前 batch 范围内写正式协议。
2. 能引用前序 frozen contract 的，不重复发明。
3. 不把 PRD 背景说明写成 contract 主体。
4. 不把实现任务清单写成 contract。
5. 必须覆盖上游 handoff 要求的关键 consumer views。

## 这一阶段必须覆盖的内容

至少应覆盖：

1. 当前 batch 的正式适用范围
2. 当前 batch 的资源/实体协议
3. 关键字段与字段语义
4. 列表、详情、编辑、动作等 consumer views
5. 查询、筛选、排序、分页、搜索等输入语义
6. 状态机与枚举约束
7. 权限与租户边界
8. 错误语义与关键校验约束
9. 与前序 frozen contract 的引用关系

## 这一阶段不能做的事

不允许：

1. 重新打开需求澄清
2. 混入新的未确认功能
3. 把宏观 PRD 背景长篇重写进来
4. 把 coding checklist 当成 contract 主体
5. 引用未冻结、不可追踪的外部中间状态

## 放行条件

只有当下面条件成立时，才允许进入 review：

1. 关键 consumer views 已具备可消费完整度
2. 关键资源、字段、状态、权限和错误语义已明确
3. 当前 spec 与 `scope_intake` / `domain_mapping` 一致
4. 没有越过当前 batch 边界
5. 引用关系清楚且稳定

## 常见错误

1. 写成更详细的 `final_prd`
2. 只有资源定义，没有 consumer views
3. 只有页面消费视角，没有资源协议
4. 没说明共享定义来自哪里
5. 让下游仍然需要继续猜字段、状态或权限语义
