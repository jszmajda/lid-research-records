I have written the decision doc at `docs/intent/record-store/decisions/concurrent-visit-edits.md` and linked it from `docs/intent/record-store/record-store-design.md`.

### Summary of `docs/intent/record-store/decisions/concurrent-visit-edits.md`

- **Decision Elements**:
  - **Gates**: No silent discard of submitted edits (eliminates Last-Write-Wins); no automated inference of botanical relationships.
  - **Weighted Criteria**: Scientific integrity of exported visits (**major**), rule maintenance and operational simplicity (**major**), coordinator review queue volume (**moderate**), and tablet/review-export contract complexity (**minor**).
- **Options & Why Field-Aware Three-Way Merge Remains Credible**:
  - **Whole-Visit Revisions**: Strong on scientific integrity and operational simplicity; weak on review queue volume because disjoint field edits still create competing revisions.
  - **Field-Aware Three-Way Merge**: Strong on reducing review volume when workers edit structurally unrelated fields (e.g., observer names vs. observation date), which would matter if coordinator capacity became the bottleneck or if teams split entry across tablets. Weak on scientific integrity because structurally disjoint changes (e.g., re-allocating species cover on one tablet while adding a note confirming original dominance on another) can still be scientifically contradictory and auto-export without review, and weak on maintenance due to custom scalar/list/species-map merge and provenance rules.
  - **Last-Write-Wins**: Eliminated at the no-silent-discard gate.
- **Downstream Accommodations**:
  - **`tablet-sync`**: Persist the server-assigned `revision_id` as `base_revision_id` (`null` on new visits), send complete visit payloads with an `idempotency_key`, and surface `needs_review` outcomes when an accepted edit branches instead of fast-forwarding.
  - **`review-export`**: Provide a side-by-side whole-visit revision comparison view over `active_heads` and their common ancestor, submit coordinator resolutions naming `resolved_revision_ids`, and hold `needs_review` visits (`current_revision: null`) out of the Friday partner CSV.

---

### Remaining Phase 2 Review for `record-store-design.md`

Before we move to Phase 3 (`record-store-specs.md`), does `record-store-design.md` + the decision doc look good as-is, and are there any of the Phase 2 edge cases you'd like to lock down in the LLD now rather than defer?

1. **Editing an existing competing head**: If a visit has `active_heads: [A, B]` and a worker submits `A'` based on `A`, does `A'` replace `A` (`[A', B]`) or add a third head (`[A, B, A']`)?
2. **Plot references**: Should `record-store` accept visits referencing an `archived` plot in `site-catalog` (e.g., captured offline before archival), and is `plot_id` immutable across revisions of a visit?
3. **Coordinator resolution idempotency**: Should coordinator resolution also take an `idempotency_key` for safe retries?