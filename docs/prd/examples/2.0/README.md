# PRD 2.0 Examples

这里放的是当前 `2.0/2.1` 四步主链路的最小可回归样例。

## 当前内容

1. [happy-path-run/raw/request.md](/Users/wangwenjie/project/archetype-admin-path/docs/prd/examples/2.0/happy-path-run/raw/request.md)
2. [happy-path-run/prd/prd-01.analysis.yaml](/Users/wangwenjie/project/archetype-admin-path/docs/prd/examples/2.0/happy-path-run/prd/prd-01.analysis.yaml)
3. [happy-path-run/prd/prd-01.review.yaml](/Users/wangwenjie/project/archetype-admin-path/docs/prd/examples/2.0/happy-path-run/prd/prd-01.review.yaml)
4. [happy-path-run/prd/prd-02.clarification.yaml](/Users/wangwenjie/project/archetype-admin-path/docs/prd/examples/2.0/happy-path-run/prd/prd-02.clarification.yaml)
5. [happy-path-run/prd/prd-03.execution_plan.yaml](/Users/wangwenjie/project/archetype-admin-path/docs/prd/examples/2.0/happy-path-run/prd/prd-03.execution_plan.yaml)
6. [happy-path-run/prd/prd-04.final_prd.yaml](/Users/wangwenjie/project/archetype-admin-path/docs/prd/examples/2.0/happy-path-run/prd/prd-04.final_prd.yaml)

## 用法

1. 跑校验：

```bash
ruby scripts/prd/validate_artifact.rb analysis docs/prd/examples/2.0/happy-path-run/prd/prd-01.analysis.yaml
ruby scripts/prd/validate_artifact.rb review docs/prd/examples/2.0/happy-path-run/prd/prd-01.review.yaml
ruby scripts/prd/validate_artifact.rb clarification docs/prd/examples/2.0/happy-path-run/prd/prd-02.clarification.yaml
ruby scripts/prd/validate_artifact.rb execution_plan docs/prd/examples/2.0/happy-path-run/prd/prd-03.execution_plan.yaml
ruby scripts/prd/validate_artifact.rb final_prd docs/prd/examples/2.0/happy-path-run/prd/prd-04.final_prd.yaml
```

2. 跑渲染：

```bash
ruby scripts/prd/render_artifact.rb analysis docs/prd/examples/2.0/happy-path-run/prd/prd-01.analysis.yaml docs/prd/examples/2.0/happy-path-run/rendered/prd-01.analysis.md
ruby scripts/prd/render_artifact.rb clarification docs/prd/examples/2.0/happy-path-run/prd/prd-02.clarification.yaml docs/prd/examples/2.0/happy-path-run/rendered/prd-02.clarification.md
ruby scripts/prd/render_artifact.rb execution_plan docs/prd/examples/2.0/happy-path-run/prd/prd-03.execution_plan.yaml docs/prd/examples/2.0/happy-path-run/rendered/prd-03.execution_plan.md
ruby scripts/prd/render_artifact.rb final_prd docs/prd/examples/2.0/happy-path-run/prd/prd-04.final_prd.yaml docs/prd/examples/2.0/happy-path-run/rendered/prd-04.final_prd.md
```
