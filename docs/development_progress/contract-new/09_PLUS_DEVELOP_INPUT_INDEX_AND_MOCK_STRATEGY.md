# Contract New Step 9+ Planning: Develop Input Index And Mock Strategy

这份文档只记录 Step 8 之后的后续规划，不是当前要立即实现的工作。

## 背景

Step 8 负责把单个 contract flow 的 OpenAPI schema 做到可消费。

Step 8 完成后，下一层会出现两个自然问题：

1. 多个 flow release 后，develop 应该如何按顺序消费。
2. OpenAPI + schema 完整后，是否应生成 mock 数据或 mock 服务，让前端先基于 mock 开发。

## 当前决策

### 1. Develop 默认按固定顺序一个一个做

正常流程不考虑 human 随意换顺序，也不优先支持并行 develop。

默认顺序来自 `contract_handoff.recommended_flow_order`：

```text
第 1 批 -> 第 2 批 -> 第 3 批
```

只有当 contract handoff 明确说明某些 flow 可以并行，后续才考虑并行 develop。

### 2. Develop 不直接消费 working 草稿

develop 只消费每个 contract run 的：

```text
contract/release/
  contract.yaml
  contract.summary.md
  openapi.yaml
  openapi.summary.md
  develop-handoff.md
```

不读取：

```text
contract/working/
```

### 3. 后续应有一个 develop input index

Step 9 可考虑生成类似：

```text
develop_handoff/
  develop-input.index.yaml
  develop-input.md
```

它负责告诉 develop：

- 当前总共有几个 flow release
- 推荐执行顺序
- 当前推荐先做哪个 flow
- 每个 flow 的 release 路径
- 每个 flow 的依赖关系
- 每个 flow 的 develop 启动提示词

### 4. Mock 方案可以后置，但 schema 要提前留钩子

Step 8 应允许 schema 带：

- `example`
- `examples`

但完整 mock 方案后置。

后续 mock 方案应满足：

- 能从 `contract/release/openapi.yaml` 生成或读取 mock 数据。
- mock 数据结构和真实接口 schema 同源。
- 前端能方便切换 mock 和真实接口。
- mock 切换方案要可维护，不能在业务代码里到处散落 if/else。
- mock 层应服务开发和测试，不反向污染 contract 真相源。

### 5. 推荐 mock 方向

后续更合理的方向是：

```text
OpenAPI schema
  -> mock data fixtures
  -> mock adapter/server
  -> frontend API client
  -> runtime switch: mock / real
```

前端侧推荐保持：

- API client 层统一封装
- mock adapter 和 real adapter 共享同一接口
- 用环境变量或统一配置切换
- 测试用例优先消费 mock adapter

## 建议 Step 9 范围

Step 9 可以只做 develop input index，不一定同时做完整 mock。

建议 Step 9 最小目标：

1. 生成 multi-flow develop input index。
2. 给每个 flow 生成 develop 启动提示词。
3. 按固定顺序推荐 develop 执行。
4. 明确 mock 进入 Step 10 或后续测试流程。

## 建议 Step 10+ 范围

mock 和测试流程更适合单独做：

1. 从 OpenAPI 生成 mock fixtures。
2. 定义 mock / real API adapter 切换方式。
3. 接入前端开发和测试流程。
4. 让测试优先使用 mock 数据，再逐步切真实接口。
