# PRD 2.1.0 范围定义

## 目标

这份文档用于定义 `PRD 2.1.0` 的完整范围，供新的上下文直接继续开发。

当前对 `2.1.0` 的定位不是“小修小补”，而是：

- 在 `2.0.0` 已完成主链路重构的基础上
- 继续把整套 PRD 流程补到“完整可测版本”
- 然后再统一做首轮真实验证

也就是说，`2.1.0` 的目标不是先测试，而是先把“应该做完的能力和结构治理”做完整。

## 当前前提

当前 `2.0.0` 已完成：

1. 主流程已切到四步：
   - `analysis`
   - `clarification`
   - `execution_plan`
   - `final_prd`
2. 主模板、主脚本、主文档、`create_run` 都已切换到新四步流程
3. reviewer 已明确要求独立 reviewer 子 agent / 独立上下文执行
4. 旧 `runs/` 暂不改写，作为历史产物保留

参考：

- [PRD_WORKFLOW_V2_PLAN.md](/Users/wangwenjie/project/archetype-admin-path/docs/prd/PRD_WORKFLOW_V2_PLAN.md)
- [PRD_2_0_VALIDATION_PREP.md](/Users/wangwenjie/project/archetype-admin-path/docs/prd/PRD_2_0_VALIDATION_PREP.md)

## 2.1.0 目标定义

`2.1.0` 需要完成两大类事情：

1. 把当前 PRD 主链路补到“完整可测”
2. 从前期就把目录、提示词、脚本、reviewer、步骤资料拆清楚，避免像 `init` 后期那样文件越来越乱、维护成本越来越高

## 一、完整可测范围

### 1. analysis 关口补强

要补的内容：

- 让 `analysis` 的输出更稳定地覆盖：
  - 输入摘要
  - 范围边界
  - 模块拆分
  - 页面 / 资源 / 流程初视图
  - 风险与阻塞缺口
  - 澄清候选
- 补明确的 reviewer 检查项，避免 reviewer 只做泛审查
- 让渲染视图更适合人工快速通读，而不是只把 YAML 平铺出来

完成标准：

- `analysis` 产物能稳定作为 `clarification` 的唯一上游输入

### 2. clarification + Human Confirmation Gate 补强

要补的内容：

- `confirmation_items` 的题型和渲染体验继续收敛
- 明确哪些问题必须进入 human gate，哪些不应该打扰用户
- 让 Human Confirmation Gate 的对话输出格式固定下来
- 让人工确认结果更容易回写到结构化产物

完成标准：

- `clarification` 之后的人机确认体验稳定，不需要每次临时解释怎么确认

### 3. execution_plan 补强

要补的内容：

- 提升计划排序的稳定性
- 让依赖关系、并行关系、contract 优先级表达更清楚
- reviewer 对“计划是否合理”的专项检查项补齐

完成标准：

- `execution_plan` 不是形式步骤，而是真的能指导下游推进顺序

### 4. final_prd -> contract handoff 补强

要补的内容：

- 明确 `final_prd` 必须具备哪些字段，才算能交给 contract
- 把 ready batch 的 `contract_handoff` 字段边界再收紧
- 明确“contract 阶段允许假设什么、不允许假设什么”

完成标准：

- `final_prd` 成为当前进入 contract 的唯一可信输入索引，并支持多 batch handoff

### 5. reviewer 体系补强

要补的内容：

- 每个阶段增加专项 reviewer 检查项
- 明确 reviewer 输入组织方式
- 明确 reviewer 输出如何驱动返工
- 保证 reviewer 独立执行规则不只停留在文档层

完成标准：

- reviewer 真正成为门禁，而不是形式步骤

### 6. run 执行体验补强

要补的内容：

- `create_run` 生成出来的提示词、进度板、首产物、渲染路径进一步打磨
- 明确首轮验证时 run 内各文件应如何配合
- 为真实验证前准备更直接的执行说明

完成标准：

- 新开一个 PRD run 时，不需要额外猜流程怎么跑

## 二、结构治理范围

这一块必须明确纳入 `2.1.0`，不是附带优化。

原因：

- 我们在 `init` 后期已经看到，文件一旦混在一起，后面会很难维护
- `prd` 现在刚切新主链路，正是最适合把结构拆清楚的时候
- 如果现在不做，后面 prompt、脚本、reviewer、步骤材料会再次堆成大文件

### 1. 提示词分拆

原则：

- 不把所有 PRD 提示词都继续堆在少数几个大文件里
- 按步骤拆开
- 按角色拆开
- 按用途拆开

目标结构建议：

- 主流程总入口
- `analysis` 专用 prompt
- `clarification` 专用 prompt
- `execution_plan` 专用 prompt
- `final_prd` 专用 prompt
- reviewer 通用 prompt
- 必要时的阶段 reviewer 补充说明

完成标准：

- 新人只看文件名就知道哪个 prompt 属于哪一步

### 2. 规则文档分拆

原则：

- 每个步骤有自己的规则文档
- reviewer 规则和主模型规则分开
- 不把“执行顺序”“字段协议”“审查要求”混写在一个大文件里

完成标准：

- 规则分工清晰，后续改单步逻辑时不需要在大文档里到处找

### 3. 脚本职责分拆

原则：

- 初始化、校验、渲染、辅助逻辑分层
- 不在单个脚本里继续堆太多跨步骤条件
- 能拆成按阶段处理的辅助逻辑，就尽早拆

方向：

- `artifact_utils.rb` 仍然可以作为 schema 中心
- 但后续若继续膨胀，应考虑按步骤拆 schema 或辅助校验逻辑
- render 逻辑如继续增长，也要准备按阶段拆分

完成标准：

- 脚本结构清楚，后续继续演进时不容易失控

### 4. reviewer 资料分拆

原则：

- reviewer 通用约束一份
- 各步骤专项检查项单独表达
- 不把所有阶段检查项混在一个 reviewer 文件里

完成标准：

- reviewer 演化时不会把单文件越改越大

### 5. 步骤资料分拆

原则：

- 每一步的“模板 / prompt / 规则 / checklist / reviewer 关注点”最好能形成同组入口
- 不要让步骤材料散落到多个目录后失去对应关系

建议方向：

- 至少在文档索引层体现出“按步骤分组”
- 必要时把 prompts 和 rules 做分组索引

完成标准：

- 维护者能从步骤视角快速找到对应材料

## 三、2.1.0 不做的事

下面这些不纳入 `2.1.0`：

1. 旧 `runs/` 的迁移和批量清理
2. 外部 `skill` 的重型编排层接入
3. 更重的 debate / 多模型对抗机制
4. 超出当前 PRD 主链路的自动化扩展

补充说明：

- `2.1.0` 允许继续使用 `to-prd` 这类已收口边界的辅助 skill
- 但只允许把它们当作步骤内参考器，不允许替代当前 YAML 协议和 reviewer / handoff 机制

这些留到后续版本处理。

## 四、2.1.0 完成标准

只有当下面条件同时满足，才算 `2.1.0` 做完：

1. PRD 四步主链路补到“完整可测”
2. Human Confirmation Gate 体验稳定
3. `final_prd -> contract` handoff 足够明确
4. reviewer 体系具备阶段专项检查项
5. 提示词 / 规则 / reviewer / 步骤资料已经明显拆开，不再继续朝“大杂烩文件”方向发展
6. 然后才进入统一首轮真实测试

## 五、新上下文建议起手顺序

新的上下文建议按下面顺序继续：

1. 先读本文件
2. 再读 [PRD_WORKFLOW_V2_PLAN.md](/Users/wangwenjie/project/archetype-admin-path/docs/prd/PRD_WORKFLOW_V2_PLAN.md)
3. 再读 [PRD_2_0_VALIDATION_PREP.md](/Users/wangwenjie/project/archetype-admin-path/docs/prd/PRD_2_0_VALIDATION_PREP.md)
4. 先做结构治理设计：确定 prompts / rules / reviewer / step materials 的拆分方案
5. 再补四步主链路的剩余缺口
6. 全部做完后，再统一做首轮真实验证
