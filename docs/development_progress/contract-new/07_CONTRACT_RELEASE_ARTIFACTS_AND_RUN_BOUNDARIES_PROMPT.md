# Contract New Step 7 Prompt

你现在只负责 `contract-new` 的第七步执行。

这一轮的目标是把 contract 阶段从“能跑通”修正为“能交付正式下游输入”。

不要重做 `contract-new` 前六步，不要重新讨论主链。

## 必须先读取

- /Users/wangwenjie/project/archetype-admin-path/docs/development_progress/contract-new/README.md
- /Users/wangwenjie/project/archetype-admin-path/docs/development_progress/contract-new/CONTRACT_NEW_FULL_DIRECTION.md
- /Users/wangwenjie/project/archetype-admin-path/docs/development_progress/contract-new/06_CONTRACT_RUN_STANDARDIZATION_AND_HUMAN_OUTPUT_WORKPLAN.md
- /Users/wangwenjie/project/archetype-admin-path/docs/development_progress/contract-new/07_CONTRACT_RELEASE_ARTIFACTS_AND_RUN_BOUNDARIES_WORKPLAN.md
- /Users/wangwenjie/project/archetype-admin-path/docs/development_progress/pending/CONTRACT_RUN_ISOLATION_DISCUSSION.md
- /Users/wangwenjie/project/archetype-admin-path/docs/development_progress/PENDING_ITEMS.md

## 当前问题

最新跑出的 contract runs 已经到 `released`，但仍有几个问题：

1. `contract/release/openapi.yaml` 存在，但 `paths` 和 `components.schemas` 为空。
2. release 包没有明确冻结的正式 `contract.yaml`。
3. human 会自然去看顶层 `rendered/`，但 contract 的 rendered 产物在 `contract/working/rendered/`。
4. contract 执行容易一次性从 `contract-01` 跑到 release，没有真正停在独立 review gate。
5. contract run 名称没有日期前缀，和 init / prd run 风格不一致。
6. contract release 现在会回写上游 PRD run，这和“run 独立隔离”的设计冲突。

## 本轮不要拆成 08

这轮先作为一个完整 Step 7 执行，但必须分阶段提交和验证。

如果发现某个阶段过大，先停下来说明具体阻塞，不要擅自把一半规则落地、一半规则留旧逻辑。

## 绝对边界

1. 不要把空 `openapi.yaml` 当成功 release。
2. 不要让 `build_release.rb` 自己猜没有定义过的 API 路由。
3. 不要让主执行 agent 自己 review 自己的 contract spec。
4. 不要在 contract 阶段回写上游 PRD run。
5. 不要修改其它 contract run 的状态。
6. 不要只改脚本，不同步 prompt、template、reviewer checklist、smoke。

## 执行顺序

### 1. 全链路扫描

用 `rg` 扫描：

- `openapi`
- `schemas`
- `paths`
- `contract/release`
- `contract/working/rendered`
- `review_complete`
- `advance_after_release`
- `contract-batch-`
- `pending_dependencies`

覆盖脚本、模板、prompt、reviewer、smoke。

### 2. 强化 contract_spec 模型

让 `contract_spec` 明确包含 API endpoint surface。

不要只靠 `queries` / `commands` 名字猜 OpenAPI。

至少支持：

- endpoint path
- method
- operation_id
- request parameters
- request body
- response schema
- error responses

更新 template、validator、review checklist 和 smoke fixtures。

### 3. 修正 release 包

`contract/release/` 必须生成：

```text
contract.yaml
contract.summary.md
openapi.yaml
openapi.summary.md
develop-handoff.md
```

`openapi.yaml` 必须有非空：

- `paths`
- `components.schemas`

缺任何一个都应 release fail。

### 4. 调整 rendered 入口

顶层 `rendered/` 应成为 human 主入口。

至少生成：

```text
rendered/contract-01.scope_intake.md
rendered/contract-02.domain_mapping.md
rendered/contract-03.contract_spec.md
rendered/contract-04.review.md
rendered/release.contract.md
rendered/release.openapi.summary.md
```

### 5. 加硬 review gate

主 agent 执行到 `contract-03` 后必须停。

review 必须由独立 reviewer prompt / 独立上下文完成。

只有 review 通过后，`review_complete.rb` 才能 build release。

### 6. 调整 contract run 命名

新 contract run 使用：

```text
runs/YYYY-MM-DD-contract-<flow-id>
```

所有输出、索引、smoke 都必须使用实际 run 路径。

不要再让下游靠 `runs/YYYY-MM-DD-contract-<flow-id>` 猜路径。

### 7. 移除 contract 回写 PRD run

PRD run 是上游事实，`prd-05` 后冻结。

contract 阶段只能：

- 读取 PRD run
- 读取依赖 contract run
- 修改当前 contract run

不能：

- 回写 PRD run
- 修改其它 contract run

依赖是否满足，通过读取依赖 run 的 release/review 产物判断。

## 验收要求

完成后必须证明：

1. 三个 contract run 都有正式 release 包。
2. `contract/release/contract.yaml` 存在。
3. `contract/release/openapi.yaml` 的 `paths` 和 `components.schemas` 非空。
4. 顶层 `rendered/` 有可读 contract 产物。
5. contract run 名称带日期。
6. release 不回写上游 PRD run。
7. 独立 review gate 没有被绕过。

至少运行：

```bash
ruby scripts/contract/full_stack_smoke.rb
git diff --check
```

如果 smoke 需要更新，必须说明更新后的断言覆盖了什么新规则。
