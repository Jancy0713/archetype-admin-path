# Multi Generation Entry Workplan

这份文档用于指导下一上下文中的 AI，在 `03.0` 已完成后，进入 `03.5`：把 `contract => generation` 从“聚合进入一个 generation”修正为“批量创建多个 generation 起点”。

注意：

- 这不是推翻 `03.0`
- `03.0` 已完成的结构收口、历史降级、桥接脚本抓手继续保留
- `03.5` 只负责修正方向错误和补齐用户真正需要的 generation 入口
- 本轮仍不是 generation 内部开发

## 当前已确认新方向

1. `prd` 的核心价值之一，是把大需求拆成多个可独立推进的 contract。
2. `contract` publish 完成后，不应该再等“全部 contract 聚合成一个 generation”才开始。
3. 更合理的方式是：一个 published contract 对应一个 generation 起点。
4. 系统应一次性为用户准备多个 generation 起点，而不是只准备一个总 generation。
5. 用户可以根据业务优先级、自身判断或 AI 推荐，选择先做哪个 generation。
6. 如果 contract 之间有依赖关系，必须明确说明。
7. 如果 contract 之间是平行关系，也必须明确说明。
8. generation 起点应自动带上初始化材料，而不是让用户自己再补 request。

## 本轮总目标

把 `contract => generation` 正式修正为下面这件事：

- 检查哪些 contract 已 publish
- 按 contract 批量创建多个 generation 起点
- 为每个 generation 起点自动准备初始化输入
- 再给用户一份总览，帮助用户决定下一步先执行哪个

## 本轮应完成

### Phase 3.5A: Direction Correction

status: completed

目标：

- 把所有仍写着“聚合全部 contracts 到一个 generation”的正式文档口径纠正

应完成：

- 更新 generation 总体方向文档
- 更新 `contract => generation` 相关文档的正式口径
- 明确 `03.0` 是阶段性结果，不再继续扩写旧聚合方案

### Phase 3.5B: Generation Entry Design

status: completed

目标：

- 定清楚“一个 published contract 对应一个 generation 起点”到底要产出什么

应完成：

- 明确 generation 起点目录结构
- 明确是否保留 `request.md`
- 明确 contract 输入材料如何注入 generation 起点
- 明确每个 generation 起点的说明文档应包含什么
- 明确用户总览文档应包含什么

### Phase 3.5C: Entry Creation Workflow

status: completed

目标：

- 定清楚“批量创建多个 generation 起点”的正式执行步骤

应完成：

- 明确触发条件
- 明确输入来源
- 明确生成哪些 generation 起点
- 明确推荐顺序、依赖关系、平行关系如何写给用户
- 明确下一轮代码实现应该补哪些脚本

## 本轮完成标准

完成后，下一轮不需要再回聊天记录猜：

1. generation 起点到底是一个还是多个
2. `request.md` 是否要自动生成
3. contract 输入材料是否要自动注入
4. 用户总览文档需要写什么

## 本轮已落地

- [03_5_MULTI_GENERATION_ENTRY_DEFINITION.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/generation/03_5_MULTI_GENERATION_ENTRY_DEFINITION.md)
- 更新 [03_CONTRACT_TO_GENERATION_BRIDGE_DEFINITION.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/generation/03_CONTRACT_TO_GENERATION_BRIDGE_DEFINITION.md) 的当前口径指向
- 更新 [contracts/README.md](/Users/wangwenjie/project/archetype-admin-path/contracts/README.md) 与 [docs/contract/WORKFLOW_GUIDE.md](/Users/wangwenjie/project/archetype-admin-path/docs/contract/WORKFLOW_GUIDE.md) 的正式使用说明

## 当前边界

本轮不应直接展开：

- generation 内部后端接口定义生成器
- generation 内部前端代码生成器
- generation 测试执行器
- generation GUI

## 下一步顺序

`03.5` 完成后，后续才能进入：

1. `03.6` 旧资产直接收敛
2. `04` runs/examples 对齐
3. `05` 主链验证
4. generation 内部开发

## 执行日志

### 2026-04-24

- 完成 `Phase 3.5A: Direction Correction`
  - 把当前正式口径收敛为“批量创建多个 generation 起点”
  - 明确 `03.0` 的聚合方案只保留为历史阶段性结果
- 完成 `Phase 3.5B: Generation Entry Design`
  - 定稿 generation entry 正式目录结构
  - 定稿 `request.md` 自动生成规则
  - 定稿 contract 输入材料注入规则
  - 定稿单个 entry 的 `README.md` 与总览文档要求
- 完成 `Phase 3.5C: Entry Creation Workflow`
  - 定稿批量扫描 published contracts -> 创建 entries -> 生成 overview 的正式 workflow
  - 明确依赖关系、平行关系和推荐顺序的写法
  - 为下一轮代码实现补出正式依据，但当前停在文档定稿
