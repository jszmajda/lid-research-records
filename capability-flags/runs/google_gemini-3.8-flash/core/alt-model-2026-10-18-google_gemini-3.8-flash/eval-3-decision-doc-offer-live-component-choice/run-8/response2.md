I have authored the full decision doc at `docs/intent/record-store/decisions/concurrent-visit-edits.md` and linked it from the Decisions & Alternatives table in `docs/intent/record-store/record-store-design.md`.

### Summary of the Decision Doc

- **Options Evaluated**: Analyzed Whole-Visit Revisions against Field-Aware Three-Way Merge across gates (no silent data loss) and weighted criteria derived from tenets (scientific integrity, coordinator operational sustainability, export throughput, sync simplicity).
- **Triggers for Reconsidering Three-Way Merge**: Documented specific conditions that would reopen the merge approach—namely review queue saturation beyond coordinator capacity as survey volume scales, evolution of survey protocols to provably independent sub-modules (e.g., sensor telemetry vs. species counts), or mature delta-tracking infrastructure on clients.
- **Downstream Obligations**:
  - `tablet-sync`: Must track and submit `base_revision_id`, transmit full visit payloads, and surface server conflict states rather than attempting silent local reconciliation.
  - `review-export`: Must provide a side-by-side whole-visit visual diff interface, tooling for coordinators to select or author reconciled revisions, and an export gate holding `in-review` visits out of the partner CSV.

Does this decision doc and the updated LLD meet your expectations, and are you ready to proceed to Phase 3 (EARS specs update for `record-store`)?