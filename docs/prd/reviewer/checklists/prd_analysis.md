# Reviewer Checklist: prd_analysis

## 必查项

1. 输入摘要是否失真，是否漏掉关键输入边界。
2. `scope_analysis` 是否区分了 in-scope 和 out-of-scope。
3. `domain_breakdown` 是否至少覆盖模块、页面、资源、流程四类视图。
4. `risk_analysis.blocking_gaps.p0` 是否真实识别阻塞项。
5. `clarification_candidates.confirmation_items` 是否真的是后续待确认问题，而不是未整理的笔记。

## 放行标准

只有当下面条件成立，才允许进入 `clarification`：

1. 没有未表达的 P0 阻塞缺口。
2. `handoff.ready_for_clarification=true` 有明确理由。
3. 当前 analysis 足以作为 `clarification` 的唯一上游输入。
