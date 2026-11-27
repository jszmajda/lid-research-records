The record-store design is finished with whole-visit revisions selected. Files changed:

- `docs/intent/record-store/record-store-design.md` — open choice resolved into a concrete design: every visit has a server-assigned, monotonic, immutable revision chain; the submission envelope is visit UUID, plot ID, base revision ID, full payload, author ID, idempotency key, client timestamp; a submission against the head appends a new head, one against any earlier revision is stored as a **competing revision** (retained in full, never applied to current state) and marks the visit unresolved; resolution names one competing revision as the new head, keeps losers as history, and records coordinator identity plus contributing submission IDs; there is no auto-merge, no timeout. Rejected alternative (field-aware three-way merge) and rationale recorded in the new Decisions & Alternatives table.
- `docs/intent/record-store/record-store-specs.md` — REC-001–006 kept (REC-004 reworded to be context-free); added REC-007–014 covering initial revision creation, head append, competing-revision storage, payload immutability, unresolved retrieval shape, resolution outcome, status persistence, and a no-merge/no-partial-apply guarantee. Consistency check: LLD behaviors all covered, no contradictions, scopes explicit.
- `docs/high-level-design.md` — record-store status now "Drafted"; the tablet-sync/review-export dependency note updated to name the settled choice and the three contract pieces those nodes must size around.

One design decision I deferred to you rather than settling: whether a coordinator may resolve by recording a manually composed payload instead of picking one competing revision. I left it as a deferred question owned by review-export (it sizes the coordinator interface); until then resolution selects one revision. Flag it now if you'd rather settle it here.

Delegated probe of the drafted LLD returned 11 gaps — triage which to fix here vs. defer. The two most load-bearing:

1. **Submissions arriving while a visit is already unresolved** — e.g. a second edit against the head after a competing revision exists. Design doesn't say whether it's accepted, stored, or rejected; this shapes tablet-sync retry logic and the coordinator worklist. (The natural reading: it becomes another competing revision, so the unresolved set can grow.)
2. **Rejection/error shape** — nothing states what a rejected submission returns, notably whether the response includes the current head revision so tablets can rebase; without that the whole-visit loop can't converge after a failure.

Other gaps found: guard against resolving a superseded revision; validation/auth rejection specs and whether a rejected submission consumes its idempotency key; idempotency-key scope (per visit/author/global) and retry-after-rejection; simultaneous same-key submissions; submission-history ordering/pagination; whether unresolved status is derived or stored; whether resolutions are immutable retrievable entries; visit deletion/retired plot handling; same-instant receipt-time ordering.

Two questions for you:

1. Do you approve this LLD and spec set, and which of the probe gaps should I fix into the design here vs. defer?
2. The concurrency choice will size tablet-sync and review-export around it and a cold reader could be tempted to reverse it for lower review volume — want a standalone decision doc for it, or is the Decisions & Alternatives row enough?