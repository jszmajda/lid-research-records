Record-store design is complete, and the HLD no longer blocks downstream nodes. No tests or code were written, since you scoped this to design; all specs remain active gaps.

**Changed**
- `docs/high-level-design.md` — record-store is no longer marked "concurrency choice open"; the architecture note now states the whole-visit revision contract.
- `docs/intent/record-store/record-store-design.md` — completed LLD.
- `docs/intent/record-store/record-store-specs.md` — REC-001–REC-030.

**Design shape**
- Every accepted submission is an immutable, complete visit revision; the server never merges fields.
- Revisions form a graph. One active revision → `current`; more than one → `unresolved`, with no revision current.
- A revision based on the sole active revision fast-forwards. A revision based on anything older is accepted as a competing branch and reopens review; unrelated edits still create review work, as expected.
- A root submission for an existing visit becomes a competing root.
- Resolution selects one reviewed revision; the rest become `not_selected`. It is compare-and-set on the reviewed frontier set and `frontier_version`, so a revision arriving mid-review cannot be silently dropped. Corrections are follow-up complete revisions.
- Idempotency is scoped to author; server receipt time is authoritative; all revisions and resolutions are retained.
- Retrieval exposes current state, revision history, unresolved queue, and resolution history; unresolved visits stay out of export.

**Checks**
- Coverage: every LLD behavior maps to a spec (submission, graph transitions, retrieval, resolution, authorization, retention, queue ordering).
- Contradiction: none found; REC-007/008 partition sole-frontier vs. other, and REC-013/014 distinguish stale review from no unresolved work.
- Scoping: specs name worker/caller/coordinator and active frontier explicitly; no reliance on section headers.

**Forks needing your call**
1. Resolution selects one whole revision; a coordinator needing a combined or corrected result submits a follow-up complete revision. Keep that, or should the review screen author a combined revision directly?
2. The plot reference is an editable field across revisions. Should it instead be immutable for a visit?
3. A second root submission for an existing visit is accepted as a competing root. Confirm that over rejecting it with a rebase error.
4. Species cover encoding is deferred to the field protocol; record-store validates entry shape only. Is that the right boundary?
5. The server accepts further revisions to an unresolved visit and keeps it unresolved; tablet-sync can decide whether to lock the UI. Is that acceptable?

The LLD records these as deferred/open items. This concurrency choice is load-bearing for tablet-sync and review-export: want a full decision doc under `docs/intent/record-store/decisions/`, or is the Decisions & Alternatives row enough?

Please reply with numbered answers or approval, and I'll revise this node before moving to tablet-sync and review-export.