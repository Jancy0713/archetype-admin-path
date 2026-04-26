# Contract Progress

## Meta

- run_id:
- flow_id:
- handoff_snapshot_yaml:
- handoff_snapshot_markdown:
- source_handoff_yaml:
- source_handoff_markdown:
- current_step_id:
- overall_status:

## Current Focus

- current_goal:
- current_blocker:
- next_agent_input:
- next_expected_output:

## Working Progress

| step_id | status | artifact | rendered | notes |
| --- | --- | --- | --- | --- |
| `contract-01` | `ready` | `contract/working/contract-01.scope_intake.yaml` | `rendered/contract-01.scope_intake.md` | `` |

## Release

- openapi:
- summary:
- develop_handoff:

## State Files

- review_result:

## Status Legend

- `todo`: 尚未开始
- `ready`: 当前步骤已准备好，可以开始填写或执行
- `doing`: 当前步骤正在处理
- `review`: 当前在 reviewer 门禁中
- `blocked`: 当前步骤被阻塞
- `done`: 当前步骤已完成
- `released`: 当前 flow 已生成正式 release 包

## Update Rules

- 文件路径统一写相对 run 目录的路径
- `current_step` 只描述当前 flow 当前推进到哪一步
- `contract/working/` 只记录过程态
- `contract/release/` 只记录正式交付
