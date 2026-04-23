# PRD 2.0 步骤编号指南

## 结论

当前正式步骤命名如下：

| step_id | 语义 | artifact_type |
| --- | --- | --- |
| `prd-01` | 需求分析与拆分 | `analysis` |
| `prd-02` | 需求澄清与人工确认 | `clarification` |
| `prd-03` | 执行计划 | `execution_plan` |
| `prd-04` | 最终 PRD | `final_prd` |

review 产物复用当前被审对象的 `step_id`。

## 推荐文件名

- `prd-01.analysis.yaml`
- `prd-01.review.yaml`
- `prd-02.clarification.yaml`
- `prd-02.review.yaml`
- `prd-03.execution_plan.yaml`
- `prd-03.review.yaml`
- `prd-04.final_prd.yaml`
- `prd-04.review.yaml`

## YAML 元信息示例

```yaml
meta:
  flow_id: prd
  step_id: prd-03
  artifact_id: prd-03.execution_plan
```

## 初始化命令示例

```bash
ruby scripts/prd/init_artifact.rb --step-id prd-01 analysis runs/demo/prd-01.analysis.yaml
ruby scripts/prd/init_artifact.rb --step prd_analysis --step-id prd-01 review runs/demo/prd-01.review.yaml
ruby scripts/prd/init_artifact.rb --step-id prd-02 clarification runs/demo/prd-02.clarification.yaml
ruby scripts/prd/init_artifact.rb --step-id prd-03 execution_plan runs/demo/prd-03.execution_plan.yaml
ruby scripts/prd/init_artifact.rb --step-id prd-04 final_prd runs/demo/prd-04.final_prd.yaml
```

## 材料查询示例

```bash
ruby scripts/prd/materials.rb --artifact execution_plan
ruby scripts/prd/materials.rb --review-step final_prd_ready
```
