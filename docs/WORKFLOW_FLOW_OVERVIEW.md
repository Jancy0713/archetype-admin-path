# Init / PRD 流程总览

这份文档用于测试时快速看清：

- 当前在哪条流程
- 正在执行第几步
- 下一步会依赖什么产物

## Init

```mermaid
flowchart TD
    A["原始输入"] --> I01["init-01<br/>project_profile<br/>foundation_context"]
    I01 --> I01V["validate"]
    I01V --> I01R["review"]
    I01R --> I01H["human confirm"]
    I01H --> I02["init-02<br/>project_profile<br/>tenant_governance"]
    I02 --> I02V["validate"]
    I02V --> I02R["review"]
    I02R --> I02H["human confirm"]
    I02H --> I03["init-03<br/>project_profile<br/>identity_access"]
    I03 --> I03V["validate"]
    I03V --> I03R["review"]
    I03R --> I03H["human confirm"]
    I03H --> I04["init-04<br/>project_profile<br/>experience_platform"]
    I04 --> I04V["validate"]
    I04V --> I04R["review"]
    I04R --> I04H["human confirm"]
    I04H --> I05["init-05<br/>baseline"]
    I05 --> I05V["validate"]
    I05V --> I05H["human confirm<br/>baseline"]
    I05H --> I06["init-06<br/>design_seed"]
    I06 --> I06V["validate"]
    I06V --> I06R["review"]
    I06R --> I07["init-07<br/>bootstrap_plan"]
    I07 --> I07V["validate"]
    I07V --> I07R["review"]
    I07R --> I07H["human confirm<br/>bootstrap plan"]
    I07H --> I08["init-08<br/>execution"]
    I08 --> P01["自动创建 prd run<br/>prd-01"]
    I08 -. "如需调整基线" .-> C1["change_request<br/>独立流程"]
```

## PRD

```mermaid
flowchart TD
    A["原始需求 / PRD / 原型"] --> P01["prd-01<br/>clarification"]
    P01 --> P01V["validate"]
    P01V --> P01R["review"]
    P01R --> P02["prd-02<br/>brief"]
    P02 --> P02V["validate"]
    P02V --> P03["prd-03<br/>decomposition"]
    P03 --> P03V["validate"]
    P03V --> P03R["review"]
    P03R --> P04["进入 Contract 设计"]
```

## 依赖原则

- 下一步 agent 默认优先消费“上一步正式通过的 YAML”，不是随手复制上一轮聊天记录
- `meta.source_paths` 用于主产物串联上游上下文
- `meta.subject_path` 用于 reviewer 明确指向当前被审对象
- `meta.step_id` 用于测试过程中的人工追踪
