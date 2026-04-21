# 执行清单

分组版本：

- [profile/EXECUTION_CHECKLIST.md](/Users/wangwenjie/project/archetype-admin-path/docs/init/prompts/profile/EXECUTION_CHECKLIST.md)
- [foundation/EXECUTION_CHECKLIST.md](/Users/wangwenjie/project/archetype-admin-path/docs/init/prompts/foundation/EXECUTION_CHECKLIST.md)
- [bootstrap/EXECUTION_CHECKLIST.md](/Users/wangwenjie/project/archetype-admin-path/docs/init/prompts/bootstrap/EXECUTION_CHECKLIST.md)
- [execution/EXECUTION_CHECKLIST.md](/Users/wangwenjie/project/archetype-admin-path/docs/init/prompts/execution/EXECUTION_CHECKLIST.md)

这份文件继续保留为总览索引与全流程清单。

## Step 1：项目画像

主模型输入：

- 用户的一句话描述 / 项目背景 / 整份 PRD
- [MASTER_PROMPT.md](/Users/wangwenjie/project/archetype-admin-path/docs/init/prompts/MASTER_PROMPT.md)
- [rules/PROJECT_PROFILE_RULE.md](/Users/wangwenjie/project/archetype-admin-path/docs/init/rules/PROJECT_PROFILE_RULE.md)
- [templates/structured/project_profile.template.yaml](/Users/wangwenjie/project/archetype-admin-path/docs/init/templates/structured/project_profile.template.yaml)
- [references/UI_UX_PRO_MAX_STYLE_REFERENCE.md](/Users/wangwenjie/project/archetype-admin-path/docs/init/references/UI_UX_PRO_MAX_STYLE_REFERENCE.md)

检查点：

- 是否先抽项目画像摘要，再进入分阶段确认
- 是否明确 `current_stage`、`completed_stages`、`remaining_stages`
- 是否只展开当前阶段，而不是一次性展开所有阶段
- 是否按阶段递进确认：
  - 第一阶段：地区、语言、系统类型、主要使用端
  - 第二阶段：租户模型、平台级 / 租户级管理结构
  - 第三阶段：登录方式、账号体系、权限模型
  - 第四阶段：UI 风格方案、主题、通用平台能力
- 是否只在当前阶段填写有效的 `confirmation_items`
- 未进入阶段是否只保留固定题骨架，而不是提前填写正式结论或扩成大题库

## Step 2：Reviewer 审查项目画像

reviewer 输入：

- 已通过：
  - `ruby scripts/init/validate_artifact.rb project_profile path/to/project_profile.yaml`
- [REVIEWER_PROMPT.md](/Users/wangwenjie/project/archetype-admin-path/docs/init/prompts/REVIEWER_PROMPT.md)
- [rules/REVIEWER_RULE.md](/Users/wangwenjie/project/archetype-admin-path/docs/init/rules/REVIEWER_RULE.md)
- [templates/structured/review.template.yaml](/Users/wangwenjie/project/archetype-admin-path/docs/init/templates/structured/review.template.yaml)
- 建议先执行：
  - `ruby scripts/init/init_artifact.rb --step project_initialization review path/to/review.yaml`

检查点：

- 是否抓准项目类型
- 是否阶段划分合理，推进顺序清晰
- 是否优先确认了高优先级阶段
- 是否把关键问题错误地下沉成默认值
- 是否提供了足够清晰的推荐项和短解释
- 是否错误地把后续阶段扩成了完整题库
- 是否填写了 `current_stage_review.checklist`
- checklist 是否覆盖了当前阶段全部专项检查项

阶段通过后，还应有人执行：

- 当前阶段 Human Confirmation Gate
- 只有确认结果回填到 `confirmation` 后，才允许把下一阶段转成 `in_progress`

## Step 3：初始化基线

主模型输入：

- 已通过且已完成阶段确认的项目画像
- [MASTER_PROMPT.md](/Users/wangwenjie/project/archetype-admin-path/docs/init/prompts/MASTER_PROMPT.md)
- [BASELINE_PROMPT.md](/Users/wangwenjie/project/archetype-admin-path/docs/init/prompts/BASELINE_PROMPT.md)
- [rules/BASELINE_RULE.md](/Users/wangwenjie/project/archetype-admin-path/docs/init/rules/BASELINE_RULE.md)
- [templates/structured/baseline.template.yaml](/Users/wangwenjie/project/archetype-admin-path/docs/init/templates/structured/baseline.template.yaml)
- [references/UI_UX_PRO_MAX_STYLE_REFERENCE.md](/Users/wangwenjie/project/archetype-admin-path/docs/init/references/UI_UX_PRO_MAX_STYLE_REFERENCE.md)

检查点：

- 是否沉淀成统一基线
- 是否把最终 UI 风格方案沉淀为可继承的完整描述，而不只是主题模式
- 是否主动补强了会影响后续实现发散度的项目细节，而不是只做摘要式整合
- 是否让后续 AI 能看懂登录、租户、权限、平台能力、UI 基线的默认落地方向
- 是否保留仍待确认的关键问题
- 是否已经通过：
  - `ruby scripts/init/validate_artifact.rb baseline path/to/baseline.yaml`

## Step 4：design_seed

主模型输入：

- 已确认的 `baseline`
- [references/UI_UX_PRO_MAX_STYLE_REFERENCE.md](/Users/wangwenjie/project/archetype-admin-path/docs/init/references/UI_UX_PRO_MAX_STYLE_REFERENCE.md)
- [templates/structured/design_seed.template.yaml](/Users/wangwenjie/project/archetype-admin-path/docs/init/templates/structured/design_seed.template.yaml)
- [DESIGN_SEED_PROMPT.md](/Users/wangwenjie/project/archetype-admin-path/docs/init/prompts/DESIGN_SEED_PROMPT.md)

检查点：

- 是否把风格方向收敛成可继承的设计约束
- 是否给出 spacing / radius / shadow / typography / color 的基线
- 是否明确 app shell 和组件原则
- 是否优先基于“脚本预填初稿”做增量修正，而不是整份推翻重来
- 是否把项目特征、页面模式和后台壳层细节真正补进了 design_seed
- 是否已经通过：
  - `ruby scripts/init/validate_artifact.rb design_seed path/to/design_seed.yaml`
- 是否已进入 reviewer 审查，再决定是否允许生成 `bootstrap_plan`
- 是否注意到这一步不单独停给人，而是在 `init-07` 一并给用户确认

## Step 5：bootstrap_plan

主模型输入：

- 已通过的 `design_seed`
- [templates/structured/bootstrap_plan.template.yaml](/Users/wangwenjie/project/archetype-admin-path/docs/init/templates/structured/bootstrap_plan.template.yaml)
- [BOOTSTRAP_PLAN_PROMPT.md](/Users/wangwenjie/project/archetype-admin-path/docs/init/prompts/BOOTSTRAP_PLAN_PROMPT.md)

检查点：

- 是否明确哪些初始化底座工作应先做
- 是否区分本轮纳入和暂不纳入
- 是否优先基于“脚本预填初稿”做增量修正，而不是整份推翻重来
- 是否已经体现 design_seed / baseline 的具体项目特征，而不是通用后台模板
- 是否已经通过：
  - `ruby scripts/init/validate_artifact.rb bootstrap_plan path/to/bootstrap_plan.yaml`
- 是否已进入 reviewer 审查，再决定是否允许进入 human gate
- 是否已额外生成 `rendered/init-07.project-conventions.md`，供 human gate 一并确认项目长期规则
- 是否已额外生成 `rendered/init-07.prd-bootstrap-context.md`，供 human gate 一并确认下一轮 PRD 输入
- 是否已额外生成 `rendered/init-07.init-execution-scope.md`，供 human gate 一并确认
- human gate 是否同时给出 3 个项目名称候选与 2 到 3 个目录名称 slug 候选
- 默认初始化位置是否被明确表达为“当前工作区根目录下创建目录 `<目录名称>`，且该目录本身就是项目根目录”

## Step 6：init-08 execution

执行输入：

- 已确认的 `bootstrap_plan`
- `rendered/init-06.design_seed.md`
- `rendered/init-07.bootstrap_plan.md`
- `rendered/init-07.init-execution-scope.md`
- 用户确认后的项目名称
- 用户确认后的目录名称
- 用户如有指定，则带上自定义初始化目录 / git 处理参数

执行要求：

- 先通过 `scripts/init/execute_init_scope.rb` 基于已确认参数生成 run 内待落位的 `rendered/init-08.project-conventions.md`、执行 prompt 和 reviewer prompt
- 然后明确告知用户新开一个干净上下文
- 再把 `prompts/init-08-execution-prompt.md` 整段交给新的执行代理
- 执行代理按 `Init Execution Scope` 初始化项目，并把规则文档写入实际代码目录 `docs/project/project-conventions.md`
- 默认初始化目录为当前工作区根目录下的 `<目录名称>`，该目录本身就是实际项目根目录
- 默认删除现有 `.git`
- 如果用户要求保留 `.git`，则按用户要求处理；如同时给出 `remote-url`，则设置对应 remote
- 初始化完成后必须先向用户汇报：
  - 本次初始化完成了哪些工作
  - 写入了哪些关键文档
  - 生成了哪些工程骨架或基础能力
- 然后必须把 `prompts/init-08-reviewer-prompt.md` 整段交给独立 reviewer 子 agent 或独立新上下文
- reviewer 通过后再自动继续：
  - 执行 `ruby scripts/init/post_init_to_prd.rb ...`
  - 创建新的 `prd` run
  - 注入 `raw/attachments/confirmed-foundation.md`
  - 注入 `raw/attachments/base-modules-prd.md`
  - 预填新的 `raw/request.md`
  - 生成新的 PRD 启动提示词
  - 上述注入内容应直接来自已清洗的 `prd-bootstrap-context`，不在 `init-08` 再做二次去味或兼容旧脏内容

## Step 7：初始化变更

- 需要修改系统基座时，使用 [change_request.template.yaml](/Users/wangwenjie/project/archetype-admin-path/docs/init/templates/structured/change_request.template.yaml)

## 当前执行约束

- AI 主输出一律为 YAML
- Markdown 只作为渲染结果给人看
- 每次主模型产出后必须先运行：
  - `ruby scripts/init/validate_artifact.rb <type> <artifact.yml>`
- 脚本校验失败时，不进入 reviewer，直接返工修正 YAML
- `project_profile` 默认按多阶段多轮更新同一个 YAML，而不是一次性填满
- `init-01` 到 `init-04` 默认经过：AI 产出 -> 脚本校验 -> reviewer -> Human Confirmation Gate
- `init-05` 默认经过：AI 产出 -> 脚本校验 -> Human Confirmation Gate
- `init-06` 默认经过：AI 产出 -> 脚本校验 -> reviewer -> 进入 `init-07`
- `init-07` 默认经过：AI 产出 -> 脚本校验 -> reviewer -> Human Confirmation Gate
- `init-08` 默认经过：执行代理初始化 -> 独立 reviewer 审查 -> post_init_to_prd
