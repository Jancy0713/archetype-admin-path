# `to-prd` Skill Adapter for PRD Flow

## 目的

这份说明把已安装的外部 skill `to-prd` 适配到当前仓库的 PRD 协议里。

skill 路径：

- `/Users/wangwenjie/.agents/skills/to-prd/SKILL.md`

## 适用范围

当前只允许把它当作下面两步的辅助参考：

1. `analysis`
2. `execution_plan`

## 允许借用的能力

### 在 `analysis`

可以借用：

- 把当前上下文扩写成更完整的问题定义
- 先草拟用户视角的 solution / user stories
- 先草拟 major modules

落地要求：

- 最终只能回填到 `analysis` YAML 的既有字段
- 不得直接输出 skill 自己的 Markdown PRD 模板
- 不得生成 GitHub issue
- 不得把未确认事实写成既定结论

### 在 `execution_plan`

可以借用：

- 草拟 major modules 和模块边界
- 帮助识别适合拆成独立 batch 的深模块
- 帮助形成先后顺序与依赖

落地要求：

- 最终只能回填到 `execution_plan.contract_priorities` 和 `execution_plan.batching_strategy`
- skill 给出的模块草稿必须再经过当前 repo 的范围约束过滤
- 不得替代 `batching_strategy` 的正式结构

## 明确禁止

- 不允许替代 `clarification` 的 `confirmation_items`
- 不允许替代 `final_prd` / `prd_batches` 的正式 handoff 协议
- 不允许替代 `validate_artifact.rb`
- 不允许替代 `render_artifact.rb`
- 不允许替代 reviewer
- 不允许要求提交 GitHub issue

## 推荐使用方式

1. 先读当前步骤输入、rule、template。
2. 再把 `to-prd` 当作“扩写器 / 模块草稿器”参考。
3. 只吸收对当前步骤有帮助的部分：
   - 问题定义
   - 用户价值
   - 模块草图
   - 深模块拆分思路
4. 最后回到当前 YAML 模板逐字段收口。

## 输出纪律

- 当前正式产物仍然只有仓库里的结构化 YAML。
- 任何外部 skill 产出的自然语言草稿，都只是临时思考材料，不是正式真相源。
