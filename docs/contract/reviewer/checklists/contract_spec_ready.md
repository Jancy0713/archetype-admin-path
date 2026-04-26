# Reviewer Checklist: contract_spec_ready

## 当前用途

这份清单当前对应 `contract_spec` 的正式 reviewer gate，是 release 前的硬门禁材料。

## 必查项

1. 当前 `contract_spec` 是否仍然在本 flow 范围内，没有越界到其他 flows。
2. 是否覆盖了上游 handoff 要求的关键 `required_contract_views`。
3. 必须包含物理 `api_surface.endpoints` 定义：
   - 每个 query / command 必须具备明确的 API 终端映射。
   - API 终端必须有明确的 request/response schema。
4. 当前 spec 是否足够支撑前端、后端、AI 或脚本消费，而不是还需要大量补猜。
5. 资源、字段、状态、权限、错误语义是否已经达到关键完整度。
6. 是否存在未确认事实被写成正式协议。
7. 是否错误重定义了前序 released contract 中已有的共享对象。
8. 是否引用了未正式 release、不可追踪的外部中间状态。
9. 命名、术语、状态和枚举是否前后一致。

## 放行标准

只有当下面条件成立时，才允许进入 `release`：

1. `contract_spec` 与上游 `scope_intake`、`domain_mapping` 和 `final_prd` handoff 一致。
2. 当前 flow 的关键 consumer views 已具备可消费完整度。
3. reviewer 没有识别 blocking issue。
4. 当前 spec 的依赖与引用关系清楚且稳定。
5. 当前结果已足够成为后续 release 消费方的正式输入。

## 典型阻塞信号

以下情况通常应直接阻塞：

1. 关键 consumer view 缺失。
2. 关键资源或动作协议仍然模糊。
3. 关键字段语义或状态语义仍需下游自行猜测。
4. 当前 spec 越过当前 flow 边界。
5. 共享定义与新增定义混淆，无法判断应复用还是应新增。
