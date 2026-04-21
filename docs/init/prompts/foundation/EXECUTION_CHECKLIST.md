# Foundation Execution Checklist

覆盖 `init-05` 到 `init-06`。

## `init-05 baseline`

输入：

- 已通过且已完成阶段确认的项目画像
- [MASTER_PROMPT.md](/Users/wangwenjie/project/archetype-admin-path/docs/init/prompts/MASTER_PROMPT.md)
- [BASELINE_PROMPT.md](/Users/wangwenjie/project/archetype-admin-path/docs/init/prompts/BASELINE_PROMPT.md)
- [rules/BASELINE_RULE.md](/Users/wangwenjie/project/archetype-admin-path/docs/init/rules/BASELINE_RULE.md)
- [templates/structured/baseline.template.yaml](/Users/wangwenjie/project/archetype-admin-path/docs/init/templates/structured/baseline.template.yaml)

执行：

1. `ruby scripts/init/foundation/prepare_baseline.rb <run_dir> [--force]`
2. 补强 `baseline`
3. 确认已通过：
   - `ruby scripts/init/validate_artifact.rb baseline path/to/baseline.yaml`
4. 进入 human gate

检查点：

- 是否沉淀成统一基线
- 是否把最终 UI 风格方案沉淀为可继承的完整描述，而不只是主题模式
- 是否主动补强了会影响后续实现发散度的项目细节，而不是只做摘要式整合
- 是否让后续 AI 能看懂登录、租户、权限、平台能力、UI 基线的默认落地方向
- 是否保留仍待确认的关键问题

说明：

- `init-05` 默认不单独加 reviewer

## `init-06 design_seed`

输入：

- 已确认的 `baseline`
- [DESIGN_SEED_PROMPT.md](/Users/wangwenjie/project/archetype-admin-path/docs/init/prompts/DESIGN_SEED_PROMPT.md)
- [templates/structured/design_seed.template.yaml](/Users/wangwenjie/project/archetype-admin-path/docs/init/templates/structured/design_seed.template.yaml)
- [references/UI_UX_PRO_MAX_STYLE_REFERENCE.md](/Users/wangwenjie/project/archetype-admin-path/docs/init/references/UI_UX_PRO_MAX_STYLE_REFERENCE.md)

执行：

1. `ruby scripts/init/foundation/prepare_design_seed.rb <run_dir> [--force]`
2. 补强 `design_seed`
3. 完成 reviewer
4. 进入 `init-07`

检查点：

- 是否把风格方向收敛成可继承的设计约束
- 是否给出 spacing / radius / shadow / typography / color 的基线
- 是否明确 app shell 和组件原则
- 是否优先基于脚本预填初稿做增量修正，而不是整份推翻重来
- 是否把项目特征、页面模式和后台壳层细节真正补进了 design_seed
- 是否已通过：
  - `ruby scripts/init/validate_artifact.rb design_seed path/to/design_seed.yaml`

说明：

- `init-06` 保留 reviewer
- `init-06` 不单独停给人，而是在 `init-07` 一并确认
