# Contract Spec

## Status

- Step: contract_spec
- Attempt: 1
- Max Retry: 2
- Ready For Next: false

## Meta

- Flow Id: contract
- Step Id: contract-03
- Artifact Id: contract-03.contract_spec
- Contract Id: batch-foundation-access
- Batch Id: batch-foundation-access
- Run Id: 2026-04-26-contract-batch-foundation-access
- Updated At: 2026-04-26T03:38:14Z

## Spec Scope

- Summary: Foundation access API contract
- Modules In Scope:
  - foundation-access
- Resources In Scope:
  - Account
- Actions In Scope:
  - listAccounts

## Shared References

- None

## Resource Contracts

### Account
- Purpose: Represent access account
- Ownership: foundation
- Fields:
  - id
  - name
- States:
  - active
- Constraints:
  - id required

## Consumer Views

### AccessList
- View Type: table
- Goal: List accounts
- Consumers:
  - admin-ui
- Required Resources:
  - Account
- Required Fields:
  - id
  - name
- Required Actions:
  - listAccounts

## Query And Command Semantics

- Queries:
  - Name: listAccounts | Applies To: Account | Inputs: page, page_size | Behavior: returns paginated accounts
- Commands:
  - Name:  | Applies To:  | Inputs:  | Effects: 

## Access And Tenant Rules

- Roles:
  - admin

## Validation And Error Semantics

- Validations:
  - page_size must be positive
- Error Cases:
  - 403 forbidden

## Implementation Notes For Consumers

- None

## Decision

- Allow Review: true
- Reason: spec ready

