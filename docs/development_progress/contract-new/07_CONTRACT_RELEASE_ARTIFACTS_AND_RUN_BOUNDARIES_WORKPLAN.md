# [COMPLETED] Contract New Step 7 Workplan

这一步是 `contract-new` 的第七轮修正。

第六步已经把 `prd-05 -> contract run` 的标准外壳和 human 回报体验收稳。第七步要把 contract 从“能跑通”提升到“产物可以作为正式下游输入”。

## 本轮判断

本轮不拆成 `07` / `08`。

原因：

- Swagger/OpenAPI 为空壳、final contract 没有明确 release 形态、review 门禁不够硬，属于同一个 release 质量问题。
- `contract` run 命名和 PRD run 隔离，会影响 `prd-05` 输出路径、依赖检查、release 后状态推进，也和正式产物消费方式强相关。
- 如果拆开，下一轮会继续在一个边界不清的 contract run 上补 Swagger，容易继续产生假完成。

因此第七步作为一个完整收口迭代，但执行时必须分阶段推进，每个阶段都有 smoke。

## 本轮目标

把 contract 阶段收口为：

```text
prd-05 生成标准 contract runs
  -> 单个 contract run 独立执行
  -> 独立 review gate
  -> release 包含 frozen contract + 非空 OpenAPI/Swagger
  -> develop 只消费 contract/release/
```

## 要解决的问题

### 1. OpenAPI/Swagger 现在是空壳

当前 `contract/release/openapi.yaml` 会生成，但只有 `info`、`tags` 和 `x-contract-run`，`paths` 与 `components.schemas` 为空。

这不应作为正式 swagger 产物通过 release。

第七步必须让 release 至少满足：

- `openapi.yaml` 有非空 `paths`
- `openapi.yaml` 有非空 `components.schemas`
- 每个 query / command 都能映射到明确 operation
- review 必须能阻止空 Swagger 被 release

### 2. Release 包缺少“正式 contract”概念

当前 `contract-03.contract_spec.yaml` 是过程态，release 里只有 OpenAPI、summary 和 develop handoff。

正式 downstream 需要同时拿到：

- frozen contract
- Swagger/OpenAPI
- human summary
- develop handoff

第七步应明确 release 包为：

```text
contract/release/
  contract.yaml
  contract.summary.md
  openapi.yaml
  openapi.summary.md
  develop-handoff.md
```

说明：

- `contract.yaml` 是通过 review 的 `contract-03.contract_spec.yaml` 冻结副本。
- `contract.summary.md` 是 human 可读的正式 contract 摘要。
- `openapi.yaml` 是可被下游工具消费的 Swagger/OpenAPI。
- `develop-handoff.md` 告诉 develop 只消费 release 包，不读 working 草稿。

### 3. `rendered/` 结构与 init / prd 不一致

当前 contract 的可读渲染在 `contract/working/rendered/`，顶层 `rendered/` 基本空着。

这和 init / prd 的心智模型不一致。

第七步应统一为：

```text
runs/<contract-run>/
  rendered/
    contract-01.scope_intake.md
    contract-02.domain_mapping.md
    contract-03.contract_spec.md
    contract-04.review.md
    release.contract.md
    release.openapi.summary.md
  contract/
    working/
      contract-01.scope_intake.yaml
      contract-02.domain_mapping.yaml
      contract-03.contract_spec.yaml
      contract-04.review.yaml
    release/
      contract.yaml
      contract.summary.md
      openapi.yaml
      openapi.summary.md
      develop-handoff.md
```

要求：

- 顶层 `rendered/` 是 human 阅读入口。
- `contract/working/` 是机器过程态 YAML。
- `contract/release/` 是正式下游消费入口。
- 不再让 human 去 `contract/working/rendered/` 找主阅读材料。

如果保留 `contract/working/rendered/` 作为兼容路径，也必须明确它不是主入口。

### 4. Review gate 必须真的成为门禁

当前实际执行体验里，AI 容易一次性把一个 contract run 从 `contract-01` 跑到 release，中间没有真正停下来做独立 review。

第七步必须修正：

- 主执行 agent 到 `contract-03` 后必须停止。
- `contract-04.review.yaml` 必须由独立 reviewer 上下文或 reviewer agent 生成。
- `review_complete.rb` 只能在 review 允许 release 后构建 release 包。
- release 前必须检查 `contract.yaml`、`openapi.yaml`、`openapi.summary.md` 的完整性。

提示词和脚本都要避免让同一个 agent 在一个上下文里“自己写 spec、自己 review、自己 release”。

### 5. Contract run 命名需要日期前缀

当前 contract run 是：

```text
runs/YYYY-MM-DD-contract-batch-foundation-access
runs/YYYY-MM-DD-contract-batch-account-access
runs/YYYY-MM-DD-contract-batch-capability-components
```

这和 init / prd 的 run 命名风格不一致。

第七步应改为：

```text
runs/YYYY-MM-DD-contract-batch-foundation-access
runs/YYYY-MM-DD-contract-batch-account-access
runs/YYYY-MM-DD-contract-batch-capability-components
```

要求：

- `run.yaml` 中继续保留稳定 `flow_id`。
- `prd-05` 输出必须列出实际 run 路径，不能再让下游靠 `flow_id` 猜路径。
- `contract_handoff.index.yaml` 或等价索引中应记录每个 flow 的实际 run id / run root。
- 所有 smoke 不能硬编码旧的 `runs/contract-*` 路径。

### 6. PRD run 作为上游事实，contract 不应回写

第六步后发现 contract release 会回写上游 PRD run 的状态或 handoff。

第七步应执行这个边界：

```text
PRD run：只读，作为上游输入快照
contract run：只改自己
依赖状态：由当前 contract run 读取和检查，不回写上游
```

要求：

- `prd-05` 可以生成 handoff 和 contract run shell。
- `prd-05` 之后，PRD run 冻结。
- contract 阶段可以读取上游 PRD run。
- contract 阶段可以读取依赖 contract run 的 release 状态。
- contract 阶段不能修改上游 PRD run。
- contract 阶段不能修改其他 contract run。

依赖未满足时，当前 contract run 应停止并提示 human，而不是回写上游或修改依赖 run。

详细背景见：

- [CONTRACT_RUN_ISOLATION_DISCUSSION.md](/Users/wangwenjie/project/archetype-admin-path/docs/development_progress/pending/CONTRACT_RUN_ISOLATION_DISCUSSION.md)

## 实施阶段

### Phase A. 扫描现有入口

必须先扫描以下入口，不允许只改 `build_release.rb`：

- `scripts/create_run.rb`
- `scripts/prd/review_complete.rb`
- `scripts/contract/init_flow_run.rb`
- `scripts/contract/continue_run.rb`
- `scripts/contract/finalize_step.rb`
- `scripts/contract/review_complete.rb`
- `scripts/contract/build_release.rb`
- `scripts/contract/handoff_generation.rb`
- `scripts/contract/workflow_manifest.rb`
- `scripts/contract/progress_board.rb`
- `docs/templates/autonomous-run-prompt.contract.template.md`
- `docs/templates/workflow-progress.template.md`
- `docs/contract/templates/structured/contract_spec.template.yaml`
- `docs/contract/reviewer/checklists/contract_spec_ready.md`
- `docs/contract/prompts/`
- `docs/contract/steps/`
- `scripts/contract/*smoke*.rb`

重点搜索：

- `openapi`
- `schemas`
- `paths`
- `contract/release`
- `contract/working/rendered`
- `review_complete`
- `advance_after_release`
- `contract-batch-`
- `pending_dependencies`

### Phase B. 强化 contract_spec 到 OpenAPI 的输入模型

不要让 `build_release.rb` 猜路由。

应在 `contract_spec` 中明确 API surface，例如：

```yaml
api_surface:
  endpoints:
    - operation_id: listAccountProfiles
      method: GET
      path: /accounts
      summary: List account profiles
      request:
        query:
          - name: page
            schema: integer
      response:
        status: 200
        schema: AccountProfileListResponse
      errors:
        - status: 403
          code: forbidden
```

要求：

- 更新 contract spec 模板。
- 更新 validator，禁止 `decision.allow_review=true` 但 endpoints 为空。
- 更新 reviewer checklist，明确检查 endpoint / schema / query / command 是否完整。
- 更新 smoke fixture。

### Phase C. 生成正式 release 包

`build_release.rb` 应生成：

- `contract/release/contract.yaml`
- `contract/release/contract.summary.md`
- `contract/release/openapi.yaml`
- `contract/release/openapi.summary.md`
- `contract/release/develop-handoff.md`

`openapi.yaml` 至少要从 `api_surface.endpoints` 和 resource/schema 定义生成：

- `paths`
- `operationId`
- `parameters`
- `requestBody`
- `responses`
- `components.schemas`

如果缺失必要字段，release 必须失败。

### Phase D. 调整 rendered 主入口

把 contract 可读渲染主入口改到顶层 `rendered/`：

- `render_artifact.rb`
- `workflow_manifest.rb`
- `progress_board.rb`
- `continue_run.rb`
- `finalize_step.rb`
- smoke

都要统一使用新路径。

### Phase E. 加硬 review gate

修改 agent prompt / runbook / scripts，使 contract 执行到 `contract-03` 后停住：

- 主 agent 生成 `contract-03.contract_spec.yaml` 和 rendered spec 后停止。
- reviewer 通过独立 prompt 或独立上下文生成 `contract-04.review.yaml`。
- 只有 `review_complete.rb` 能进入 release。
- human 回报必须明确“等待独立 review”或“release 已生成”。

### Phase F. 日期化 contract run 命名

修改 contract run 创建逻辑：

- 新 run 使用 `YYYY-MM-DD-contract-<flow-id>`。
- `run.yaml` 保留 `flow_id`。
- `prd-05` 输出使用实际路径。
- 查找依赖 run 时不能只靠 `runs/YYYY-MM-DD-contract-<flow-id>` 拼路径。

### Phase G. 移除下游回写上游 PRD run

禁止 contract release 修改上游 PRD run。

重点检查并处理：

- `ContractFlow::HandoffGeneration.advance_after_release!`
- `scripts/contract/build_release.rb`
- `scripts/contract/review_complete.rb`
- 依赖解锁相关 smoke

替代规则：

- 当前 contract run 读取依赖 run 的 release 包判断是否可继续。
- 依赖未满足时停止并提示。
- 不回写 `runs/<prd-run>/contract_handoff/`。

## 完成标准

1. 三个 contract run 的 release 包都有 `contract.yaml` 和非空 `openapi.yaml`。
2. `openapi.yaml` 的 `paths` 和 `components.schemas` 不为空。
3. 顶层 `rendered/` 能看到 contract 的人类可读产物。
4. contract 执行不会跳过独立 review gate。
5. 新 contract run 命名带日期前缀。
6. contract 执行不会回写上游 PRD run 或其它 contract run。
7. `full_stack_smoke` 或等价主链 smoke 覆盖以上行为。

## 必跑验证

至少运行：

```bash
ruby -c scripts/contract/build_release.rb
ruby -c scripts/contract/review_complete.rb
ruby -c scripts/contract/finalize_step.rb
ruby scripts/contract/full_stack_smoke.rb
git diff --check
```

并新增或更新断言：

- `openapi.yaml paths.size > 0`
- `components.schemas.size > 0`
- release 包包含 `contract.yaml`
- 顶层 `rendered/` 包含 contract render
- `build_release.rb` 不修改上游 PRD run
- pending dependency run 只读依赖状态，不回写其它 run
