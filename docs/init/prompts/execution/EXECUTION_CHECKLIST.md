# Execution Execution Checklist

覆盖 `init-08`。

## 输入

- 已确认的 `bootstrap_plan`
- `rendered/init-06.design_seed.md`
- `rendered/init-07.bootstrap_plan.md`
- `rendered/init-07.init-execution-scope.md`
- 用户确认后的项目名称
- 用户确认后的目录名称
- 用户如有指定，则带上自定义初始化目录 / git 处理参数

## 执行

1. `ruby scripts/init/execution/prepare_execution.rb <run_dir> [execute_init_scope args...]`
2. 在 run 内生成待落位的 `rendered/init-08.project-conventions.md`
3. 生成 run 内执行 prompt 与 reviewer prompt
4. 明确告知用户新开一个干净上下文
5. 把 `prompts/init-08-execution-prompt.md` 整段交给新的执行代理
6. 执行代理按 `Init Execution Scope` 初始化项目，并把规则文档写入实际代码目录 `docs/project/project-conventions.md`
7. 初始化完成后先向用户汇报本次完成内容
8. 再把 `prompts/init-08-reviewer-prompt.md` 整段交给独立 reviewer 子 agent / 新上下文
9. reviewer 通过后自动继续：
   - `ruby scripts/init/post_init_to_prd.rb ...`
   - 创建新的 `prd` run
   - 注入 `raw/attachments/confirmed-foundation.md`
   - 注入 `raw/attachments/base-modules-prd.md`
   - 预填新的 `raw/request.md`
   - 生成新的 PRD 启动提示词
   - 这些文件应直接由已清洗的 `prd-bootstrap-context` 拆分得到，不在 `init-08` 再承担二次去味或兼容旧逻辑

## 检查点

- 默认初始化目录为当前工作区根目录下的 `<目录名称>`，该目录本身就是实际项目根目录
- `rendered/init-08.project-conventions.md` 只是待落位稿，不应提前写到外层容器目录
- 默认删除现有 `.git`
- 如果用户要求保留 `.git`，则按用户要求处理；如同时给出 `remote-url`，则设置对应 remote
- 执行后必须先向用户汇报：
  - 本次初始化完成了哪些工作
  - 写入了哪些关键文档
  - 生成了哪些工程骨架或基础能力
- reviewer 必须由独立 reviewer 子 agent 或独立新上下文执行，主执行 agent 不得自己兼任 reviewer
- reviewer 通过前，不得执行 `post_init_to_prd.rb`
- 注入的新 PRD run 输入应保持职责清晰：
  - `confirmed-foundation.md` 只承载稳定前提
  - `base-modules-prd.md` 只承载基础模块需求
  - `raw/request.md` 只承载最小执行指令
- `init-08` 应优先使用新上下文，不继续复用 `init-01` 到 `init-07` 的长对话
