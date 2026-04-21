# Bootstrap Execution Checklist

覆盖 `init-07`。

## 输入

- 已通过的 `design_seed`
- [templates/structured/bootstrap_plan.template.yaml](/Users/wangwenjie/project/archetype-admin-path/docs/init/templates/structured/bootstrap_plan.template.yaml)
- [BOOTSTRAP_PLAN_PROMPT.md](/Users/wangwenjie/project/archetype-admin-path/docs/init/prompts/BOOTSTRAP_PLAN_PROMPT.md)

## 执行

1. `ruby scripts/init/bootstrap/prepare_bootstrap_plan.rb <run_dir> [--force]`
2. 补强 `bootstrap_plan`
3. 完成 reviewer
4. 生成并准备 human gate 材料：
   - `rendered/init-06.design_seed.md`
   - `rendered/init-07.bootstrap_plan.md`
   - `rendered/init-07.project-conventions.md`
   - `rendered/init-07.prd-bootstrap-context.md`
   - `rendered/init-07.init-execution-scope.md`
5. human gate 同时给出项目名称候选和目录 slug 候选；这些候选应直接体现在 `rendered/init-07.bootstrap_plan.md` 的“执行参数确认”段落中

## 检查点

- 是否明确哪些初始化底座工作应先做
- 是否区分本轮纳入和暂不纳入
- 是否优先基于脚本预填初稿做增量修正，而不是整份推翻重来
- 是否已经体现 design_seed / baseline 的具体项目特征，而不是通用后台模板
- 是否已通过：
  - `ruby scripts/init/validate_artifact.rb bootstrap_plan path/to/bootstrap_plan.yaml`
- 是否已进入 reviewer 审查，再决定是否允许进入 human gate
- 是否已额外生成长期规则、PRD 交接输入、execution scope 三类渲染物
- `rendered/init-07.bootstrap_plan.md` 是否已经收敛成索引页，而不是大段复述三份子文档正文
- `rendered/init-07.bootstrap_plan.md` 是否已明确区分 rendered 预览文件与后续项目固定路径
- human gate 是否同时给出 3 个项目名称候选与 2 到 3 个目录名称 slug 候选
- `rendered/init-07.bootstrap_plan.md` 是否已包含“执行参数确认”段落
- 默认初始化位置是否被明确表达为“当前工作区根目录下创建目录 `<目录名称>`，且该目录本身就是项目根目录”
