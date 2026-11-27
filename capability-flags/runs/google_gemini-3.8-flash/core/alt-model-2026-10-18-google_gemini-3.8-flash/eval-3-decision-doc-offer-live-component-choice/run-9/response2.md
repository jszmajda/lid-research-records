The decision doc has been created at `docs/intent/record-store/decisions/concurrent-visit-revisions.md` and linked from the Decisions & Alternatives table in `docs/intent/record-store/record-store-design.md`.

### Summary of Completed Artifacts

1. **Decision Doc (`docs/intent/record-store/decisions/concurrent-visit-revisions.md`):**
   - **Context & Gates:** Evaluates concurrency under the inherited gate of *no silent data loss* across 12 shared tablets and 320 permanent plots.
   - **Weighted Criteria:** Analyzes options against *Scientific relationship preservation (Major)*, *Coordinator operational burden (Major)*, *Implementation complexity (Moderate)*, and *Field team autonomy (Moderate)*.
   - **Options Analyzed:** Full comparative analysis between *Whole-Visit Revisions* and *Field-Aware Three-Way Merge*.
   - **Selection & Tenet Alignment:** Turns on tenets *Keep the path from a submitted observation to an exported value inspectable* and *Prefer workflows two coordinators can operate without a dedicated systems administrator*.
   - **Reconsideration Conditions:** Documents under what conditions the project would reconsider field-aware merge (scaling past coordinator review bandwidth, provided merge automation is restricted strictly to disjoint non-scientific metadata like observer normalization and supported by dedicated tooling).
   - **Downstream Obligations:** Details explicit architectural requirements that `tablet-sync` (tracking base revision IDs, preserving local drafts upon conflict, durable idempotency) and `review-export` (side-by-side revision diff UI, strict export gating, resolution provenance) must accommodate.

2. **LLD Record Store (`docs/intent/record-store/record-store-design.md`):**
   - Incorporates the whole-visit revision model, ingestion schema, revision DAG lineage, and coordinator resolution mechanics.
   - Links directly to the new decision doc.

---

### Phase 2 Review & Next Steps

This concludes **Phase 2 (LLD check or draft)** for `record-store`.

Please review the drafted decision doc and updated LLD. Upon your approval, we will proceed to **Phase 3 (EARS spec update)** to align `docs/intent/record-store/record-store-specs.md` with the whole-visit revision contract before moving to `tablet-sync` and `review-export`.