# Workflow Progress

## Meta

- run_id:
- owner:
- started_at:
- current_flow:
- current_step_id:
- overall_status:

## Current Focus

- current_goal:
- current_blocker:
- next_agent_input:
- next_expected_output:

## Inputs

- raw_request:
- attachments:
- baseline_if_any:

## Init Progress

| step_id | artifact | status | attempt | input | output | reviewer | human_confirmation | next |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `init-01` | `project_profile` | `todo` | `1` | `raw/request.md` | `init/init-01.project_profile.yaml` | `init/init-01.review.yaml` | `pending` | `init-02` |
| `init-02` | `project_profile` | `todo` | `1` | `init/init-01.project_profile.yaml` | `init/init-02.project_profile.yaml` | `init/init-02.review.yaml` | `pending` | `init-03` |
| `init-03` | `project_profile` | `todo` | `1` | `init/init-02.project_profile.yaml` | `init/init-03.project_profile.yaml` | `init/init-03.review.yaml` | `pending` | `init-04` |
| `init-04` | `project_profile` | `todo` | `1` | `init/init-03.project_profile.yaml` | `init/init-04.project_profile.yaml` | `init/init-04.review.yaml` | `pending` | `init-05` |
| `init-05` | `baseline` | `todo` | `1` | `init/init-04.project_profile.yaml` | `init/init-05.baseline.yaml` | `` | `pending` | `init-06` |
| `init-06` | `design_seed` | `todo` | `1` | `init/init-05.baseline.yaml` | `init/init-06.design_seed.yaml` | `init/init-06.review.yaml` | `batched_with_init-07` | `init-07` |
| `init-07` | `bootstrap_plan` | `todo` | `1` | `init/init-06.design_seed.yaml` | `init/init-07.bootstrap_plan.yaml` | `init/init-07.review.yaml` | `pending` | `init-08` |
| `init-08` | `execution` | `todo` | `1` | `init/init-07.bootstrap_plan.yaml` | `project-root` | `` | `not_needed` | `prd-01` |

## PRD Progress

| step_id | artifact | status | attempt | input | output | reviewer | human_confirmation | next |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `prd-01` | `analysis` | `todo` | `1` | `raw/request.md` | `prd/prd-01.analysis.yaml` | `prd/prd-01.review.yaml` | `not_needed` | `prd-02` |
| `prd-02` | `clarification` | `todo` | `1` | `prd/prd-01.analysis.yaml` | `prd/prd-02.clarification.yaml` | `prd/prd-02.review.yaml` | `required` | `prd-03` |
| `prd-03` | `execution_plan` | `todo` | `1` | `prd/prd-02.clarification.yaml` | `prd/prd-03.execution_plan.yaml` | `prd/prd-03.review.yaml` | `not_needed` | `prd-04` |
| `prd-04` | `final_prd` | `todo` | `1` | `prd/prd-03.execution_plan.yaml` | `prd/prd-04.final_prd.yaml` | `prd/prd-04.review.yaml` | `optional` | `contract` |

## Decisions

| date | flow | step_id | decision | by | impact |
| --- | --- | --- | --- | --- | --- |
|  |  |  |  |  |  |

## Handoff Notes

- 

## Status Legend

- `todo`: 还没开始
- `doing`: 主产物填写中
- `validating`: 正在过脚本校验
- `review`: reviewer 审查中
- `batched_with_init-07`: 当前步骤不单独停给人，会在 `init-07` 人工确认时一并确认
- `confirmed`: 已通过且已记录人工确认
- `done`: 已完成并进入下一步
- `blocked`: 当前卡住

## Update Rules

- 文件路径统一写相对 run 目录的路径
- 同一步返工不新增行，只更新 `attempt` 和 `status`
- 只有通过脚本校验的 YAML 才能写进 `output`
- reviewer 完成前，不把步骤写成 `done`
- 需要人工确认的步骤，未确认前不能推进下一步
