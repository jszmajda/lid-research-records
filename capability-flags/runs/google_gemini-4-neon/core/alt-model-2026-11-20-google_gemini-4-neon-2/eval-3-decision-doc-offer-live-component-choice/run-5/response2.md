Written `docs/intent/record-store/decisions/concurrent-visit-edits.md` and linked it from the `Decisions & Alternatives` table in `docs/intent/record-store/record-store-design.md`.

### What's in the Decision Doc

- **Context**: Captures TidePlot's offline survey scale, the coupling between scientific fields, and the standing invariant that original submissions are never discarded.
- **Decision Elements**: Five weighted criteria grounded in the HLD tenets and non-goals — whole-visit scientific integrity (**major**), operational simplicity without dedicated administration (**major**), inspectable provenance (**moderate**), coordinator review volume and Friday export throughput (**moderate**, cutting against whole-visit revisions), and tablet storage/sync complexity (**minor**).
- **Options in the Domain**: Full descriptions, worked examples on a concurrent edit to the same visit, and per-criterion fit analyses for both **Whole-visit revisions** and **Field-aware three-way merge** (making the strongest case for why field-aware merging stays a credible alternative when disjoint edits are frequent).
- **Selection & Downstream Obligations**: Explains why whole-visit revisions wins on the major criteria, notes the revisit condition if disjoint-edit review volume outstrips two coordinators, and specifies what `tablet-sync` (persisting `base_revision_id`, whole-visit payloads, surfacing `unresolved` status) and `review-export` (side-by-side revision comparison, exact `contributing_revision_ids` resolution, excluding `unresolved` visits from Friday CSV exports) must accommodate.

---

### Remaining Phase 2 Stop Items

Before moving to Phase 3 (`docs/intent/record-store/record-store-specs.md`):
1. Let me know any edits you want to `docs/intent/record-store/decisions/concurrent-visit-edits.md` or `docs/intent/record-store/record-store-design.md`.
2. Let me know how you'd like to triage the 9 Phase 2 LLD edge-case probe items from the previous message (which to settle in `record-store-design.md` now vs. defer as open questions).
3. Confirm whether you want the stale "concurrency choice open/pending" notes in `docs/high-level-design.md` and `docs/intent/site-catalog/site-catalog-design.md` updated as well.