# Contract Domain Mapping Rule

## 目标

`domain_mapping` 的职责是把当前 batch 的范围映射成后续 `contract_spec` 可直接消费的结构骨架。

它的重点不是写最终协议，而是把：

- 资源
- 动作
- 状态
- 权限
- 视图消费面
- 跨模块依赖

之间的关系理顺。

## 核心原则

1. 先定结构骨架，再写最终协议。
2. 只映射当前 batch 范围内的资源和动作。
3. 能复用前序 frozen contract 的，不重复定义。
4. 必须显式标出共享定义和新增定义的边界。
5. 必须显式标出当前 batch 要支撑的 consumer views。

## 这一阶段必须说明的内容

至少应明确：

1. 当前 batch 的核心资源/实体有哪些
2. 每个资源参与哪些页面或动作
3. 哪些状态和枚举由本批定义
4. 哪些状态和枚举来自共享 contract
5. 哪些权限与租户边界在本批生效
6. 哪些 consumer views 是本批必须支撑的
7. 哪些引用依赖必须在 `contract_spec` 中正式落下

## 这一阶段不能做的事

不允许：

1. 直接把最终字段协议写满
2. 把最终 DTO/接口结构提前当成 mapping 主体
3. 不区分共享定义和新增定义
4. 漏掉关键 consumer views
5. 不标注跨模块依赖就直接往下写 spec

## 放行条件

只有当下面条件成立时，才允许进入 `contract_spec`：

1. 当前 batch 的资源和动作边界清楚
2. 当前 batch 的 consumer views 基本清楚
3. 共享定义与新增定义边界清楚
4. 关键依赖引用已被标记
5. 没有把最终 spec 细节提前混写成 mapping 主体

## 常见错误

1. 把 `domain_mapping` 写成字段级 spec 草稿
2. 资源、动作、状态三者关系没有拉清楚
3. 没明确哪些内容引用前序 contract
4. consumer views 只字带过，无法支撑后续正式 spec
