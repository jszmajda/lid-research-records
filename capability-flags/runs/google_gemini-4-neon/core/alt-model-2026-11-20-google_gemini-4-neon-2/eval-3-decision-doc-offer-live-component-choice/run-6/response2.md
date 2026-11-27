Added `docs/intent/record-store/decisions/concurrent-visit-edits.md` (owned by `record-store`) and linked it from the Decisions & Alternatives table in `docs/intent/record-store/record-store-design.md`.

### Summary of `concurrent-visit-edits.md`
- **Decision elements**: Evaluates both options on four weighted criteria—whole-visit scientific coherence (`major`), operational simplicity for two coordinators (`major`), coordinator review queue volume and Friday export readiness (`moderate`), and offline tablet state/submission simplicity (`minor`)—grounded in the HLD tenets and Non-Goals, with the standing invariants (no silent discard, offline capture) held in Context.
- **Options in the domain**: Gives full, standalone representations and concrete demonstrations of both **Whole-visit revisions** and **Field-aware three-way merge**, with per-criterion `strong`/`partial`/`weak` fit verdicts.
- **Selection & revisit trigger**: Selects whole-visit revisions, records the accepted trade-off on review queue volume, and states when field-aware three-way merge would be revisited (if routine disjoint edits exceed what two coordinators can clear before Friday export).
- **Downstream obligations**:
  - `tablet-sync`: track `baseRevisionId` per cached visit, submit whole-visit payloads with per-edit idempotency keys, handle `needs_review` without discarding local state, and display pending competing revisions.
  - `review-export`: provide whole-visit side-by-side comparison (competing heads + nearest common ancestor), submit resolutions with exact `resolvedRevisionIds` (handling stale-conflict refreshes), and exclude `needs_review` visits from the Friday CSV until resolved.

### Phase 2 Stop — Ready for Review
Before I move to Phase 3 (`docs/intent/record-store/record-store-specs.md`), please let me know:
1. Any changes to `record-store-design.md` or `decisions/concurrent-visit-edits.md` (and whether to update the status note in `docs/high-level-design.md`).
2. How you want to triage the 8 edge-case probe items from above (fix in the LLD now vs. defer to Open Questions).