I have written the standalone decision doc at `docs/intent/record-store/decisions/concurrent-visit-edits.md` and linked it from `docs/intent/record-store/record-store-design.md`.

### Summary of `docs/intent/record-store/decisions/concurrent-visit-edits.md`
- **Context**: Explains the 48-hour offline window on shared tablets and why vegetation survey edits can be either administrative/disjoint (e.g., fixing an observer name) or ecologically coupled across fields (e.g., re-identifying `Spartina alterniflora` to `Spartina patens`, adjusting its cover percentage, and updating the habitat note).
- **Decision Elements**:
  - **Gate**: Preserve every submitted edit (from HLD tenet *Do not silently discard a submitted edit*).
  - **Weighted Criteria**: Scientific integrity across coupled fields (*major*), Coordinator review burden before the Friday export (*major*), Rule and schema maintenance complexity (*moderate*), and Offline tablet storage and sync payload footprint (*minor*).
- **Options in the Domain**:
  - **Option 1 (Whole-Visit Revisions)**: Full description, JSON demonstration, and per-element fit analysis (`passes` gate; `strong` on scientific integrity, rule maintenance, and tablet footprint; `partial` on coordinator review burden).
  - **Option 2 (Field-Aware Three-Way Merge)**: Full strongest-honest representation—including why it remains credible when workers split entry tasks across disjoint form sections or when pre-combining disjoint fields for coordinator confirmation—alongside its JSON demonstration and per-element fit analysis (`passes` gate; `strong` on coordinator review burden; `weak` on cross-field scientific integrity and merge-rule/provenance maintenance; `partial` on tablet base-snapshot retention).
- **Selection & Downstream Obligations**: Records why Option 1 wins on scientific integrity and operational simplicity, and spells out the concrete contract obligations for `tablet-sync` (`baseRevisionId` tracking, whole-visit idempotent submission envelopes, surfacing `needs_review` outcomes) and `review-export` (revision comparison screen over `currentRevision` and `competingRevisions`, stale-safe `resolveVisit` with `resolvedRevisionIds`, and holding `needs_review` visits out of the Friday CSV export).

---

### Remaining Phase 2 Stop Questions (`record-store` LLD)

Before we move to **Phase 3 (EARS specs update)**, do you want to adjust any part of `record-store-design.md` or the decision doc, and how would you like to handle the 5 edge-case probe items from the LLD?

1. **Identical concurrent payloads**: If two workers starting from the same `baseRevisionId` submit identical payloads, should that still enter `needs_review` as two competing revisions, or auto-coalesce to `clean` while keeping both submissions in history?
2. **`baseRevisionId: null` collision**: If two tablets somehow submit a new visit with the same `visitId` and `baseRevisionId: null`, should `currentRevisionId` be `null` with both revisions in `competingRevisionIds` (`status = needs_review`)?
3. **Follow-up edits while `needs_review`**: When a visit is already `needs_review`, allow tablets to submit edits based on either an existing competing branch tip (replacing that tip in `competingRevisionIds`) or an older revision (adding another branch tip)?
4. **Idempotency key scope**: Scope `idempotencyKey` per `(visitId, idempotencyKey)` or globally across the store?
5. **Late offline edits after coordinator resolution**: If an offline tablet submits an edit based on a pre-resolution revision after a coordinator has already resolved the visit, transition the visit back to `needs_review` with the coordinator's resolution revision and the late worker revision as `competingRevisionIds`?