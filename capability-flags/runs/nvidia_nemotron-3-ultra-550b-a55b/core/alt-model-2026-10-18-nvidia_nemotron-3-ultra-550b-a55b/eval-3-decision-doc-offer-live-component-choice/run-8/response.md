**Phase 4 — Intent-Narrowing Edge Audit**: 

Here are the genuine forks I found in the whole-visit revisions design:

| # | Spec(s) | Fork |
|---|---------|------|
| 1 | REC-010 | **Non-existent base revision**: A submission arrives with a `baseRevisionId` that never existed (not just stale, but invalid). Reject vs. accept as competing anyway? |
| 2 | REC-008 | **Resolution target validation**: Coordinator chooses a `revisionId` not in `{currentRevisionId} ∪ competingRevisions`. Reject vs. allow (e.g., manual merge creating new revision)? |
| 3 | REC-002/003 | **Idempotency key scope**: Is the key unique per-visit or globally? If global, a key collision across visits blocks unrelated retries. |
| 4 | REC-009 | **History pagination**: At ~6,000 visits/season with multiple revisions each, unbounded history retrieval could be large. Need pagination contract now or defer? |
| 5 | REC-005/007 | **Competing revisions after resolution**: Design says "clear competing revisions" — does this mean remove from `competingRevisions` array only (keep in history), or mark them superseded? Current text implies array-only. |
| 6 | REC-001 | **New visit creation**: First submission for a `visitId` uses sentinel `baseRevisionId`. What if two workers independently create a visit for the same plot (different `visitId`s)? That's two separate visits — correct? |
| 7 | REC-008 | **Concurrent resolutions**: Two coordinators resolve the same unresolved visit simultaneously. Last-write-wins vs. optimistic lock on `currentRevisionId`? |

Please resolve each (or defer with a note). I'll narrow the specs accordingly before Phase 5.