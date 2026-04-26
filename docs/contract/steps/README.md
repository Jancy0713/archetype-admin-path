# Contract 步骤说明

这个目录用于说明 `contract` 正式流程中的每一步负责什么、输入输出是什么、重点要写什么、什么不能写，以及进入下一步前的完成标准。

当前建议的 `contract` MVP 正式步骤为：

1. `contract-01 scope_intake`
2. `contract-02 domain_mapping`
3. `contract-03 contract_spec`
4. `contract-04 review`

## 步骤入口

1. [scope_intake](/Users/wangwenjie/project/archetype-admin-path/docs/contract/steps/scope_intake.md)
2. [domain_mapping](/Users/wangwenjie/project/archetype-admin-path/docs/contract/steps/domain_mapping.md)
3. [contract_spec](/Users/wangwenjie/project/archetype-admin-path/docs/contract/steps/contract_spec.md)
4. [review](/Users/wangwenjie/project/archetype-admin-path/docs/contract/steps/review.md)

- 一个 flow 从 step 1 走到 step 4
- 每个 flow 都运行在独立、标准的 Run 工作区中
- 人类启动材料为 `prompts/run-agent-prompt.md`，而不是直接将 YAML 交给 AI
- 当前正式入口来自 Handoff 快照，不再引用整份 `final_prd`

## 总体原则

### 1. 每一步只承担一种主要职责

不要把：

- 输入边界确认
- 资源映射
- 最终实现协议
- review/release gate

混在同一步里一次性完成。

### 2. 每一步都应服务于下一步

也就是说：

- `scope_intake` 要足够稳定，才能做 `domain_mapping`
- `domain_mapping` 要足够清晰，才能写 `contract_spec`
- `contract_spec` 要足够完整，才能进入 `review`

### 3. 不在早期步骤过早写最终细节

例如：

- `scope_intake` 不直接展开完整字段协议
- `domain_mapping` 不直接充当最终 contract
- `review` 不重写主体内容

## Step 1: `contract-01 scope_intake`

### 目标

接收单个 ready flow 的 handoff，并明确本 flow 进入 `contract` 的正式范围、依赖和禁止越界项。

这一步的核心作用是：

- 先把“本批到底在做什么”钉住
- 防止后续步骤在理解边界时漂移

### 输入

至少应包含：

- `intake/contract-handoff.snapshot.yaml`
- `intake/contract-handoff.snapshot.md`
- `prompts/run-agent-prompt.md` (作为上下文启动依据)
- 必要时引用：
  - `raw/attachments/` (上游快照)

### 这一阶段重点要写什么

重点应包括：

- 当前 flow 的目标范围
- 当前 flow 覆盖哪些模块/页面/资源
- 当前 flow 依赖哪些前置 flows
- 当前 flow 明确不能假设什么
- 当前 flow 当前可使用哪些上游已确认结论
- 当前 flow 还剩哪些真正阻塞 `contract` 的问题

### 这一阶段不应该写什么

不应在这一步写：

- 完整字段定义
- 列表/详情/编辑的最终结构协议
- 具体接口输入输出形状
- 最终错误语义表
- 最终资源引用模型

### 这一阶段要达到什么效果

达到的效果应是：

- 后续 agent 或 reviewer 不需要再猜“这批到底做不做某块内容”
- 本批的边界、依赖、禁止假设项已经稳定
- 后续可以在明确边界内做资源和视图映射

### 完成标准

进入下一步前，至少应满足：

- 当前 flow 范围明确
- 当前 flow 的依赖明确
- `do_not_assume` 已被吸收进本步结果
- 没有把未确认事实写成既定范围
- 没有遗漏会直接影响 `domain_mapping` 的阻塞问题

## Step 2: `contract-02 domain_mapping`

### 目标

把当前 batch 的范围映射为：

- 资源
- 动作
- 状态
- 角色/权限点
- 租户边界
- 跨模块依赖
- 视图消费面

这一步的核心作用是：

- 在写最终 contract 之前，先把“结构骨架”理顺

### 输入

至少应包含：

- `contract-01 scope_intake` 结果
- `final_prd` 中与本 batch 相关的资源、页面、流程、约束
- 如有需要，前序已冻结 batch 的 contract 引用

### 这一阶段重点要写什么

重点应包括：

- 本批有哪些核心资源/实体
- 每个资源参与哪些页面或动作
- 哪些状态和枚举需要在本批定义
- 哪些权限边界在本批生效
- 哪些共享对象应复用前序 contract
- 哪些内容属于本批新增定义
- 本批要支撑哪些 consumer views

### 这一阶段不应该写什么

不应在这一步写：

- 最终逐字段协议
- 完整查询参数细则
- 最终 DTO/接口字段表
- 完整错误码或错误语义细目
- 完整 UI 配置级结构

### 这一阶段要达到什么效果

达到的效果应是：

- 本批的资源结构和关系图已经清楚
- 后续写 `contract_spec` 时不再反复重判资源边界
- 哪些内容需要引用其他 contract，哪些内容由本批定义，已经足够明确

### 完成标准

进入下一步前，至少应满足：

- 资源和动作边界清楚
- consumer views 基本清楚
- 共享定义与新增定义边界清楚
- 关键跨模块依赖已经标记
- 没有把最终 spec 细节提前混写进来

## Step 3: `contract-03 contract_spec`

### 目标

产出当前 batch 的正式 `contract artifact`。

这是后续前端、后端、AI 和脚本消费的正式真相源。

### 输入

至少应包含：

- `contract-01 scope_intake` 结果
- `contract-02 domain_mapping` 结果
- 必要的前序 frozen contracts

### 这一阶段重点要写什么

这一阶段是正式主体，应重点覆盖：

- 模块/资源边界
- 字段及字段语义
- 查询、筛选、排序、分页、搜索等视图输入
- 列表、详情、编辑、动作相关 consumer views
- 状态机与枚举约束
- 权限与租户边界
- 错误语义与关键校验约束
- 与前序 contract 的引用关系

### 这一阶段不应该写什么

不应在这一步写：

- 新的需求澄清题
- 宏观产品背景说明
- 长篇自然语言 PRD 叙述
- step-by-step 实现任务清单

### 这一阶段要达到什么效果

达到的效果应是：

- 前端拿到后，不再猜页面所需数据结构和约束
- 后端拿到后，不再猜资源动作边界和主要字段方向
- AI / 脚本拿到后，不再猜生成输入和依赖关系

### 完成标准

进入下一步前，至少应满足：

- 当前 batch 的核心 consumer views 已有正式协议
- 关键资源/字段/状态/权限/错误边界已具备消费完整度
- 与前序 contract 的引用关系明确
- 未越过 `scope_intake` 已确认边界
- 没有把“待确认事项”伪装成正式定义

## Step 4: `contract-04 review`

### 目标

对当前 flow 的 `contract_spec` 做独立 review，并在通过后触发 release 包生成，使其成为正式可消费版本。

### 输入

至少应包含：

- `contract-03 contract_spec`
- 上游 `scope_intake`
- 上游 `domain_mapping`
- `intake/contract-handoff.snapshot.yaml`
- 如有需要，相关前序 release contracts

### 这一阶段重点要检查什么

重点应检查：

- 是否越出当前 flow 范围
- 是否引入未确认假设
- 是否遗漏关键 consumer views
- 是否存在命名漂移
- 是否重复定义已存在共享对象
- 是否存在跨模块引用不清
- 是否已经足够供下游消费

### 这一阶段不应该做什么

不应在这一步：

- 大规模重写 contract 主体
- 重新打开需求澄清流程
- 在未 review 的情况下直接宣布可供下游正式消费

### 这一阶段要达到什么效果

达到的效果应是：

- 当前 flow 的 contract 已经成为可信正式输入
- 后续 release 消费方可以稳定引用
- 当前版本进入可追踪、可复用、可回溯状态

### 完成标准

通过 review 并生成 release 前，至少应满足：

- reviewer 没有识别 blocking issues
- 当前 contract 足够支撑下游消费
- 当前 contract 与上游 handoff 一致
- 当前 contract 的依赖引用是稳定的
- 已形成正式 release 包

## 步骤之间的关系

默认顺序是：

```text
scope_intake
-> domain_mapping
-> contract_spec
-> review
-> release
```

如果某一步发现问题，应优先回退到最近的合理上游步骤，而不是在当前步骤硬补所有问题。

例如：

- 如果发现 flow 边界不清，应回到 `scope_intake`
- 如果发现资源归属不清，应回到 `domain_mapping`
- 如果只是字段表达不完整，可在 `contract_spec` 内修订

## 当前阶段先不展开的内容

这份文档当前只定义步骤职责，不展开：

- 具体模板字段
- 具体脚本命令
- 具体 reviewer YAML 结构
- 具体 rendered markdown 样式

这些内容应在步骤职责稳定后再继续补齐。
