# PRD 版本路线图

## 目标

这份文档用于统一记录 `PRD` 流程的版本归属，避免后续继续开发时混淆：

- 哪些内容已经做完
- 哪些属于 `2.1.0`
- 哪些留到 `2.2.0` 以后
- 什么时候开始第一轮真实测试

## 当前结论

当前采用的版本推进节奏是：

1. `2.0.0`：主链路重构完成
2. `2.1.0`：把主链路补到完整可测，并提前做好结构治理
3. `2.1.0` 完成后：先做第一轮真实测试
4. `2.2.0`：更系统的 skill 编排和能力增强
5. `2.3.0+`：更重的自动化 / 对抗式机制

## 2.0.0 已完成

`2.0.0` 当前已经完成的内容：

1. 正式重排 PRD 主流程：
   - `analysis`
   - `clarification`
   - `execution_plan`
   - `final_prd`
2. 主模板切换到新四步流程
3. 主脚本切换到新四步流程
4. `create_run` 切换到 `prd-01.analysis.yaml` 起手
5. `final_prd -> contract` 的基础 handoff 结构
6. reviewer 独立执行规则：
   - reviewer 必须由独立 reviewer 子 agent 或独立上下文执行
   - 主 agent 不得自己兼任 reviewer
7. `clarification` 默认接入 `Human Confirmation Gate`
8. 主文档、流程图、进度板、运行目录规范已经对齐新四步流程

说明：

- `2.0.0` 现在的定位不是“还在设计”，而是“主链路已经切过去了”
- 但它还没有经过首轮真实验证

## 2.1.0 范围

`2.1.0` 的目标不是重新做流程重构，而是把当前主链路补到“完整可测版本”。

### A. 主链路补强

1. `analysis` 输出稳定性补强
2. `clarification + Human Confirmation Gate` 体验补强
3. `execution_plan` 计划质量补强
4. `final_prd -> contract` handoff 细化
5. reviewer 各阶段专项检查项补齐
6. run 执行体验补强
7. 首轮真实验证前的执行说明补齐

### B. 结构治理

这一块明确属于 `2.1.0`，不是附带优化：

1. 提示词分拆
2. 规则文档分拆
3. 脚本职责分拆
4. reviewer 资料分拆
5. 步骤资料分拆

目标：

- 从前期就把文件拆清楚
- 避免像 `init` 后期那样 prompt / script / reviewer / step materials 越堆越乱

### C. `2.1.0` 内允许的 skill 用法

`2.1.0` 已经允许把外部 skill 当作“参考器 / 草稿器 / 子步骤能力”接入当前流程，但边界要收紧：

1. 只允许在步骤 prompt 中作为辅助参考
2. 不允许替代当前 YAML 结构、校验器、render 和 handoff 协议
3. 优先接入已经有明确 adapter 的 skill
4. skill 产出最终必须回填到当前仓库的结构化产物中

当前优先采用的 skill：

- `to-prd`
- `to-issues`
- `grill-me`

其中：

- `to-prd` 适合 `analysis` / `execution_plan` 阶段做需求扩写和模块草拟
- `to-issues` 适合在 `final_prd` 稳定后，作为下游 issue 拆分器使用
- `grill-me` 适合在 `clarification` 或 reviewer 阶段补强追问强度

### D. 2.1.0 完成后的动作

`2.1.0` 做完后，不直接继续做 `2.2.0`，而是先做：

1. 第一轮真实测试
2. 根据测试结果决定是否修 `2.1.0` 残留问题
3. 测试通过后，再更新 `CHANGELOG.md`

## 2.2.0 范围

`2.2.0` 不再是“第一次用 skill”，而是开始做更系统的 skill 编排和能力增强。

范围包括：

1. skill 编排层设计
2. 多 skill 协同策略
3. 高频问题库
4. 更稳定的澄清题模板
5. 计划生成增强
6. 更自动化的辅助编排

当前记录的 skill 候选包括：

- `pm-skills`
- `product-manager-skills`
- `prd-colipot`
- `to-prd`
- `to-issues`
- `grill-me`
- `github/awesome-copilot@prd`
- `github/awesome-copilot@breakdown-feature-prd`
- `request-refactor-plan`

当前约束：

- 先不改别人的 skill
- 先把 skill 当“参考器 / 草稿器 / 子步骤能力”
- 不能让 skill 取代你自己的 YAML、校验器、render 和 handoff 协议

## 2.3.0 以后

更后面的增强方向包括：

1. 更复杂的 reviewer / debate 机制
2. contract 前更强门禁
3. 多轮自动澄清策略
4. 更完整的跨阶段自动编排

这些内容默认不提前进入 `2.1.0` 或 `2.2.0`。

## 推荐阅读关系

如果要继续推进版本工作，建议按下面顺序看：

1. [PRD_VERSION_ROADMAP.md](/Users/wangwenjie/project/archetype-admin-path/docs/prd/PRD_VERSION_ROADMAP.md)
2. [PRD_2_1_SCOPE.md](/Users/wangwenjie/project/archetype-admin-path/docs/prd/PRD_2_1_SCOPE.md)
3. [PRD_WORKFLOW_V2_PLAN.md](/Users/wangwenjie/project/archetype-admin-path/docs/prd/PRD_WORKFLOW_V2_PLAN.md)
4. [PRD_2_0_VALIDATION_PREP.md](/Users/wangwenjie/project/archetype-admin-path/docs/prd/PRD_2_0_VALIDATION_PREP.md)
