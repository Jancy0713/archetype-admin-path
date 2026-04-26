# Contract New Step 8 Workplan

这一步是 `contract-new` 的第八轮修正。

第七步已经把 contract release 从“空 Swagger”修到“能生成非空 OpenAPI”。第八步要继续补强：OpenAPI 不能只是非空，必须具备可被 develop 消费的 schema 字段结构。

## 本轮判断

这不是大重构，但不能当零散小修处理。

原因：

- 需要同时改 `contract_spec` 模型、validator、reviewer checklist、release 生成和 smoke。
- 如果只改 `build_release.rb`，release 仍然会从不完整输入里猜 schema。
- 如果只改 prompt，AI 仍可能写出 endpoint 非空但 schema 空壳的 contract。

因此本轮作为独立 Step 8 执行。

## 本轮新增决策

1. **依赖 flow 默认复用，不重定义**  
   下游 flow 如果需要使用上游 flow 已 release 的资源、schema 或公共语义，默认应复用上游定义。不得在当前 flow 静默重新定义同名资源或 schema。

2. **公共协议先固定通用规则**  
   如果 PRD 没有明确特殊要求，contract 阶段默认采用统一的通用规则，不为每个 flow 自行发明：

   - 认证：受保护接口统一使用当前登录会话安全方案；登录接口除外。
   - 租户：租户上下文默认来自会话，不由客户端随意传 `tenant_id`。
   - 错误：统一使用稳定 `ErrorResponse` envelope。
   - 分页：列表接口统一使用 `page`、`page_size` 请求参数和 `pagination` 响应结构。

3. **example 可以先进入 schema，完整 mock 流程后置**  
   本轮 schema 模型应允许字段或 schema 携带 `example` / `examples`，方便后续 mock。  
   但本轮不强制生成完整 mock server、mock 数据目录或前端 mock 切换方案；这些放到后续 Step 9+ 统一规划。

4. **多 flow develop 入口后置**  
   当前 develop 正常顺序按 contract handoff 的固定顺序执行：先第 1 批，再第 2 批，再第 3 批。  
   本轮不处理 human 任意换顺序、并行 develop 或多 flow 聚合 develop index；这些放到 Step 9+。

## 要解决的问题

### 1. Swagger 可能仍是“可生成但不可消费”

第七步后 `openapi.yaml` 理论上会包含：

- 非空 `paths`
- 非空 `components.schemas`

但当前 `build_release.rb` 可能为 endpoint 引用的 schema 自动补：

```yaml
type: object
properties: {}
```

这种不应算正式可消费 Swagger。

### 2. `contract_spec` 缺少正式 schema 定义区

当前 `contract_spec` 有：

- `resource_contracts`
- `consumer_views`
- `query_and_command_semantics`
- `api_surface.endpoints`

但没有强制要求：

```yaml
api_surface:
  schemas:
    PasswordLoginRequest:
      type: object
      required: []
      properties: {}
```

导致 endpoint 可以引用 schema 名称，但 schema 字段内容没有正式来源。

### 3. Reviewer 还不能阻止 schema 空壳

reviewer checklist 当前重点检查 endpoint 是否存在，但没有明确要求检查：

- endpoint 引用的 request/response schema 是否都存在
- schema 是否有字段
- required 字段是否合理
- error response 是否有稳定结构

同时，当前 contract 主执行 agent 停在 `contract-03` 后，只用自然语言提示“等待 review”。这还不够稳定。

本轮应让 contract run 生成明确的 reviewer 启动提示词，例如：

```text
prompts/contract-04-reviewer-prompt.md
```

这个提示词必须能直接交给独立 reviewer 子 agent 使用，不能让 human 自己整理 reviewer 材料。

### 4. 缺少回归断言

现有 smoke 需要补一类断言：

- `components.schemas` 不只是非空
- endpoint 引用的 schema 都能在 `components.schemas` 找到
- 关键 schema 的 `properties` 不为空
- release 不允许自动生成空 object 占位 schema

### 5. 下游 flow 可能静默重定义上游定义

例如第 1 批已经定义 `AuthSession`、`TenantContext`、`RoleGrant` 后，第 2 批如果继续需要这些定义，应该复用第 1 批 release，而不是在第 2 批重新写一套同名 schema。

本轮应补：

- prompt 明确“依赖 flow 定义默认复用”
- reviewer 检查同名资源 / schema 是否误重定义
- validator 尽量阻止明显的同名本地重定义

### 6. 公共错误、认证、分页协议需要固定默认值

如果每个 flow 自己定义错误结构、认证方式或分页结构，develop 仍然会遇到碎片化协议。

本轮应补最小公共约定：

- 统一 `ErrorResponse`
- 统一 security scheme
- 统一 tenant context 来源规则
- 统一 pagination 请求和响应结构

## 本轮目标

把 release 链路改成：

```text
contract-03.contract_spec.yaml
  -> api_surface.endpoints
  -> api_surface.schemas
  -> contract-04 reviewer gate
  -> contract/release/openapi.yaml
```

其中：

- `contract_spec` 是 schema 真相源。
- `build_release.rb` 只做机械转换，不猜字段。
- reviewer 必须审 schema 完整性。
- smoke 必须能抓住空 schema 假成功。

## 实施范围

### Phase A. 扫描现有入口

必须先扫描：

- `docs/contract/templates/structured/contract_spec.template.yaml`
- `scripts/contract/artifact_utils.rb`
- `scripts/contract/build_release.rb`
- `scripts/contract/render_artifact.rb`
- `docs/contract/reviewer/checklists/contract_spec_ready.md`
- `docs/contract/prompts/contract_spec/STEP_PROMPT.md`
- `docs/contract/prompts/review/STEP_PROMPT.md`
- `docs/templates/autonomous-run-prompt.contract.template.md`
- `scripts/contract/*smoke*.rb`

重点搜索：

- `api_surface`
- `schemas`
- `components.schemas`
- `properties`
- `request.body`
- `response.schema`

### Phase B. 扩展 contract_spec 模型

在 `contract_spec.template.yaml` 中补：

```yaml
api_surface:
  endpoints: []
  schemas:
    ExampleSchema:
      type: object
      required: []
      properties:
        id:
          type: string
```

最小支持字段：

- `type`
- `required`
- `properties`
- property 的 `type`
  - 可选 `description`
  - 可选 `enum`
  - 可选 `items`
  - 可选 `$ref`
  - 可选 `example`
  - 可选 `examples`

同时补公共定义区或约定区，用于表达：

- 统一 security scheme
- 统一 error envelope
- 统一 pagination schema
- 依赖 flow 复用定义

不要一开始实现完整 OpenAPI Schema 全量 DSL，只做当前 contract 需要的最小可消费子集。

### Phase C. 强化 validator

`scripts/contract/artifact_utils.rb` 必须新增校验：

1. `decision.allow_review=true` 时，`api_surface.schemas` 必须非空。
2. 每个 endpoint 的 `request.body` 如果非空，必须在 `api_surface.schemas` 中存在。
3. 每个 endpoint 的 `response.schema` 必须在 `api_surface.schemas` 中存在。
4. 每个 schema 至少要有非空 `properties`，除非它显式声明为允许无 body 的响应类型。
5. 每个 property 至少要有 `type` 或 `$ref`。
6. `required` 中的字段必须存在于 `properties`。
7. 当前 flow 如果定义了与依赖 flow 同名的 schema/resource，必须显式说明是复用、扩展还是覆盖；默认不允许静默覆盖。
8. 受保护 endpoint 必须使用统一 security scheme；登录等公开 endpoint 必须显式标记为 public。
9. error response 必须引用统一 `ErrorResponse` 或明确说明本 flow 的特殊错误结构。
10. 列表 endpoint 如果出现分页，必须使用统一 pagination 结构。

### Phase D. 修正 build_release

`scripts/contract/build_release.rb` 必须：

1. 从 `api_surface.schemas` 生成 `components.schemas`。
2. 不再自动补 `{ type: object, properties: {} }`。
3. endpoint 引用缺失 schema 时 fail。
4. schema properties 为空时 fail，除非 schema 明确允许空结构。
5. 生成 OpenAPI 前后都做完整性检查。
6. 生成统一 `components.securitySchemes`。
7. 将统一 `ErrorResponse` 和 pagination schema 写入 `components.schemas`。
8. 保留 schema 上的 `example` / `examples`，但不在本轮生成完整 mock 数据。

### Phase E. 更新 reviewer 和 prompt

更新：

- contract spec step prompt
- reviewer prompt
- reviewer checklist
- autonomous contract run prompt
- contract run 内 reviewer 启动提示词生成逻辑

要求 AI 在 `contract-03` 中同时写：

- endpoint
- request schema
- response schema
- error schema 或稳定 error shape

reviewer 必须检查 schema 是否足够 develop 消费。

同时 reviewer 必须检查：

- 下游 flow 是否静默重定义了依赖 flow 的同名资源或 schema。
- 受保护接口是否使用统一认证规则。
- tenant context 是否来自会话，而不是让客户端自由传租户。
- 错误响应是否使用统一 `ErrorResponse`。
- 列表接口是否使用统一分页协议。

contract 主执行 agent 停止后，必须明确指向 run 内 reviewer prompt：

```text
prompts/contract-04-reviewer-prompt.md
```

该 prompt 至少应包含：

- 当前 contract run 路径
- 被审查的 `contract-03.contract_spec.yaml`
- reviewer 输出路径 `contract/working/contract-04.review.yaml`
- reviewer 渲染路径 `rendered/contract-04.review.md`
- reviewer 必读材料
- 禁止主 agent 自审的约束
- review 通过后再由主流程执行 `scripts/contract/review_complete.rb`

### Phase F. 补 smoke

至少补两类 smoke：

1. 正向：一个 contract spec 带 endpoint + schema，release 后 OpenAPI 有非空 paths 和带字段的 components.schemas。
2. 反向：endpoint 引用缺失 schema 或 schema properties 为空时，validator / release 必须失败。
3. 反向：依赖 flow 已有同名 schema 时，当前 flow 静默重定义应失败或被 reviewer checklist 明确阻塞。
4. 正向：统一 `ErrorResponse`、security scheme 和 pagination schema 能进入 release OpenAPI。

优先复用现有 contract smoke，不要新增一条难维护的大型端到端脚本。

## 不做范围

- 不实现完整 OpenAPI 3.1 schema DSL。
- 不进入 develop 阶段。
- 不生成真实业务代码。
- 不生成完整 mock server 或前端 mock 切换实现。
- 不生成多 flow develop index。
- 不修改测试 run 现场来伪造成功。
- 不把 schema 字段从前端代码或后端代码反推回来。

## 验收标准

1. `contract_spec` 模板包含 `api_surface.schemas`。
2. validator 能阻止 endpoint 引用不存在的 schema。
3. validator 能阻止空 properties schema 被当作正式 schema。
4. reviewer checklist 明确检查 schema 完整性。
5. contract run 会生成可交给独立 reviewer 子 agent 的 reviewer 启动提示词。
6. `build_release.rb` 不再自动生成空 object schema。
7. 下游 flow 默认复用上游 release 定义，不静默重定义同名资源或 schema。
8. release 后的 `openapi.yaml` 中：
   - `paths` 非空
   - `components.schemas` 非空
   - endpoint 引用的 schema 都存在
   - 关键 schema 有字段
   - 有统一 `ErrorResponse`
   - 有统一 security scheme
   - 列表接口有统一 pagination 结构
9. smoke 覆盖正向和反向场景。

## 建议验证命令

```bash
ruby -c scripts/contract/artifact_utils.rb
ruby -c scripts/contract/build_release.rb
ruby scripts/contract/full_stack_smoke.rb
git diff --check
```

如果 full stack smoke 过重，至少先跑新增/修改的 schema release smoke，再说明未跑全量的原因。
