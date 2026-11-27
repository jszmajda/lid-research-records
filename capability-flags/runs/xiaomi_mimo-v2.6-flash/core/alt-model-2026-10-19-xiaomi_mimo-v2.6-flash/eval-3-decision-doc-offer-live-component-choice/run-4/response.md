**Phase 1 — HLD check (done). Stop for your review.**

**Coherence pre-flight**
- EARS → LLD: `REC-001`–`REC-006` all trace to the current record-store design (submission retention, idempotency, unresolved-work flag, resolution provenance). `REC-004/005/006` are phrased policy-agnostic, so the selection doesn't stale them.
- Tests → EARS: no code or tests exist yet; nothing to trace.
- LLD → HLD: consistent — the HLD delegates the concurrency mechanism to record-store and the LLD keeps it there.

**HLD changes** (`docs/high-level-design.md`)
1. Architecture table, record-store row state: `Drafted; concurrency choice open` → `Drafted; concurrency mechanism selected`.
2. The dependency paragraph after the table now reads:

> The concurrency mechanism belongs to record-store, not this HLD. Its mechanism is whole-visit revisions: each edit names the revision it started from, and competing revisions wait for coordinator resolution. Tablet-sync and review-export depend on that mechanism — it determines submission metadata, the shape of review work, and which record states can enter an export — and their designs build on the contract record-store defines.

No new tenet or Key Design Decisions entry: the HLD explicitly assigns this choice to record-store, so its rationale belongs in that node's Decisions table.

Two things before I move to Phase 2 (finishing the record-store LLD around whole-visit revisions):

1. Approve the HLD check and edits above, with feedback if any?
2. The revision-vs-merge choice clears the bar for a decision doc — two credible options weighed against review workload, merge-rule maintenance risk, and whole-visit intent, with tablet-sync and review-export about to be sized around it. Record it as a full decision doc (`docs/intent/record-store/decisions/whole-visit-revisions.md`), or just a Decisions & Alternatives row in the record-store LLD?