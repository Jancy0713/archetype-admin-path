# Contract Scope Intake Rule

## 目标

`scope_intake` 的职责是把单个 ready batch 的上游 handoff 收稳，形成后续 `domain_mapping` 的正式边界输入。

它不是最终 contract，也不是重新做一轮 PRD。

## 核心原则

1. 只消费已确认输入，不重开需求讨论。
2. 只确认当前 batch 的范围，不扩写其他 batch 的内容。
3. 只保留真正阻塞进入 `domain_mapping` 的问题。
4. 必须显式吸收上游 `contract_handoff.do_not_assume`。
5. 如果依赖前序 frozen contract，必须明确指出依赖关系。

## 这一阶段必须说明的内容

至少应明确：

1. 当前 batch 覆盖哪些模块、页面、资源、动作
2. 当前 batch 不覆盖什么
3. 当前 batch 依赖哪些前置 batch 或 frozen contract
4. 当前 batch 当前可继承哪些上游已确认结论
5. 当前 batch 的禁止假设项
6. 当前是否仍有阻塞 `domain_mapping` 的问题

## 这一阶段不能做的事

不允许：

1. 直接展开最终字段协议
2. 直接定义最终查询参数与输入输出结构
3. 把未确认事实写成既定范围
4. 重新引入 `final_prd` 已排除的内容
5. 把别的 batch 的内容提前混入当前 batch

## 放行条件

只有当下面条件成立时，才允许进入 `domain_mapping`：

1. 当前 batch 的范围边界明确
2. 当前 batch 的依赖明确
3. `do_not_assume` 已被吸收
4. 没有遗漏会直接影响资源映射的阻塞问题

## 常见错误

1. 把 `scope_intake` 写成 `contract_spec` 的简化版
2. 只抄 `final_prd` 原文，没有收敛当前 batch 的边界
3. 漏掉前序 batch 依赖
4. `do_not_assume` 没被真正落进当前结论
