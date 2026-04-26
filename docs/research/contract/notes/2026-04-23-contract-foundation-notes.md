# Contract Foundation Notes

日期：2026-04-23

## 当前共识

- 现在先不做具体业务 `contract` 开发，先定义“`contract` 是什么”
- `final_prd` 产出的 batch 顺序，只能作为某次需求的 handoff 结果，不能反过来定义 `contract` 正式流程
- 我们要建设的是一套独立、标准化、可复用的 `contract` 流程
- `final_prd` 在这套流程中的角色，是 `contract` 的上游输入，而不是 `contract` 本身

## 当前目标定义

我们希望最终形成的 `contract` 是：

- 前端拿到后，可以直接开始页面、表单、列表、状态、权限等实现
- 后端拿到后，可以直接定义接口、字段、DTO、校验和权限边界
- AI 或脚本拿到后，可以稳定生成类型、mock、页面骨架、后端输入建议
- 消费方不需要再回头猜字段、状态、权限、租户边界或模块关系

换句话说，`contract` 应该成为：

- 可执行的实现真相源
- 比 PRD 更硬、更明确的结构化输入
- 前后端和 AI 的共同语言层

## 当前边界判断

`contract` 不是：

- PRD 的自然语言重写
- Swagger 的简单镜像
- 只面向接口设计的 API 文档
- 一次性生成后就不再维护的中间文件

`contract` 应该：

- 跟随项目长期演进
- 在需求变更时成为优先修改对象之一
- 能被定位、引用、追踪和联动修改

## 当前倾向

- 颗粒度初步倾向按“模块”拆分
- 这和后端常见的按功能模块拆 Swagger 的方式接近，比较符合工程直觉
- 但模块之间不可避免存在资源、字段、状态和数据依赖
- 因此未来需要一套标准化引用/查找逻辑，让一个模块的 `contract` 可以稳定引用另一个模块的定义

当前结论：

- 颗粒度先不拍死
- 先完成外部仓库调研，再回头决定正式拆分方式

## 本轮调研任务

需要分别研读下面两个仓库，并站在它们的现有架构和工作流之上，反推我们自己的 `contract` 体系该怎么设计：

1. `obra/superpowers`
2. `affaan-m/everything-claude-code`

调研目标不是简单总结仓库内容，而是回答：

- 它们如何组织 agent / skill / workflow / review / automation
- 哪些结构适合迁移到我们的 `contract` 流程
- 哪些能力可以直接借鉴
- 哪些地方不适合直接照搬
- 在我们的 `init -> prd -> contract -> generation` 主链路里，`contract` 应该如何落位

## 后续产出要求

- 每个外部仓库单独研究一次
- 每次研究只聚焦一个仓库
- 每次研究都输出到固定目录
- 输出结果必须是“可指导下一步设计”的方案草案，而不是泛泛的读后感

## 调研后的共同结论

基于：

- [superpowers-contract-research.md](/Users/wangwenjie/project/archetype-admin-path/docs/research/contract/findings/superpowers-contract-research.md)
- [everything-claude-code-contract-research.md](/Users/wangwenjie/project/archetype-admin-path/docs/research/contract/findings/everything-claude-code-contract-research.md)

当前已经出现的稳定共识：

### 1. `contract` 应该成为独立正式系统，而不是 `final_prd` 的附录

- `final_prd` 继续负责业务范围、批次、约束、handoff 和是否允许进入 `contract`
- `contract` 负责把单个 batch 收敛成实现可消费的结构化协议
- 因此 `final_prd` 是 `contract` 的上游输入索引，不是 `contract` 本身

### 2. `contract` 不应是一篇总文档，而应是一套分层结构

调研后更倾向采用的最小分层：

- `rules/`
- `templates/`
- `steps/`
- `prompts/`
- `reviewer/`
- `scripts/`

当前结论：

- 这套分层已经足够作为 MVP 方向
- 暂时不需要引入更重的 hook、插件装配、多 agent 并行编排

### 3. `contract` 的职责已经比 PRD 更清楚

应进入 `contract` 的内容：

- 资源/实体定义
- 字段语义与约束
- 查询/列表/详情/编辑/动作视图
- 状态机与枚举
- 权限与租户边界
- 错误语义与关键校验约束
- 跨模块引用和依赖

不应进入 `contract` 的内容：

- 宏观业务背景说明
- 范围讨论和澄清过程
- 宏观执行计划
- step-by-step coding checklist

### 4. `contract` 也应该继承正式 reviewer / freeze gate

- 不应写完就直接进入 generation
- 必须有独立 reviewer
- 必须有 freeze 或等价的正式通过元数据
- 下游消费应只读取 frozen contract

### 5. `contract` 需要过程态和冻结态分离

当前更合理的系统形态是：

- `runs/...` 存过程态
- `contracts/...` 存冻结态
- `generated/...` 或 contract 内 generated 子目录存派生产物

### 6. 颗粒度暂时仍倾向按模块，但必须配套标准引用机制

- “按模块拆”仍然是当前最符合工程直觉的倾向
- 但模块之间的共享资源、枚举、动作、字段定义，必须能被稳定引用
- 因此将来需要：
  - `module_id`
  - `version`
  - `depends_on_modules`
  - `type_ref / enum_ref / action_ref`
  - `lookup` 脚本或等价索引机制

## 当前更像下一轮设计输入的问题

现在已经不太需要继续争论“要不要做 contract 系统”，而是要回答下面这些设计问题：

1. `contract workflow` 的正式步骤编号和门禁怎么定义
2. `contract_spec` 的最小字段分区怎么设计
3. `runs/` 过程态和 `contracts/` 冻结态的目录关系怎么定
4. `required_contract_views` 和未来正式 `consumer_views` 如何对齐
5. 第一版是否同时覆盖前端视图层字段和后端接口层字段

## 已确认的流程定位

### 1. 对外主流程仍然保持为 `init + prd`

- 用户不需要决定自己是走 `prd` 还是走 `contract`
- 用户给出的原始需求、简要 PRD、附件、上下文，统一先进入我们的 `prd` 流程
- `contract` 不是用户直接触发的独立入口

### 2. 系统内部真实主链路是 `init -> prd -> contract`

- `prd` 的正式目标不再只是产出 `final_prd`
- `prd` 的正式目标是产出“可进入 `contract` 的正式输入索引”
- 只有当 `final_prd` 通过门禁后，系统内部才进入 `contract`

### 3. `final_prd` 仍然是 `contract` 的正式上游输入

- `final_prd` 负责：
  - 范围收敛
  - 角色、资源、流程、约束汇总
  - ready batches
  - recommended batch order
  - batch handoff
  - 是否允许进入 `contract`
- `contract` 负责：
  - 把某个 ready batch 压成实现可消费的结构化真相源

### 4. 不允许用户拿原始 PRD 直接进入 `contract`

原因：

- 原始 PRD 通常还没完成澄清、收敛、阻塞清理、batch 划分和 handoff 边界定义
- `contract` 默认消费的是已确认输入，而不是原始需求文本

### 5. `contract` 应按 batch 启动独立 run / 上下文

- 不建议在同一个长上下文里连续完成多个 contract batch
- 当 `final_prd` 存在多个 ready batches 时，应按 batch 启动独立 `contract run`
- 每个 batch 都有自己完整的 `scope_intake -> domain_mapping -> contract_spec -> review_and_freeze`

### 6. batch 的执行方式默认应是“单批从头到尾”

当前更合理的执行原则：

- 一个 batch 进入 `contract` 后，应从头到尾完成本批的完整流程
- 已冻结的前序 batch 可以作为后续 batch 的正式输入参考
- 不建议采用“batch-01 做完 step1，再 batch-02 做完 step1，再 batch-03 做完 step1”这种横切推进方式

原因：

- 横切推进会让上下文、review、依赖和冻结状态都变得更难管理
- 纵向完成单批更符合“先形成可信真相源，再供下游或后续 batch 复用”的原则

### 7. 并行只在依赖允许且前序 batch 已冻结后才成立

- 如果某些 batch 依赖前置 batch 的共享资源/状态/引用定义，就必须等前置 batch freeze 后再启动
- 如果两个 batch 的依赖都已经满足，则可以并行
- 但并行的前提仍然是“一个 batch 一个独立上下文 / 独立 run”

## 用户侧交付原则

### 1. 用户入口仍然停留在 `final_prd`

- 用户完成并确认 `final_prd` 后，系统再进入 `contract` 启动阶段
- 用户不需要自己理解 `contract` 内部步骤编号、目录结构或脚本细节

### 2. `final_prd` 输出时，应同时生成全部 batch 的启动提示词

- 如果 `final_prd` 中有 `x` 个 ready batches，就在内部一次性生成 `x` 份 batch 启动提示词
- 每份提示词对应一个独立 batch 的 `contract run`
- 提示词文件应写入固定路径，便于后续按顺序取用

### 3. 但用户侧只按顺序暴露当前这一轮要执行的提示词

- 即使后台已经生成了全部 batch 的提示词，也不要一次性把 3 份提示词都告诉用户
- 当前轮次只告诉用户：
  - 本次 PRD 一共拆成多少个 batch
  - 当前应该执行哪一轮
  - 当前提示词文件路径是什么
  - 不要跳过顺序提前执行后续 batch

### 4. 用户侧建议话术

应表达为：

- 如果你要继续调整需求或边界，我们先回到 `final_prd`
- 如果你确认当前 `final_prd`，可以直接使用当前这一轮的 batch 启动提示词
- 当前 batch 完成并经过确认后，再给出下一轮 batch 的提示词路径

不应表达为：

- 让用户自己从多个 batch 提示词中任选
- 一次性把所有后续批次都抛给用户自己判断顺序
- 让用户自己推断前后依赖和是否可以提前做

### 5. 当前倾向的交付行为

假设 `final_prd` 产出 3 个 ready batches：

- 系统内部生成：
  - batch-01 启动提示词
  - batch-02 启动提示词
  - batch-03 启动提示词
- 但用户当前只看到：
  - “本次一共拆成 3 轮”
  - “请先执行第 1 轮”
  - “当前提示词路径：xxx”
  - “请不要提前执行第 2/3 轮；第 1 轮完成并确认后再继续”

### 6. 这样设计的原因

- 降低用户心智负担
- 避免用户跳过依赖顺序
- 保持每个 batch 的 review / freeze / handoff 边界清晰
- 让前序 batch 的正式冻结结果可以自然成为后续 batch 的输入参考

相关草案：

- [Final PRD To Contract Prompt Handoff Draft](/Users/wangwenjie/project/archetype-admin-path/docs/research/contract/FINAL_PRD_TO_CONTRACT_PROMPT_HANDOFF_DRAFT.md)
