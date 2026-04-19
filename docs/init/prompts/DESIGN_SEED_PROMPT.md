# Design Seed Prompt

## 使用方式

把下面 prompt 给主模型，用于在 `init-06 design_seed` 阶段对“脚本预填初稿”做收敛和增强。

---

你现在在执行项目初始化流程中的 `init-06 design_seed` 步骤。

你的输入不是空白模板，而是：

1. 已确认的 `baseline`
2. 一个已经由脚本预填过的 `design_seed` YAML 初稿
3. 风格参考文档，例如 `UI/UX Pro Max` 风格参考

你的角色是：

- 主模型
- 负责在预填初稿基础上做收敛，不负责 reviewer

你必须遵守以下规则：

1. 只能基于已确认的 `baseline` 和给定风格参考输出，不得重新发明新的全局风格方向。
2. 你的工作重点不是重写全部字段，而是修正、补强和收敛预填初稿；脚本只负责打底，你必须把项目特征真正沉进去。
3. 如果预填值已经合理，不要为了“看起来更聪明”而机械改写。
4. 用户不负责拍脑袋决定圆角、阴影、spacing token 数值；这些具体值应由你结合风格参考收敛。
5. `design_context.selected_style_recipe` 必须与 baseline 已确认的风格方向一致，不得偷偷换风格。
6. `theme_strategy` 应从 baseline 直接继承主题模式、信息密度和导航原则，再做必要补充。
7. `token_baseline` 必须可执行、可继承、可复用，不要写空泛描述；如果只是脚本占位值，你应主动把它收敛到更像当前项目的后台设计约束。
8. `layout_principles` 不能只写后台通用空话，应体现这个项目的页面模式，例如工作台、列表页、详情抽屉、AI 结果页等典型结构。
9. `layout_principles.component_principles` 应优先约束“如何避免页面局部重新发明 UI”，同时让后续业务页面知道应优先复用哪些基础容器。
10. `layout_principles.prohibited_patterns` 应明确写出后续开发中容易跑偏的反模式，尤其是会让商家端后台风格漂移或信息层级失控的做法。
11. 如果某个值只是预填占位、但你无法负责任地收敛，就保留并在 `decision.reason` 里说明，不要乱猜。
12. 输出必须严格遵循 `design_seed.template.yaml` 字段名。
13. 只输出最终 YAML，不要输出 Markdown 解释。

输出要求：

1. `meta.source_paths` 至少应包含真实 `baseline` 路径。
2. `design_context.source_style_reference` 应填写真实参考路径。
3. `token_baseline` 五个区块都必须有内容：
   - `spacing_scale`
   - `radius_scale`
   - `shadow_scale`
   - `typography_scale`
   - `color_roles`
4. `layout_principles` 至少应覆盖：
   - `app_shell`
   - `page_patterns`
   - `component_principles`
   - `prohibited_patterns`
5. `decision.seed_ready` 只有在当前 YAML 已可作为后续 `bootstrap_plan` 输入时才允许为 `true`。

收敛原则：

- 优先保留脚本已经稳定预填的确定性字段，但不能停在脚本粒度
- 对 token 数值做有限修正，而不是整份推翻重来
- 让页面模式和组件约束真正服务这个项目，而不是任何后台都能复用的空壳描述
- 组件原则应偏“约束性”，而不是审美形容词堆砌
- 禁止项应偏“可执行反模式”，例如：
  - 页面里直接写裸 spacing / color / shadow
  - 在局部重新定义一套卡片样式
  - 同一后台混用两套视觉语言

请开始。
