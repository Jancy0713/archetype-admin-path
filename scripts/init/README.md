# Init Scripts Layout

`scripts/init` 正在按阶段簇重组，目标分组如下：

- [profile](/Users/wangwenjie/project/archetype-admin-path/scripts/init/profile/README.md)
- [foundation](/Users/wangwenjie/project/archetype-admin-path/scripts/init/foundation/README.md)
- [bootstrap](/Users/wangwenjie/project/archetype-admin-path/scripts/init/bootstrap/README.md)
- [execution](/Users/wangwenjie/project/archetype-admin-path/scripts/init/execution/README.md)

当前主脚本仍保留在本目录，后续迁移优先保证：

- step id 不漂移
- prompt 与脚本入口一致
- reviewer / human gate 规则不变
- rendered 产物路径不变
- reviewer 必须继续由独立 reviewer 子 agent 或独立新上下文执行
- `init-07 -> init-08` 必须继续走“生成执行 prompt -> 新开上下文执行”的切换方式
