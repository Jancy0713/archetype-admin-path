# Domain Mapping

## Status

- Step: domain_mapping
- Attempt: 1
- Max Retry: 2
- Ready For Next: false

## Meta

- Flow Id: contract
- Step Id: contract-02
- Artifact Id: contract-02.domain_mapping
- Contract Id: batch-foundation-access
- Batch Id: batch-foundation-access
- Run Id: 2026-04-26-contract-batch-foundation-access
- Updated At: 2026-04-26T03:38:14Z

## Mapping Basis

- Scope Intake Path: ../working/contract-01.scope_intake.yaml
- Handoff Snapshot Path: ../../intake/contract-handoff.snapshot.yaml
- Source Final Prd Path: ../../intake/prd-04.final_prd.yaml

## Resource Map

### Account
- Kind: entity
- Ownership: foundation
- Summary: Core access account
- Shared Or New: new
- Related Views:
  - AccessList

## Action Map

### listAccounts
- Resource Name: Account
- Action Type: query
- Summary: List accounts
- Related Views:
  - AccessList

## State And Enum Map

### Item 1

## Access Map

- None

## Consumer View Map

### AccessList
- View Type: table
- Goal: View access accounts
- Primary Resources:
  - Account
- Primary Actions:
  - listAccounts

## Reference Plan

- Definitions To Finalize In Spec:
  - Account list contract

## Decision

- Allow Contract Spec: true
- Reason: mapping ready

