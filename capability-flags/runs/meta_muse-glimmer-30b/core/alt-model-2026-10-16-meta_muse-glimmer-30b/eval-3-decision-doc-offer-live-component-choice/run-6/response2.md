Record-store design rewritten with the choice rationale and downstream accommodations explicit.

**`docs/intent/record-store/record-store-design.md` — Concurrency Policy section updated**

*Why whole-visit revisions*
Preserves the worker's submitted visit as an atomic unit. No merge rules are required, so the server never combines fields that may be scientifically related in ways field names do not reveal, e.g., a species identification change paired with its cover estimate. Review volume increases because even edits to unrelated fields create competing revisions, and the tablet and export side must handle larger review queues.

*Rejected alternative: Field-aware three-way merge*
Field-aware three-way merge would have each edit supply its base state and a structured change set. Disjoint field changes could be combined automatically; overlapping changes would require review. This would reduce review volume and get more visits ready for export sooner. The cost is maintaining merge rules for scalar fields, observer lists, and species entries, and the risk that automatically combined fields cross scientific relationships the rules do not understand. The team chose to accept a bigger review queue over maintaining merge rules that could silently combine scientifically related edits.

Submission envelope, current-state response, unresolved work representation, and resolution operation remain as previously specified:
- `visitId`, `baseRevisionId`, `payload`, `idempotencyKey`
- Current-state includes `revisionId`, `visitId`, `payload`, `authorId`, `receivedAt`, `status`, `unresolved`
- Unresolved work = `competingRevisions` list with author/receivedAt/baseRevisionId and fork `baseRevisionId`
- `resolveVisit(visitId, chosenRevisionId, coordinatorId, note)` records coordinator identity + contributing submission IDs, marks chosen revision current, others superseded, idempotent

**Downstream Contract Work now explicit**

Tablet-sync must:
- Retain `baseRevisionId` for each local draft and send it with every submission
- Store base snapshots locally to explain to workers which revision they edited from and whether competing revisions arrived since sync
- Surface pending competing revisions after sync, e.g., “another worker submitted a different version while you were offline”
- Preserve idempotency key and `baseRevisionId` across retries; do not re-base automatically

Review-export must:
- Provide a revision comparison screen showing two complete visit payloads side-by-side with author, receivedAt, and baseRevisionId
- Hold visits with unresolved competing revisions out of the Friday CSV export; export eligibility requires `unresolved = false` and a selected current revision
- Record coordinator resolution notes and contributing submission IDs for auditability
- Size the coordinator interface for a larger review queue, since even unrelated field edits create review work

Decisions & Alternatives table records the choice:
Concurrent visit edits — Chosen: Whole-visit revisions — Alternatives considered: Field-aware three-way merge — Rationale: preserves submitted visit as a unit, avoids merge rules that could combine scientifically related edits without noticing; larger review queue accepted over maintaining field-level merge rules.

The LLD and EARS specs are now context-free and ready. Confirm this write-up, or give numbered feedback for further edits before we move to tablet-sync and review-export design.