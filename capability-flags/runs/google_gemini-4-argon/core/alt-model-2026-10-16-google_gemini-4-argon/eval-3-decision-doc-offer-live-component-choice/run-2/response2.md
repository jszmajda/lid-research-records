I have written `docs/intent/record-store/decisions/concurrent-visit-edits.md` and linked it from `docs/intent/record-store/record-store-design.md`.

### Summary of `docs/intent/record-store/decisions/concurrent-visit-edits.md`

- **Context & Decision Elements**:
  - **Gate**: *No silent loss of submitted edits* (eliminates arrival-order overwrite).
  - **Weighted Criteria**: *Scientific cross-field integrity (major)*, *Operational simplicity and maintainability (major)*, *Coordinator review queue volume (moderate)*, and *Tablet payload and state footprint (minor)* — each tied to the HLD tenets and goals.
- **Options in the Domain**:
  - **Option 1: Whole-Visit Revisions** — complete immutable revisions linked via `base_revision_id` / `parent_revision_ids`, linear fast-forward when `base_revision_id` is the sole active head, and competing heads (`needs_review`) when edits fork.
  - **Option 2: Field-Aware Three-Way Merge** — strong representation of why it remains a credible contender (automatically merging disjoint edits like observer-list fixes and separate species entries to keep the weekly Friday coordinator review queue small as survey volume grows), paired with its clinical trade-offs on cross-field ecological dependencies (e.g., species re-identification coupled with cover adjustments or notes) and per-field provenance/merge-rule maintenance.
- **Selection & Downstream Accommodations**:
  - Explains why Option 1 wins on the major criteria and HLD tenets, what it forecloses, and what downstream nodes must accommodate:
    - **`tablet-sync`**: Persisting `base_revision_id` per synced visit across offline restarts, sending whole-visit payloads with an `idempotency_key`, and surfacing `needs_review` outcomes when a submission creates competing heads.
    - **`review-export`**: Providing a coordinator revision-comparison screen over `competing_revisions` and revision history, submitting whole-visit resolutions naming `resolved_revision_ids`, and holding `needs_review` visits out of the Friday CSV export while surfacing unresolved counts.

---

### Remaining Check Before Phase 3 (EARS Specs)

Before we move to **Phase 3 (`record-store-specs.md`)**, please confirm whether you approve `docs/intent/record-store/record-store-design.md` and `docs/intent/record-store/decisions/concurrent-visit-edits.md` as written, and whether you'd like to adjust or keep the current LLD handling for any of the Phase 2 edge cases:

1. **Stale resolution check**: Keep the requirement that `resolved_revision_ids` must match the entire active head set (`409 Conflict` if a new worker revision arrived during review)?
2. **Deferred items in LLD**: Keep `plot_id` mutability across revisions and concurrent identical-payload coalescing in *Deferred*, or settle either of them in the LLD now?