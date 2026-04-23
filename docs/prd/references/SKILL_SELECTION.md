# PRD Flow Skill Selection

这份说明基于 `mattpocock/skills` 最近一版 README 中的 skill 命名与定位，整理当前仓库最适合优先使用的 skill。

目标不是把外部 skill 变成主协议，而是给 `PRD 2.1.0` 补一层更稳定的辅助能力。

## 当前建议

优先级最高的三个：

1. `to-prd`
2. `to-issues`
3. `grill-me`

## 为什么是这三个

### `to-prd`

最适合当前仓库。

原因：

- 当前流程本来就需要把模糊需求扩成更稳定的 PRD 结构
- 仓库里已经存在 [to-prd skill adapter](/Users/wangwenjie/project/archetype-admin-path/docs/prd/references/TO_PRD_SKILL_ADAPTER.md)
- `analysis` 和 `execution_plan` 步骤 prompt 已经给了它的使用边界

当前落点：

- `analysis`：补强问题定义、用户价值、用户故事覆盖、major modules 草稿
- `execution_plan`：补强模块边界、batch 拆分、contract 优先级草稿

硬边界：

- 不输出 skill 自己的 Markdown PRD 模板
- 只允许辅助思考
- 最终必须回填当前仓库的 YAML 结构

### `to-issues`

适合作为 `final_prd` 之后的下游拆分器。

原因：

- 当前仓库已经把 `final_prd` 定义成进入 contract 的可信输入
- 一旦 `final_prd` 稳定，`to-issues` 很适合把 PRD 或执行计划拆成可领取的垂直切片 issue

当前建议落点：

- 不直接插进 `2.1.0` 四步主产物协议
- 放在 `final_prd` 之后，作为下游交付辅助能力
- 进入 `2.2.0` 时再考虑更正式的编排入口

### `grill-me`

适合作为澄清问题压力测试器。

原因：

- 当前 `clarification + Human Confirmation Gate` 正在收敛
- 这类 skill 很适合逼出隐藏假设、模糊边界和遗漏条件

当前建议落点：

- `clarification` 阶段：辅助检查待确认项是否真的必要
- reviewer 阶段：辅助检查问题是否问到了关键岔路

当前限制：

- 不替代 human gate
- 不替代 reviewer checklist
- 只增强追问质量

## 暂不优先纳入主链路的 skill

### `request-refactor-plan`

适合这个仓库自身后续重构时使用，但不适合当前 PRD 主链路。

### `design-an-interface`

适合 UI 设计发散，但当前 PRD 主链路更需要稳定结构化收口，不是界面方向探索。

### `write-a-skill`

适合后面沉淀自己的 PRD skill 时再用，现在还不是先手动作。

## 命名对齐

如果看到旧资料里的这些名字，按下面映射理解：

- `write-a-prd` -> `to-prd`
- `prd-to-issues` -> `to-issues`

## 当前结论

对当前仓库来说，最合理的顺序是：

1. `2.1.0` 继续正式使用 `to-prd` 作为受控辅助 skill
2. `clarification` / reviewer 逐步试用 `grill-me` 的追问思路
3. `final_prd` 稳定后，再把 `to-issues` 作为下游 issue 拆分能力接进来
