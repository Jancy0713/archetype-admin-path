# 测试进度板模板

这份模板的目标不是替代 YAML，而是让你测试时一眼看清：

- 现在卡在哪一步
- 上一步是否已通过
- 下一步应该喂给哪个 agent 什么上下文

正式模板放在：

- [docs/templates/workflow-progress.template.md](/Users/wangwenjie/project/archetype-admin-path/docs/templates/workflow-progress.template.md)

运行目录规范见：

- [RUNS_WORKSPACE_GUIDE.md](/Users/wangwenjie/project/archetype-admin-path/docs/RUNS_WORKSPACE_GUIDE.md)

## 使用建议

- 每个正式步骤一行
- 同一步返工不新增行，只更新 `attempt`、`状态`、`备注`
- reviewer 与主产物分开记，避免误判“步骤已完成”

## Init

| step_id | 产物 | 当前状态 | attempt | 上游输入 | 当前输出 | 下一步 |
| --- | --- | --- | --- | --- | --- | --- |
| `init-01` | `project_profile` | `todo / doing / review / confirmed` | `1` | 原始输入 | `init-01.project_profile.yaml` | `init-01.review.yaml` |
| `init-01` | `review` | `todo / done` | `1` | `init-01.project_profile.yaml` | `init-01.review.yaml` | 人工确认 |
| `init-02` | `project_profile` | `todo / doing / review / confirmed` | `1` | `init-01.project_profile.yaml` | `init-02.project_profile.yaml` | `init-02.review.yaml` |
| `init-02` | `review` | `todo / done` | `1` | `init-02.project_profile.yaml` | `init-02.review.yaml` | 人工确认 |
| `init-03` | `project_profile` | `todo / doing / review / confirmed` | `1` | `init-02.project_profile.yaml` | `init-03.project_profile.yaml` | `init-03.review.yaml` |
| `init-03` | `review` | `todo / done` | `1` | `init-03.project_profile.yaml` | `init-03.review.yaml` | 人工确认 |
| `init-04` | `project_profile` | `todo / doing / review / confirmed` | `1` | `init-03.project_profile.yaml` | `init-04.project_profile.yaml` | `init-04.review.yaml` |
| `init-04` | `review` | `todo / done` | `1` | `init-04.project_profile.yaml` | `init-04.review.yaml` | 人工确认 |
| `init-05` | `baseline` | `todo / doing / confirmed` | `1` | `init-04.project_profile.yaml` | `init-05.baseline.yaml` | `init-06.design_seed.yaml` |
| `init-06` | `design_seed` | `todo / doing / review / done` | `1` | `init-05.baseline.yaml` | `init-06.design_seed.yaml` | `init-06.review.yaml` |
| `init-06` | `review` | `todo / done` | `1` | `init-06.design_seed.yaml` | `init-06.review.yaml` | `init-07.bootstrap_plan.yaml` |
| `init-07` | `bootstrap_plan` | `todo / doing / review / confirmed` | `1` | `init-06.design_seed.yaml` | `init-07.bootstrap_plan.yaml` | `init-07.review.yaml` |
| `init-07` | `review` | `todo / done` | `1` | `init-07.bootstrap_plan.yaml` | `init-07.review.yaml` | 人工确认 |
| `init-08` | `execution` | `todo / doing / done` | `1` | `init-07.bootstrap_plan.yaml` | 新项目初始化结果 | `prd-01.analysis.yaml` |

## PRD

| step_id | 产物 | 当前状态 | attempt | 上游输入 | 当前输出 | 下一步 |
| --- | --- | --- | --- | --- | --- | --- |
| `prd-01` | `analysis` | `todo / doing / review / done` | `1` | 原始输入 | `prd-01.analysis.yaml` | `prd-01.review.yaml` |
| `prd-01` | `review` | `todo / done` | `1` | `prd-01.analysis.yaml` | `prd-01.review.yaml` | `prd-02.clarification.yaml` |
| `prd-02` | `clarification` | `todo / doing / review / confirmed` | `1` | `prd-01.analysis.yaml` | `prd-02.clarification.yaml` | `prd-02.review.yaml` |
| `prd-02` | `review` | `todo / done` | `1` | `prd-02.clarification.yaml` | `prd-02.review.yaml` | 人工确认 |
| `prd-03` | `execution_plan` | `todo / doing / review / done` | `1` | `prd-02.clarification.yaml` | `prd-03.execution_plan.yaml` | `prd-03.review.yaml` |
| `prd-03` | `review` | `todo / done` | `1` | `prd-03.execution_plan.yaml` | `prd-03.review.yaml` | `prd-04.final_prd.yaml` |
| `prd-04` | `final_prd` | `todo / doing / review / done` | `1` | `prd-03.execution_plan.yaml` | `prd-04.final_prd.yaml` | `prd-04.review.yaml` |
| `prd-04` | `review` | `todo / done` | `1` | `prd-04.final_prd.yaml` | `prd-04.review.yaml` | Contract |

## 最小落地规则

- 文件名、`meta.step_id`、进度板三者保持一致
- 每一步只把“正式通过脚本校验”的 YAML 记为有效输出
- 需要给下一步 agent 喂上下文时，优先给：
  - 当前步正式 YAML
  - 对应 reviewer YAML
  - 人工确认结论
