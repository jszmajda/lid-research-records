Wrote the decision doc at `docs/intent/record-store/decisions/concurrent-visit-edits.md` and linked it from the **Decisions & Alternatives** table in `docs/intent/record-store/record-store-design.md`.

### What the decision doc covers

- **Context & Decision Elements**: Frames the problem at TidePlot's scale (24 workers, 12 offline tablets, ~6,000 visits/season, 2 coordinators, Friday CSV export) and evaluates five weighted criteria tied to the HLD tenets and goals: scientific integrity (**major**), operational/maintenance simplicity (**major**), coordinator review queue volume (**moderate**), export readiness latency (**moderate**), and client storage/submission complexity (**minor**).
- **Options in the Domain**: Gives both **Whole-visit revisions** and **Field-aware three-way merge** full representations with concrete demonstrations and per-criterion fit verdicts — including the case for three-way merge (automatically combining disjoint edits to keep the coordinator queue small and visits export-ready).
- **Selection & Downstream Obligations**: Records the selection of whole-visit revisions, notes the condition under which to revisit it (if disjoint concurrent edits outpace two coordinators before Friday exports), and states what `tablet-sync` (base revision IDs, whole-payload + idempotency-key submission, `needs_review` feedback) and `review-export` (revision comparison over active heads and common ancestor, explicit `resolved_revision_ids`, holding `needs_review` visits out of the CSV) must accommodate.

### Remaining for Phase 2 approval

Before I move to **Phase 3** (updating `docs/intent/record-store/record-store-specs.md`):

1. Let me know any edits to `docs/intent/record-store/decisions/concurrent-visit-edits.md` or `docs/intent/record-store/record-store-design.md`.
2. Let me know how you'd like to triage the 9 Phase 2 edge-case probe items from above (which to settle in the LLD now vs. defer as open questions).
3. Confirm whether you'd like `docs/high-level-design.md` updated to clear the `concurrency choice open` status once this LLD is approved.