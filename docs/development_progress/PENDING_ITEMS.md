# 待定与后续补充

这个文档只记录“用户明确说先放一下、后面再优化”的事项。

原则：

- 只记录明确延后的优化方向
- 不记录下一步马上要做的工作
- 不记录已经落地的结构、脚本或文档拆分
- 每项只保留一句话级别的后续方向

## Init Flow

- 继续观察初始化输入表单的真实填写成本，必要时再补更强的引导示例和默认提示。
- 补充初始化阶段的常见问题库与推荐选项参考，但保持题目仍以结构化确认为主。
- 补强 baseline 变更追踪，后续再统一收敛 `change_request` 对字段来源、影响范围和 diff 的表达。

## PRD Flow

- 基于真实 run 继续收口 `analysis -> clarification -> execution_plan -> final_prd` 的稳定性和推进体验。
- 继续优化 Human Confirmation Gate 与 `rendered/*.md` 的可读性，让人更快完成确认和通读。
- 补充更通用的需求澄清题库与高频问题模式，但不破坏现有结构化协议。
- 持续验证 `final_prd -> contract` 的交接体验，后续再补更完整的样例和执行指引。
- 评估外部 skill 在 PRD 流程中的辅助接入方式，但只作为增强，不替代现有主协议。

## Contract Flow

- 后续再补更完整的 schema 级 validator 覆盖，但本轮先优先收紧关键 cross-field 约束。
- 后续再补完整自动化的 `continue_run / finalize_step / publish` 闭环，但本轮先落最小可推导入口和桥接骨架。
- 多 batch 并行策略、版本升级策略和更细的 `contract_id` 映射规则后续再展开，本轮先保持 `contract_id = batch_id` 的 MVP 约定。
- 进度板系统、跨 run 状态追踪和更完整的 state snapshot 后续再统一接入，本轮先保持最小 review/run 收口。
- 多 batch 自动并行调度、复杂解锁策略和更细的 handoff 文案个性化后续再展开，本轮先优先收稳 batch index 与 handoff 主链。
- [Done] `runs/contract-*` 三个 contract run 文件夹命名已补齐日期前缀，与 init / prd run 命名风格保持一致。
- [Done] Contract 运行边界隔离已落：Contract 彻底与 PRD Run 隔离，只能读取上游和依赖 Run 的 release 产物，严禁回写。
- `contract` 的 GUI/前端入口与更重的可视化面板后续再做，本轮先用 run 内 Markdown progress board + YAML state snapshot 收稳主链状态。
- 更完整的跨流程自动编排和守护式 orchestration 后续再展开，本轮先把 `final_prd -> contract` 挂接、step closure 和主链级回归收稳。
