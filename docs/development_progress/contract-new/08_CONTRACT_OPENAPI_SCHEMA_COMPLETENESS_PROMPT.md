# Contract New Step 8 Prompt

你现在只负责 `contract-new` 的第八步执行。

这一轮目标：把 contract release 的 Swagger 从“非空”提升为“可被 develop 消费”。重点是让 `contract_spec` 明确定义 request/response schema，并让 `build_release.rb` 只做机械转换，不再猜 schema。

不要重做前七步，不要修改测试 run 现场来伪造成功。

## 必须先读取

- /Users/wangwenjie/project/archetype-admin-path/docs/development_progress/contract-new/README.md
- /Users/wangwenjie/project/archetype-admin-path/docs/development_progress/contract-new/07_CONTRACT_RELEASE_ARTIFACTS_AND_RUN_BOUNDARIES_WORKPLAN.md
- /Users/wangwenjie/project/archetype-admin-path/docs/development_progress/contract-new/08_CONTRACT_OPENAPI_SCHEMA_COMPLETENESS_WORKPLAN.md
- /Users/wangwenjie/project/archetype-admin-path/docs/contract/templates/structured/contract_spec.template.yaml
- /Users/wangwenjie/project/archetype-admin-path/scripts/contract/artifact_utils.rb
- /Users/wangwenjie/project/archetype-admin-path/scripts/contract/build_release.rb
- /Users/wangwenjie/project/archetype-admin-path/docs/contract/reviewer/checklists/contract_spec_ready.md
- /Users/wangwenjie/project/archetype-admin-path/docs/templates/autonomous-run-prompt.contract.template.md

## 当前已知背景

第七步已经解决了空 Swagger 问题的第一层：`openapi.yaml` 不应再是空 `paths` / 空 `components.schemas`。

但现在仍可能出现第二层假成功：

```yaml
components:
  schemas:
    SomeResponse:
      type: object
      properties: {}
```

这不应算可消费 Swagger。

补充决策：

- 下游 flow 默认复用上游 release 的资源和 schema，不静默重定义同名内容。
- 没有特殊 PRD 要求时，认证、租户、错误响应和分页使用固定通用规则。
- schema 可以支持 `example` / `examples`，但完整 mock server、mock 数据目录和前端 mock 切换方案放到后续 Step 9+。
- 多 flow develop 入口、develop 执行顺序索引和并行/换序策略放到后续 Step 9+。

## 绝对边界

1. 不要修改 `runs/` 测试现场来制造通过结果。
2. 不要让 `build_release.rb` 自动补空 object schema。
3. 不要只改 prompt，不改 validator / release / smoke。
4. 不要实现完整 OpenAPI schema DSL，本轮只做最小可消费子集。
5. 不要进入 develop 阶段。
6. 不要让 human 手工整理 reviewer 材料；contract run 应提供可直接交给独立 reviewer 子 agent 的启动提示词。
7. 不要生成完整 mock server 或前端 mock 切换实现。
8. 不要生成多 flow develop index。

## 执行顺序

### 1. 扫描现状

用 `rg` 扫描：

- `api_surface`
- `schemas`
- `components.schemas`
- `properties`
- `request.body`
- `response.schema`

覆盖脚本、模板、prompt、reviewer checklist、smoke。

### 2. 扩展 contract_spec 模板

在 `api_surface` 下补 `schemas` 定义区。

最小 schema 结构支持：

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

同时补最小公共约定：

- 统一 security scheme
- 统一 `ErrorResponse`
- 统一 pagination schema
- 依赖 flow 定义默认复用，不静默重定义

### 3. 强化 validator

在 `scripts/contract/artifact_utils.rb` 中确保：

- `decision.allow_review=true` 时 `api_surface.schemas` 非空。
- endpoint 的 `request.body` 和 `response.schema` 必须能在 schemas 中找到。
- schema properties 不允许为空，除非显式允许空响应。
- required 字段必须存在于 properties。
- property 至少有 `type` 或 `$ref`。
- 受保护 endpoint 必须使用统一 security scheme，公开 endpoint 必须显式标记。
- error response 必须引用统一 `ErrorResponse` 或说明特殊结构。
- 列表 endpoint 必须使用统一 pagination 结构。
- 当前 flow 不允许静默重定义依赖 flow 已有同名 schema/resource。

### 4. 修正 release 生成

在 `scripts/contract/build_release.rb` 中确保：

- `components.schemas` 来自 `api_surface.schemas`。
- 不再自动补空 object。
- 引用缺失或 schema 空壳时 release fail。
- OpenAPI 输出仍保留 `paths`、`tags`、`x-contract-run`、review/source 追踪。
- OpenAPI 输出应包含统一 `components.securitySchemes`、`ErrorResponse` 和 pagination schema。
- OpenAPI 应保留 schema 上的 `example` / `examples`，但本轮不生成完整 mock 数据。

### 5. 更新 reviewer / prompt

同步更新：

- `docs/contract/reviewer/checklists/contract_spec_ready.md`
- `docs/contract/prompts/contract_spec/STEP_PROMPT.md`
- `docs/contract/prompts/review/STEP_PROMPT.md`
- `docs/templates/autonomous-run-prompt.contract.template.md`
- contract run 内 reviewer prompt 生成逻辑

让 AI 和 reviewer 都明确：endpoint 之外必须写 schema 字段。

同时让 reviewer 明确检查：

- 是否静默重定义依赖 flow 的同名资源或 schema。
- 是否使用统一认证、租户、错误和分页规则。
- schema example 是否有助于后续 mock，但不把 mock 生成当成本轮必做。

同时让每个 contract run 在进入 `Waiting for Review` 前准备：

```text
prompts/contract-04-reviewer-prompt.md
```

这个 prompt 必须能直接交给独立 reviewer 子 agent，包含被审查 spec、review 输出路径、必读 reviewer 材料和禁止主 agent 自审的约束。

### 6. 补 smoke

补正向和反向断言：

- 正向：release 后 OpenAPI schemas 有字段。
- 反向：缺 schema / 空 properties 不允许通过 validator 或 release。
- 反向：依赖 flow 同名 schema/resource 被静默重定义时应失败或被 review 阻塞。
- 正向：统一 `ErrorResponse`、security scheme、pagination schema 能进入 OpenAPI。

优先改现有 smoke，避免新增一条难维护的大脚本。

## 验收命令

至少运行：

```bash
ruby -c scripts/contract/artifact_utils.rb
ruby -c scripts/contract/build_release.rb
ruby scripts/contract/full_stack_smoke.rb
git diff --check
```

如果没有跑全量 smoke，必须说明具体原因和已跑的替代验证。

## 最终回报

完成后按这个结构汇报：

1. `contract_spec` schema 模型补了什么。
2. validator 新挡住了哪些假成功。
3. `build_release.rb` 如何生成 OpenAPI schemas。
4. reviewer / prompt 同步改了哪些，run 内 reviewer 启动提示词生成在哪里。
5. 统一认证、租户、错误、分页和依赖复用规则如何落地。
6. smoke 覆盖了哪些正反场景。
7. 哪些验证已通过，哪些没有跑。
