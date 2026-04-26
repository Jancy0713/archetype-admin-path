# Contract 结构化产物指南

> Legacy note: 本文中残留的 `freeze` 表达属于旧术语。当前正式单 flow run 以 `contract/release/` 为正式交付层。

## 目标

这份文档用于说明：

1. `contract` 各正式步骤应产出什么类型的结构化产物
2. 每类产物的大区块应该承担什么职责
3. 当前阶段哪些内容先定义到“区块级”，哪些内容暂不下钻到字段级

当前目标不是直接确定模板字段，而是先确定：

- 每一步产物应该长成什么类型
- 这些产物之间如何衔接
- 哪些信息属于哪一步

## 当前正式步骤与产物关系

当前建议的步骤与主产物关系为：

1. `contract-01 scope_intake`
   - 主产物：`scope_intake`
2. `contract-02 domain_mapping`
   - 主产物：`domain_mapping`
3. `contract-03 contract_spec`
   - 主产物：`contract_spec`
4. `contract-04 review`
   - 主产物：`review`
   - 通过后动作产物：`freeze`

这些产物共同构成一个 batch 的完整 `contract run`。

## 产物级总体原则

### 1. 每类产物只承载本步骤职责

不要让：

- `scope_intake` 充当最终 spec
- `domain_mapping` 充当 reviewer 结论
- `contract_spec` 继续承担范围确认
- `review` 反过来重写主体结构

### 2. 越靠后，信息越“硬”

大体上：

- `scope_intake`：确认边界
- `domain_mapping`：组织结构骨架
- `contract_spec`：正式实现协议
- `review/freeze`：正式门禁与冻结状态

### 3. 当前先定区块，不急着定最终字段

当前阶段先做到：

- 每个 artifact 需要哪些主要区块
- 每个区块大概承担什么职责

暂时先不做：

- 每个区块的最终字段命名
- validator schema
- rendered markdown 细节布局

## `scope_intake` 应包含哪些大区块

`scope_intake` 的重点是“确认本批 contract 边界”，因此建议至少包含下面这些区块：

### 1. Meta

负责说明：

- 当前 artifact 身份
- 所属 run
- 对应 batch
- 来源上游文件
- 更新时间和所有者

### 2. Intake Basis

负责说明：

- 本批 intake 基于哪些上游输入
- 当前可直接继承哪些已确认结论
- 当前 intake 使用了哪些 handoff 信息

### 3. Batch Scope

负责说明：

- 当前 batch 覆盖什么
- 当前 batch 不覆盖什么
- 当前 batch 的目标边界在哪里

### 4. Dependencies

负责说明：

- 当前 batch 依赖哪些前置 batch
- 是否已有可引用的 frozen contract
- 哪些依赖若未满足则不能继续

### 5. Do Not Assume

负责沉淀：

- 当前 batch 明确禁止自行假设的内容

### 6. Blocking Items

负责说明：

- 当前还剩哪些真正阻塞进入下一步的问题

### 7. Decision

负责说明：

- 是否允许进入 `domain_mapping`
- 如果不允许，原因是什么

## `domain_mapping` 应包含哪些大区块

`domain_mapping` 的重点是“把 batch 范围映射成结构骨架”，因此建议至少包含下面这些区块：

### 1. Meta

负责说明 artifact 身份、来源和对应 batch。

### 2. Mapping Basis

负责说明：

- 当前 mapping 基于哪些 intake 结论
- 当前引用了哪些上游或前序 frozen contract

### 3. Resource Map

负责说明：

- 本批有哪些资源/实体
- 它们的边界是什么
- 哪些是共享对象，哪些是本批新增

### 4. Action Map

负责说明：

- 本批包含哪些关键动作
- 哪些动作属于页面行为
- 哪些动作属于状态流转或命令性操作

### 5. State And Enum Map

负责说明：

- 本批有哪些状态或枚举
- 哪些状态应在本批定义
- 哪些状态来自共享 contract

### 6. Access Map

负责说明：

- 本批涉及哪些角色/权限边界
- 租户边界如何作用在本批

### 7. Consumer View Map

负责说明：

- 本批要支撑哪些 consumer views
- 哪些资源会被哪些视图消费

### 8. Reference Plan

负责说明：

- 哪些定义需要引用其他 contract
- 哪些引用必须在 `contract_spec` 中被正式落下来

### 9. Decision

负责说明：

- 是否允许进入 `contract_spec`
- 如果不允许，缺口在哪里

## `contract_spec` 应包含哪些大区块

`contract_spec` 是正式实现协议主体，因此建议至少包含下面这些区块：

### 1. Meta

负责说明 artifact 身份、版本、batch、来源与适用范围。

### 2. Spec Scope

负责说明：

- 本份 contract 适用于哪个 batch
- 本份 contract 覆盖哪些模块、页面、资源、动作

### 3. Shared References

负责说明：

- 当前 contract 正式引用了哪些前序 frozen contract
- 哪些共享定义不在本批重复展开

### 4. Resource Contracts

负责说明：

- 每个核心资源的正式协议
- 资源的字段、语义、状态、约束、引用关系

### 5. Consumer Views

负责说明：

- 列表、详情、编辑、动作、状态变化等视图层消费面
- 每种 view 依赖哪些资源和哪些字段语义

### 6. Query And Command Semantics

负责说明：

- 查询、筛选、排序、分页、搜索等输入语义
- 创建、编辑、状态变更等动作语义

### 7. Access And Tenant Rules

负责说明：

- 权限边界
- 租户隔离规则
- 哪些 view 或动作受哪些规则影响

### 8. Validation And Error Semantics

负责说明：

- 关键校验规则
- 常见错误或冲突场景
- 禁用条件、空态、失败态等实现必须显式处理的语义

### 9. Implementation Notes For Consumers

负责说明：

- 对前端、后端、脚本消费最关键的补充说明
- 但不写成任务计划

### 10. Decision

负责说明：

- 当前 spec 是否允许进入 review

## `review` 应包含哪些大区块

`review` 的重点是“独立判断这份 contract 是否可放行”，因此建议至少包含下面这些区块：

### 1. Meta

负责说明 reviewer 身份、被审对象、时间、来源。

### 2. Findings

负责说明：

- 识别到的问题
- 是否存在阻塞项
- 哪些问题必须在 freeze 前修复

### 3. Coverage Check

负责说明：

- 是否覆盖了本批要求的 consumer views
- 是否与上游 handoff 一致
- 是否遗漏关键结构块

### 4. Boundary Check

负责说明：

- 是否越界
- 是否引入未确认假设
- 是否错误重定义共享对象

### 5. Decision

负责说明：

- 是否允许 freeze
- 如果不允许，必须返工到哪一步

## `freeze` 应包含哪些大区块

`freeze` 的重点是“声明当前 batch contract 已成为正式可引用版本”，因此建议至少包含下面这些区块：

### 1. Meta

负责说明冻结对象身份、所属 batch、所属 run、对应 `contract_id`、时间和责任人。

### 2. Frozen Inputs

负责说明：

- 本次 freeze 基于哪些正式输入
- 包括哪些上游 artifact 与 reviewer 结论

### 3. Frozen Outputs

负责说明：

- 当前冻结的是哪份正式 contract
- 对应 rendered views 或派生产物有哪些

### 4. Dependency Snapshot

负责说明：

- 当前 freeze 时依赖了哪些前序 frozen contracts

### 5. Consumption Status

负责说明：

- 当前版本是否允许被后续 batch 或 generation 消费

## 不同产物之间的关系

推荐关系是：

```text
scope_intake
-> domain_mapping
-> contract_spec
-> review
-> freeze
```

其中：

- `scope_intake` 定边界
- `domain_mapping` 定骨架
- `contract_spec` 定正式协议
- `review` 做独立门禁
- `freeze` 作为 `review` 通过后的冻结动作，宣布正式可消费

## 当前阶段先不展开的内容

这份文档当前只定义产物的大区块，不展开：

- 具体字段名
- 字段级 schema
- validator 规则细节
- rendered markdown 章节格式

这些内容应在当前区块级设计稳定后再继续推进。

## 与后续文档的关系

建议结合下面文档一起看：

1. [Contract README](/Users/wangwenjie/project/archetype-admin-path/docs/contract/README.md)
2. [Contract Workflow Guide](/Users/wangwenjie/project/archetype-admin-path/docs/contract/WORKFLOW_GUIDE.md)
3. [Contract 步骤说明](/Users/wangwenjie/project/archetype-admin-path/docs/contract/steps/README.md)
