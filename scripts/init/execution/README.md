# Execution Scripts Group

目标承载 `init-08` 的脚本包装层。

范围：

- `execute_init_scope.rb`
- `render_init_execution_prompt.rb`
- `post_init_to_prd.rb`

当前 wrapper：

- [prepare_execution.rb](/Users/wangwenjie/project/archetype-admin-path/scripts/init/execution/prepare_execution.rb)

说明：

- 这一组和前面几组不同，重点是执行编排，不是结构化 YAML 生成。
- `prepare_execution.rb` 的职责是把 `init-07` 已确认结果收敛成新的执行包。
- `init-08` 应在新的执行上下文里运行，不继续复用 `init-01` 到 `init-07` 的长对话。
- `prepare_execution.rb` 现在会在 run 内生成待落位的 `rendered/init-08.project-conventions.md`，由执行代理在实际代码目录中写入。
- 工程初始化完成后，必须再交给独立 reviewer 子 agent 或新的独立上下文审查，通过后才能继续 `post_init_to_prd.rb`。
