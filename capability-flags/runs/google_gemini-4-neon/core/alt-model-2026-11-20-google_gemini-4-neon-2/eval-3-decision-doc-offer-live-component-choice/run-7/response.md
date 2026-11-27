Updated `docs/intent/record-store/record-store-design.md` for **Phase 2 (LLD)** using the whole-visit revisions model. `docs/intent/record-store/record-store-specs.md` (`REC-001`–`REC-006`) is untouched pending your Phase 2 approval, and `docs/high-level-design.md` still marks the concurrency choice as open (we can update that status line once this LLD is approved).

### Summary of `record-store-design.md`

- **Data model & revision graph:** Append-only immutable revisions (`kind: submission | resolution`) with `revisionId`, `visitId`, `parentRevisionIds` (`[]` for initial, `[baseRevisionId]` for worker edits, `[revA, revB, ...]` for resolutions), `authorId`, `receivedAt`, `idempotencyKey`, and full visit `payload`. Visit state is derived from head count: `current` (1 head, `exportEligible: true`) or `needs_review` (2+ heads, `exportEligible: false`).
- **Operations:**
  - *Submit visit revision:* Validates auth, field types, `plotId` in `site-catalog`, and `baseRevisionId` lineage. Enforces `idempotencyKey` replay/conflict semantics. Stale-base submissions and submissions against `needs_review` visits are accepted as additional competing heads rather than rejected.
  - *Retrieve current visit / List visits by state / Retrieve submission history:* Exposes `state`, `exportEligible`, single `currentRevision` or all `competingRevisions`, and full immutable revision history.
  - *Resolve competing revisions (coordinator):* Requires `resolvedRevisionIds` to match the exact current competing head set (optimistic check against late arrivals), appends an immutable `resolution` revision citing those head IDs and the chosen/reconciled `payload`, and returns the visit to `current`.
- **Downstream contracts:** Notes the obligations for `tablet-sync` (base revision IDs, idempotency keys, surfacing `needs_review`) and `review-export` (comparison view from `competingRevisions`, exact-head resolutions, excluding `exportEligible: false` from CSV export).
- **Decisions & Alternatives:** Records whole-visit revisions vs. field-aware three-way merge / last-write-wins, accepting stale-base submissions as competing heads, and append-only resolution revisions.

---

### Decision Doc Offer

Because whole-visit revisions vs. field-aware three-way merge trades real competing criteria (review workload vs. merge-rule maintenance and scientific coupling), will stay live for a future reader, and sizes both `tablet-sync` and `review-export`, would you like me to record it as a standalone decision doc at `docs/intent/record-store/decisions/concurrent-visit-edits.md` (linked from the LLD), or is the `Decisions & Alternatives` row in `record-store-design.md` sufficient?

---

### Phase 2 Edge-Case Probe (for triage: fix in LLD vs. defer)

An independent read of `record-store-design.md` surfaced these internal gaps:

1. **Idempotency key scope & replay behavior:** What happens if an accepted `idempotencyKey` is reused with a different `visitId` or `authorId`, or if a previously rejected submission is retried with the same key? On replay, should `headRevisionIds` return the original acceptance snapshot or the visit's current heads?
2. **Coordinator resolution retry:** `Resolve competing revisions` has no `idempotencyKey`. If a resolution succeeds server-side but the response is lost, how should a retry be distinguished from a stale resolution racing with a new submission?
3. **Resolution `note` field:** The Operations table accepts an optional `note` on resolution, but the data model and retrieval sections omit it — should it be persisted on `resolution` revisions and returned on reads?
4. **`plotId` mutability & resolution payload validation:** Can a later edit or resolution change `payload.plotId` for an existing `visitId`, and does resolution run the same payload/`plotId` validation as submission (including how archived plots are handled)?
5. **No-op / identical competing payloads:** If a stale-base submission carries the exact same `payload` as the current head (or an edit matches its own base), should it still append a revision and enter `needs_review`?
6. **Concurrent writes on the same `visitId`:** What per-visit serialization/atomicity guarantee governs simultaneous writes (e.g., a submission racing with a coordinator resolution, two concurrent resolutions, or two initial `baseRevisionId: null` submissions)?
7. **Ordering, `updatedAt`, and pagination on reads:** What deterministic order is guaranteed for `Retrieve submission history` on a branching graph or tied `receivedAt` timestamps? For `List visits by state`, how is `updatedAt` defined across multiple heads, what is the sort order, and is `state` optional?
8. **Error taxonomy & rejection payloads:** What distinct error codes/payloads are returned for unknown `visitId`, mismatched `baseRevisionId`, `idempotencyKey` conflict, stale `resolvedRevisionIds` (should it return current `headRevisionIds`?), or a coordinator attempting to resolve a `current` visit?
9. **Erroneous or duplicate visits:** Since the graph is append-only with only `current` and `needs_review`, is voiding/retracting an accidental or duplicate `visitId` out of `exportEligible` needed in this release or intentionally deferred?

---

**Next step:** Please review `docs/intent/record-store/record-store-design.md` and let me know:
1. Any changes to the LLD itself.
2. Which probe items (1–9) to resolve in the LLD vs. defer.
3. Whether you want the standalone decision doc or just the Decisions table row.
4. Once settled, whether to proceed to Phase 3 (`record-store-specs.md`) and update the open-choice note in `docs/high-level-design.md`.