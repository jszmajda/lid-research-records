Decision doc written: `docs/intent/record-store/decisions/whole-visit-revisions.md`, linked from the record-store Decisions & Alternatives table.

It records:

- **Both options at full strength** — whole-visit revisions and field-aware three-way merge — with concrete visit examples and per-criterion analysis (scientific-edit safety, review volume, maintenance burden, explainability, operability, submission size).
- **Why the alternative remains credible**: it becomes the right choice if coordinator review volume becomes the binding constraint and the team is prepared to own merge rules, field-level provenance, and explicit review for every potentially related edit.
- **What it obligates downstream**: tablet-sync retains base revision IDs and whole snapshots, handles no-current-revision retrieval, and surfaces competing/unresolved outcomes; review-export gets a whole-revision comparison screen, drains the unresolved-work queue, holds unresolved visits out of the CSV, exports only the resolved current revision, and records resolution provenance.
- **Reconsideration trigger** and the consequences the choice forecloses (automatic disjoint-edit reconciliation, field-level provenance as the primary explanation, coordinator-composed hybrid revisions).

The LLD itself is unchanged apart from the link. You haven't approved it yet, and the Phase 2 probe gaps are still open. Please confirm:

- whether the LLD is approved as written or needs changes,
- which probe gaps to fix now versus defer (notably idempotency-key scope, submission response shape, resolution retry/stale ordering, and late-edit reopening),
- and then I'll draft the EARS updates (Phase 3).