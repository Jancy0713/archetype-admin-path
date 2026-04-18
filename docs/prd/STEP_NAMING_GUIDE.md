# PRD 步骤编号指南

## 结论

`prd` 流程天然是线性的，所以非常适合引入 `prd-01` 这种步骤编号。

这里同样采用“双标识”方案：

- `artifact_type` 表达产物类型
- `status.step` 表达流程语义
- `meta.step_id` 表达测试时看的步骤编号
- 文件名与 `meta.step_id` 对齐

## 推荐命名

### 文件名

- `prd-01.clarification.yaml`
- `prd-01.review.yaml`
- `prd-02.brief.yaml`
- `prd-03.decomposition.yaml`
- `prd-03.review.yaml`

### YAML 元信息

```yaml
meta:
  flow_id: prd
  step_id: prd-02
  artifact_id: prd-02.brief
```

## 步骤映射

| step_id | 语义 | artifact_type |
| --- | --- | --- |
| `prd-01` | 需求补充提问 | `clarification` |
| `prd-02` | 澄清版 brief | `brief` |
| `prd-03` | PRD 结构化拆解 | `decomposition` |

说明：

- reviewer 产物复用被审对象的 `step_id`
- 同一步返工不增加 `step_id`，只增加 `status.attempt`
- 正式进入下一步时，才创建新的 `step_id`

## 初始化命令示例

```bash
ruby scripts/prd/init_artifact.rb --step-id prd-01 clarification runs/demo/prd-01.clarification.yaml
ruby scripts/prd/init_artifact.rb --step requirement_clarification --step-id prd-01 review runs/demo/prd-01.review.yaml
ruby scripts/prd/init_artifact.rb --step-id prd-02 brief runs/demo/prd-02.brief.yaml
ruby scripts/prd/init_artifact.rb --step-id prd-03 decomposition runs/demo/prd-03.decomposition.yaml
```
