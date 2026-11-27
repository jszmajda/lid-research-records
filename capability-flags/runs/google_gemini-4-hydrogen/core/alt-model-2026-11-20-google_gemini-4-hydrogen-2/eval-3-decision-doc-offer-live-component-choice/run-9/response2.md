Written `docs/intent/record-store/decisions/concurrent-visit-edits.md` and linked it from the `Decisions & Alternatives` table in `docs/intent/record-store/record-store-design.md`.

It covers:
- **Both options in full**: Whole-visit revisions vs. field-aware three-way merge, including when field-aware merging remains a credible alternative to revisit (if disjoint-field collisions exceed what two coordinators can clear before the Friday export).
- **Decision elements & tenets**: Scientific integrity of coupled fields, coordinator review workload, export throughput under high concurrency, rule/maintenance burden, and auditability of submitted intent.
- **Downstream implications**: What `tablet-sync` (`base_revision_id` persistence, `idempotency_key`, full-payload submission, `needs_review` surfacing) and `review-export` (whole-visit comparison view, resolution with `contributing_revision_ids`, excluding `export_eligible: false` from CSV) must accommodate.

Before moving to **Phase 3** (`record-store-specs.md`), please confirm approval of `record-store-design.md` and let me know how you want to triage the 5 edge cases from the LLD probe (specify in the LLD now vs. defer):
1. **Late offline edit during resolution**: Require `contributing_revision_ids` to match the full current `pending_revisions` set (rejecting with conflict if a new revision arrived), or resolve the listed ones and leave the new revision in `needs_review`?
2. **Archived plot submissions**: Reject *new* visit creations (`base_revision_id: null`) for archived plots while allowing edits to existing visits, or accept any valid `plot_id`?
3. **Invalid `base_revision_id`**: Reject unknown/mismatched-visit `base_revision_id` as invalid input, or treat as a competing edit?
4. **Resolution authorization**: Enforce a distinct coordinator role in `record-store`, or require any authenticated user and rely on `review-export` / identity provider for role checks?
5. **Idempotency payload equality**: Canonicalized JSON equality or byte-exact comparison?