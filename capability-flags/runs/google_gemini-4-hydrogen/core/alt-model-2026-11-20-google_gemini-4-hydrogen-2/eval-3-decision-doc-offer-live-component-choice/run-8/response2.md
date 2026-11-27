I have written the decision doc at `docs/intent/record-store/decisions/concurrent-visit-edits.md` and linked it from `docs/intent/record-store/record-store-design.md`'s `Decisions & Alternatives` table.

It covers:
- **Decision Elements & Tenets**: Weights preservation of coupled scientific intent, coordinator review workload, rule maintenance/implementation complexity, and export readiness against the HLD tenets.
- **Options in the Domain**: Gives both **Whole-visit revisions** and **Field-aware three-way merge** full representations—including why field-aware merging remains the natural alternative to revisit if concurrent disjoint edits ever overwhelm coordinator capacity.
- **Downstream Obligations**: Specifies what `tablet-sync` (base revision IDs, complete payloads, `idempotencyKey`, surfacing `needs_review`) and `review-export` (side-by-side comparison, resolution provenance, excluding `needs_review` from the Friday CSV) must accommodate.

Before we move to **Phase 3** (updating `docs/intent/record-store/record-store-specs.md`):
1. Which of the 14 LLD edge-case probe gaps above should we resolve in `record-store-design.md` now vs. defer?
2. Do you approve the `record-store` LLD and decision doc to proceed to Phase 3?