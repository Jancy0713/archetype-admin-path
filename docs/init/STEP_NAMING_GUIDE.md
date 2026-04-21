# Init 步骤编号指南

## 结论

建议引入 `init-01` 这种步骤编号，但不要只靠文件名承载流程语义。

更稳妥的做法是：

- `artifact_type` 继续表达产物语义，比如 `project_profile`、`review`、`baseline`
- `status.step` 继续表达流程关口语义，比如 `project_initialization`
- `meta.step_id` 表达测试时看的线性编号，比如 `init-01`
- 文件名只做展示层，推荐与 `meta.step_id` 保持一致

这样做的正向效果更大，因为：

- 你测试时一眼就能看到“现在在第几步”
- 上一步产物传给下一步 agent 时更直观
- reviewer、人工确认、脚本校验都更容易对齐到同一个步骤编号

纯文件名编号的负向点也要避免：

- 如果只改文件名，不补 YAML 元信息，后续很容易出现“文件叫 `init-02`，内容还是第一步”的错位
- `init` 流程里 `project_profile` 是一个阶段化画像，不像 `prd` 那样天然是线性的一次一产物；如果完全按文件名切分，很容易把重试、阶段推进、正式快照混在一起

所以这里采用的是“双标识”方案，而不是“文件名即真相”方案。

## 推荐命名

### 文件名

- `init-01.project_profile.yaml`
- `init-01.review.yaml`
- `init-02.project_profile.yaml`
- `init-02.review.yaml`
- `init-03.project_profile.yaml`
- `init-03.review.yaml`
- `init-04.project_profile.yaml`
- `init-04.review.yaml`
- `init-05.baseline.yaml`
- `init-06.design_seed.yaml`
- `init-07.bootstrap_plan.yaml`

### YAML 元信息

```yaml
meta:
  flow_id: init
  step_id: init-03
  artifact_id: init-03.project_profile
```

## 步骤与阶段映射

| step_id | 语义 | artifact_type |
| --- | --- | --- |
| `init-01` | `foundation_context` 阶段画像 | `project_profile` |
| `init-02` | `tenant_governance` 阶段画像 | `project_profile` |
| `init-03` | `identity_access` 阶段画像 | `project_profile` |
| `init-04` | `experience_platform` 阶段画像 | `project_profile` |
| `init-05` | 初始化基线定稿 | `baseline` |
| `init-06` | 设计约束基线 | `design_seed` |
| `init-07` | 初始化底座计划 | `bootstrap_plan` |
| `init-08` | 初始化执行 | `execution` |

说明：

- 同一步的 reviewer 产物复用同一个 `step_id`
- 同一步内的返工不升级 `step_id`，只增加 `status.attempt`
- 只有进入下一个正式阶段快照时，才进入新的 `step_id`
- `change_request` 保持为独立流程，不再占用 `init-08`

## 初始化命令示例

```bash
ruby scripts/init/profile/init_project_profile_step.rb runs/demo init-01
ruby scripts/init/profile/init_project_profile_review.rb runs/demo init-01
ruby scripts/init/foundation/prepare_baseline.rb runs/demo
```
