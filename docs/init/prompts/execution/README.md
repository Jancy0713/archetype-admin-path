# Execution Prompt Group

这一组覆盖 `init-08`，负责工程初始化执行与 post-init 交接。

包含：

- 执行 prompt：
  [INIT_EXECUTION_PROMPT.md](/Users/wangwenjie/project/archetype-admin-path/docs/init/prompts/INIT_EXECUTION_PROMPT.md)
- 分组执行清单：
  [EXECUTION_CHECKLIST.md](/Users/wangwenjie/project/archetype-admin-path/docs/init/prompts/execution/EXECUTION_CHECKLIST.md)

说明：

- `init-08` 需要独立 reviewer 子 agent / 新上下文在执行完成后做一次收口审查
- reviewer 通过后，执行代理必须运行 `post_init_to_prd.rb`
