# Baselines

本目录用于持久化存放“**已被实现验证过的稳定合同**”（Source of Truth）。

它有别于 `runs/YYYY-MM-DD-contract-<flow-id>/contract/working/`（过程态草稿）与 `runs/YYYY-MM-DD-contract-<flow-id>/contract/release/`（交给 `develop` 但尚未验证的输入）。

## 目录结构设计原则

以 Flow ID 为单位进行管理，优先保证业务边界清晰度：

```text
baselines/
  <flow-id>/
    current/
      openapi.yaml
      openapi.summary.md
      develop-verified-handoff.md
      implementation-settlement.md # 实现后产出的结算说明
    history/
      <run-id>/
        # 对应历史版本的备档
```

## 使用准则

- 仅当 `develop` 阶段的代码生成和实现试错顺利通过后，才使用 `settle_baseline.rb` 脚本将当前的 `release/` 内容迁至此处作为 `current` 稳定基线。
- 未来如果功能有针对性的增量需求（不涉及拆分调整），可以基于此处的 `current` 作为回切基准（Baseline Re-entry）。
