# Init Execution Prompt

## 目标

这份 prompt 用于把 `init-08 execution` 变成标准可执行步骤：

1. 读取 `design_seed`、`bootstrap_plan` 和 `Init Execution Scope`
2. 在目标项目目录执行工程初始化命令
3. 由 AI 对工程骨架做必要补强
4. 完成后自动执行 `post_init_to_prd.rb`

## 标准输入

- `rendered/init-06.design_seed.md`
- `rendered/init-07.bootstrap_plan.md`
- `rendered/init-08.init-execution-scope.md`
- `docs/project/project-conventions.md`
- 用户确认后的项目名称
- 用户确认后的初始化参数

## Prompt 必须覆盖的要求

1. 明确初始化目录、git 处理、owner、可选 `prd-run-id`
2. 要求代理优先使用 refine、shadcn、tailwind 等当前版本的官方初始化命令
3. 要求代理只落地工程基座、主题 token、provider、平台默认能力占位，不实现业务模块
4. 要求代理在汇报中列出：
   - 实际执行命令
   - 关键文件落位
   - 已落地能力与保留占位
   - 留待后续 PRD 的边界
5. 要求代理在工程初始化完成后立即执行：
   - `ruby scripts/init/post_init_to_prd.rb ...`

## 运行时文件

实际执行时，应由脚本生成 run 内专用 prompt：

- `prompts/init-08-execution-prompt.md`

推荐生成方式：

```bash
ruby scripts/init/execute_init_scope.rb path/to/bootstrap_plan.yaml --project-name "<name>"
```

如需单独渲染 prompt，也可直接执行：

```bash
ruby scripts/init/render_init_execution_prompt.rb path/to/bootstrap_plan.yaml runs/<run-id>/prompts/init-08-execution-prompt.md --project-name "<name>"
```
