# Init Execution Prompt

## 目标

这份 prompt 用于把 `init-08 execution` 变成标准可执行步骤：

1. 读取 `design_seed`、`bootstrap_plan` 和 `Init Execution Scope`
2. 在 run 内先生成待落位的 `project-conventions`
3. 在目标项目目录执行工程初始化命令
4. 由 AI 对工程骨架做必要补强
5. 由独立 reviewer 子 agent / 新上下文审查初始化结果
6. reviewer 通过后自动执行 `post_init_to_prd.rb`

这份 prompt 的预期用法是：在 `init-07` 完成后，新开一个干净上下文，把生成后的 run 内 prompt 整段交给新的执行代理，不要继续复用前面 01-07 的长对话。

## 标准输入

- `rendered/init-06.design_seed.md`
- `rendered/init-07.bootstrap_plan.md`
- `rendered/init-07.init-execution-scope.md`
- `rendered/init-08.project-conventions.md`
- 用户确认后的项目名称
- 用户确认后的初始化参数

## Prompt 必须覆盖的要求

1. 明确初始化目录、git 处理、owner、可选 `prd-run-id`
2. 要求代理优先使用 refine、shadcn、tailwind 等当前版本的官方初始化命令
3. 要求代理先把 run 内准备好的规则文档写入实际代码目录 `docs/project/project-conventions.md`
4. 要求代理只落地工程基座、主题 token、provider、平台默认能力占位，不实现业务模块
5. 要求代理在汇报中列出：
   - 实际执行命令
   - 关键文件落位
   - 已落地能力与保留占位
   - 留待后续 PRD 的边界
6. 要求代理在工程初始化完成后，必须先交给独立 reviewer 子 agent / 新上下文审查
7. 要求代理只有在 reviewer 明确通过后，才执行：
   - `ruby scripts/init/post_init_to_prd.rb ...`

## 运行时文件

实际执行时，应由脚本生成 run 内专用 prompt：

- `prompts/init-08-execution-prompt.md`
- `prompts/init-08-reviewer-prompt.md`

推荐生成方式：

```bash
ruby scripts/init/execute_init_scope.rb path/to/bootstrap_plan.yaml --project-name "<name>" --project-dir-name "<slug>"
```

如需单独渲染 prompt，也可直接执行：

```bash
ruby scripts/init/render_init_execution_prompt.rb path/to/bootstrap_plan.yaml runs/<run-id>/prompts/init-08-execution-prompt.md --project-name "<name>" --project-dir-name "<slug>"
```
