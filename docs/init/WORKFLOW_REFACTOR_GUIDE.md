# Init Workflow Refactor Guide

这份文档记录当前 `init` 流程重构后的结构约定，目标是减少脚本、提示词和步骤编号之间的漂移。

## 当前原则

- 不修改历史 `runs/<run-id>/...` 产物
- 只重构流程代码、文档索引与脚本包装层
- 先收敛编排事实，再迁移文件位置
- 旧入口尽量保留，必要时转发到新 wrapper

## 当前单一事实来源

- `init` 步骤映射、阶段分组、continue 链路、初始进度状态：
  [scripts/init/workflow_manifest.rb](/Users/wangwenjie/project/archetype-admin-path/scripts/init/workflow_manifest.rb)

## 当前脚本分组

- [profile](/Users/wangwenjie/project/archetype-admin-path/scripts/init/profile/README.md)
- [foundation](/Users/wangwenjie/project/archetype-admin-path/scripts/init/foundation/README.md)
- [bootstrap](/Users/wangwenjie/project/archetype-admin-path/scripts/init/bootstrap/README.md)
- [execution](/Users/wangwenjie/project/archetype-admin-path/scripts/init/execution/README.md)

## 当前提示词分组

- [prompts index](/Users/wangwenjie/project/archetype-admin-path/docs/init/prompts/README.md)
- [profile checklist](/Users/wangwenjie/project/archetype-admin-path/docs/init/prompts/profile/EXECUTION_CHECKLIST.md)
- [foundation checklist](/Users/wangwenjie/project/archetype-admin-path/docs/init/prompts/foundation/EXECUTION_CHECKLIST.md)
- [bootstrap checklist](/Users/wangwenjie/project/archetype-admin-path/docs/init/prompts/bootstrap/EXECUTION_CHECKLIST.md)
- [execution checklist](/Users/wangwenjie/project/archetype-admin-path/docs/init/prompts/execution/EXECUTION_CHECKLIST.md)

## 后续改动顺序建议

1. 先改 `workflow_manifest.rb`
2. 再改 wrapper 脚本
3. 再改 prompt/checklist 导航
4. 最后才改总览文档和模板

## 每次改动后的最小检查

1. `ruby -c` 检查变更脚本
2. `create_run --flow init` smoke check
3. `continue_run` 关键 step 命令链检查
4. `workflow-progress.md` 状态检查
5. prompt 链接与 checklist 链接检查
