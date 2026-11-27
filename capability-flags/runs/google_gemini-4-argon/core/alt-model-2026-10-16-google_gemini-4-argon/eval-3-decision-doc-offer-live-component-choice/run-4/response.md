I have updated `docs/intent/record-store/record-store-design.md` (and marked the concurrency choice settled in `docs/high-level-design.md`) to complete the Phase 2 LLD around **whole-visit revisions**.

### 1. Decision Doc Offer

Because the concurrency choice between whole-visit revisions and field-aware three-way merge was weighed against multiple criteria (scientific coupling across fields, coordinator review load, and merge-rule maintenance) and sizes the contracts of both `tablet-sync` and `review-export`, it clears the bar for a standalone decision doc:

- **Option A — Decisions & Alternatives row only** (already recorded in `record-store-design.md`).
- **Option B — Full decision doc** at `docs/intent/record-store/decisions/concurrent-visit-edits.md` linked from the LLD's Decisions table.

Would you like to keep just the table row or add the standalone decision doc?

---

### 2. Updated `record-store` LLD (`docs/intent/record-store/record-store-design.md`)

Key additions in the draft:
- **Revision Model & State Transitions**:
  - Every worker submission or coordinator resolution creates an immutable `VisitRevision` (`revisionId`, `visitId`, `baseRevisionId`, `authorId`, `receivedAt`, `source`, `payload`).
  - Visits track `status` (`clean` | `needs_review`), `currentRevisionId`, and `competingRevisionIds`.
  - Linear edits (`status = clean` and `baseRevisionId == currentRevisionId`) advance `currentRevisionId` and stay `clean`.
  - Concurrent edits (`baseRevisionId != currentRevisionId` or visit already `needs_review`) keep `currentRevisionId` at the pre-fork revision, place all unmerged leaf revisions in `competingRevisionIds`, and set `status = needs_review`.
- **Operations & Validation Contract**:
  - `submitVisit`, `getVisit`, `listVisitHistory`, `listUnresolvedVisits`, and `resolveVisit`.
  - Idempotency key handling (`409 IdempotencyConflict` on payload mismatch), `site-catalog` plot existence validation (active or archived), and stale-resolution protection (`409 StaleResolutionSet` if `resolvedRevisionIds` does not match the current `competingRevisionIds`).
- **Downstream Contracts**:
  - `tablet-sync` tracks `revisionId` as `baseRevisionId` and displays `needs_review` status on conflict.
  - `review-export` compares `competingRevisions`, resolves via `resolveVisit`, and holds `needs_review` visits out of the Friday CSV export.

---

### 3. Phase 2 LLD Edge-Case Probe

Please review these edge cases and let me know which to bake into the LLD now vs. defer:

1. **Identical concurrent payloads**: If two workers starting from the same `baseRevisionId` submit byte-identical payloads (e.g., both noticed and fixed the same typo), should the store still create two competing revisions in `needs_review`, or auto-coalesce them into a single `clean` state while preserving both submission records?
2. **Forking before any common ancestor (`baseRevisionId: null` collision)**: If two tablets independently create a visit with the same `visitId` (`baseRevisionId: null`), there is no prior unambiguous revision. Should `currentRevisionId` be `null` while `status = needs_review`, with both initial revisions in `competingRevisionIds`?
3. **Editing while `needs_review`**: When a visit is already `needs_review`, can a tablet submit a follow-up edit based on one of the `competingRevisionIds` (advancing that branch tip), or based on the older `currentRevisionId` (creating a 3-way fork in `competingRevisionIds`)? (The draft currently allows both by tracking all unmerged leaf revisions in `competingRevisionIds`.)
4. **Idempotency key scope**: Are idempotency keys scoped globally across the record store, per `(workerId, idempotencyKey)`, or per `(visitId, idempotencyKey)`?
5. **Re-opening or amending a resolved visit**: After a coordinator resolves a conflict (`coordinator_resolution` revision becomes `currentRevisionId`), if an offline tablet later syncs an edit based on an older pre-resolution revision, should it transition the visit back to `needs_review` with `[currentRevisionId, newLateRevisionId]` as `competingRevisionIds`?

---

### Next Step (Phase 2 Stop)

Please let me know:
1. Your preference on the **decision doc offer** (table row only vs. standalone decision doc).
2. How you want to triage the **5 edge-case probe questions** above (or any edits to the LLD).

Once you approve the `record-store` LLD, we will proceed to **Phase 3 (EARS specs update)**.