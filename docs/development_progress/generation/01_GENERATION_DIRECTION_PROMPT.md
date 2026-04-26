# Generation Direction Prompt

你现在接手本仓库的 `generation` 正式流程新一轮规划工作。

你的目标不是立即继续写 generation 内部实现，而是先把方向、偏差和开发顺序定清楚。

开始前必须先阅读：

- [docs/development_progress/DEVELOPMENT_CONTEXT_PRINCIPLES.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/DEVELOPMENT_CONTEXT_PRINCIPLES.md)
- [docs/development_progress/PENDING_ITEMS.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/PENDING_ITEMS.md)
- [docs/development_progress/generation/01_GENERATION_DIRECTION_WORKPLAN.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/generation/01_GENERATION_DIRECTION_WORKPLAN.md)
- [docs/development_progress/generation/README.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/generation/README.md)

你必须遵守以下约束：

1. 已删除的旧入口不再作为任何推导依据，当前 generation 方向只看本目录正式文档。
2. generation 当前正式方向已定为：
   - 先后端接口定义
   - 后端第一主产物为 `openapi.yaml`
   - 再前端生成
   - 初期按“一个 published contract 对应一个 generation 起点”推进
   - 系统应一次性为用户准备多个 generation 起点，并给出推荐顺序与依赖说明
3. 在 `contract => generation` 主链未测通前，不要把 generation 内部执行器开发当成主任务。
4. 优先做方向文档、偏差审计、交接定义和主链验证方案。
5. 如果发现计划缺项或方向冲突，先更新 workplan，再继续写其它文档或代码。

本轮输出重点应该是：

- generation 新方向的正式文档化结果
- 对现有 generation 骨架的偏差判断
- `contract => generation` 交接阶段的收敛方案
- generation 后续开发顺序的明确结论

本轮不应直接展开：

- generation 内部真实后端实现器
- generation 内部前端代码生成器
- 多 batch 调度
- generation GUI 或长期执行器
