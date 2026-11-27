Written `docs/intent/record-store/decisions/concurrent-visit-edits.md` and linked it from the Decisions & Alternatives table in `docs/intent/record-store/record-store-design.md`.

### What's in `decisions/concurrent-visit-edits.md`
- **Context & Decision Elements**: Frames the problem at TidePlot's scale (24 workers, 12 tablets, 48-hour offline windows, 2 coordinators, Friday CSV export) and weighs five criteria tied to the HLD tenets: scientific coherence across coupled fields (major), operational simplicity for two coordinators (major), review queue volume and export readiness (moderate), auditability and provenance clarity (moderate), and offline client state/payload complexity (minor).
- **Options in the Domain**: Gives full descriptions, concrete demonstrations, and per-criterion fit analyses for both **Whole-Visit Revisions** and **Field-Aware Three-Way Merge** (including why three-way merge remains the credible alternative if concurrent disjoint edits ever outgrow the coordinators' Friday review capacity).
- **Selection & Downstream Obligations**: Records **Whole-Visit Revisions** and spells out what **tablet-sync** (retain `baseRevisionId` and persistent `idempotencyKey`, send full payloads, surface `unresolved` outcomes without on-tablet merging) and **review-export** (revision-comparison/resolution workflow, handling late-arriving edits during review, excluding `unresolved` visits from the Friday CSV) must accommodate.

### Still at Phase 2 Stop

Before I move to Phase 3 (`docs/intent/record-store/record-store-specs.md`):
1. Are you good with `record-store-design.md` and `decisions/concurrent-visit-edits.md` as written?
2. Which of the 8 LLD edge-case probe items from above should be folded into `record-store-design.md` now vs. deferred to Open Questions? (And should I refresh the stale "concurrency choice open" status note in `docs/high-level-design.md` once approved?)