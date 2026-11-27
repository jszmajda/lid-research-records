The record-store design is finished around whole-visit revisions. Three files changed — please review:

**docs/high-level-design.md** — removed the stale "concurrency choice open" state; the architecture note now states the settled mechanism and that tablet-sync/review-export build against record-store's contract.

**docs/intent/record-store/record-store-design.md** — the open choice is replaced by the settled design:
- **Model**: every accepted submission becomes a complete revision naming its base revision. Base = current and visit resolved → new current revision; anything else → competing revision and the visit is marked unresolved. Nothing merges automatically; only coordinator selection makes a competing revision current.
- **Envelope**: visit ID, base revision ID, idempotency key, complete payload; author/receipt time/IDs assigned server-side. Validation covers auth, field types, plot resolution (archived plots valid — historical visits keep their references), cross-visit bases, base-less submissions to existing visits.
- **Outcome & retrieval**: the acceptance result states current-vs-competing (what tablet-sync will explain to the worker); current-state retrieval returns the current revision plus the unresolved listing; history is never rewritten.
- **Resolution**: coordinator selects one revision; combining happens as a follow-up standard submission, so every stored payload keeps its original author.
- **Decisions & Alternatives** records the field-aware three-way merge rejection in your terms — a bigger review queue over merge rules that could silently combine scientifically related edits.

**docs/intent/record-store/record-store-specs.md** — REC-001/004/005 refreshed for the settled policy (IDs stable), twelve new specs REC-007–018. Consistency report: coverage complete, no contradictions, scopes explicit.

**Edge-case probe — triage requested.** A blind reviewer found gaps now listed in the LLD's Deferred section; tell me which to resolve in the design vs. keep deferred:

1. **First-submission race** — two base-less submissions for the same visit ID: loser becomes competing or rejected?
2. **Resolution atomicity** — submission concurrent with resolution; both coordinators resolving at once?
3. **Re-opening unresolved** — submission based on a non-selected revision after resolution?
4. **Nonexistent base revision** — reject, or treat how?
5. **Rejected submissions** — retained anywhere (tenet: don't silently discard), and what error shape?
6. **Idempotency key scope** — per author, per visit, or store-wide; stale-outcome replay?
7. **Revision ID uniqueness** — global vs per-visit; submission-ID-to-revision-ID mapping?
8. **Resolution input** — does the coordinator select a submission ID or a revision ID?
9. **Arrival-order tension** — first-arrival wins the current slot by rule, which the Context disclaims as authority; accepted cost, or mitigate in review presentation?

**One offer:** the whole-visit-vs-merge choice stays live for a cold reader (two credible options, multiple criteria, tablet-sync and review-export sized around it). Want a full decision doc in `docs/intent/record-store/decisions/`, or is the Decisions & Alternatives row enough?

I've stopped here per the workflow — on your approval I'll run the intent-narrowing audit over the new specs (including the divergent-readings pass) before any tests or code.