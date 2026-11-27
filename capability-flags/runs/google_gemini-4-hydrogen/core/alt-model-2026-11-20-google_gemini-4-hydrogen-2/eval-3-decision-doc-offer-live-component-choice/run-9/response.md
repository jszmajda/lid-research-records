Updated `docs/intent/record-store/record-store-design.md` for **whole-visit revisions** (and updated the `record-store` state in `docs/high-level-design.md` from `Drafted; concurrency choice open` to `Drafted`).

### Summary of `docs/intent/record-store/record-store-design.md`
- **Concurrency Model**: Each accepted submission creates an immutable revision (`revision_id`, `author_id`, `receipt_time`, `base_revision_id`, full `payload`). Initial creation or fast-forward edits (`base_revision_id == head_revision_id` while `clean`) advance `head_revision_id`; mismatched `base_revision_id` or edits arriving while `needs_review` are persisted into `pending_revisions` and set `review_status: needs_review`.
- **Submission Envelope & Validation**: Requires `visit_id`, `idempotency_key`, optional `base_revision_id`, and complete `payload`; enforces worker auth, idempotency (same key + identical payload returns original result; different payload is rejected), field validation, and `plot_id` resolution against `site-catalog`.
- **Retrieval & Resolution**: Current-state retrieval exposes `review_status`, `export_eligible` (`true` only when `clean`), `head_revision`, and `pending_revisions`. Resolution records `coordinator_id`, `resolved_at`, `contributing_revision_ids`, and either promotes a `selected_revision_id` or persists a reconciled `payload`, clearing resolved revisions from `pending_revisions`.
- **Decisions & Alternatives / Downstream Obligations**: Recorded whole-visit revisions vs. field-aware three-way merge, plus contract obligations for `tablet-sync` and `review-export` (held until we cascade to those segments).

### LLD-Level Edge-Case Probe (`record-store` internal gaps)
Please triage which of these to specify in the LLD now vs. defer:
1. **Late offline edit during resolution**: If a tablet submits a new competing revision `R4` while a coordinator is resolving `[R2, R3]`, should resolution require `contributing_revision_ids` to match the full current `pending_revisions` set (rejecting with a conflict so the coordinator sees `R4`), or resolve `[R2, R3]` and leave the visit `needs_review` with `[R4]`?
2. **Submission for an archived plot**: Should `record-store` reject *new* visit creations (`base_revision_id: null`) referencing an archived `plot_id` while allowing *edits* (`base_revision_id != null`) to existing visits on archived plots, or accept any valid `plot_id` regardless of archived status?
3. **Invalid `base_revision_id`**: What should happen if a submission references a `base_revision_id` that does not exist on `visit_id` (e.g., unknown UUID or revision from another visit) — reject as invalid input, or treat as a competing edit?
4. **Resolution authorization**: Does `record-store` enforce a distinct coordinator role on the resolution operation, or only require an authenticated user (relying on `review-export` / identity provider for role checks)?
5. **Payload equality for idempotency**: Should `idempotency_key` payload comparison be canonicalized JSON equality (ignoring key order/whitespace) or byte-exact?

### Decision Doc Offer
Because the **whole-visit revisions vs. field-aware three-way merge** choice trades multiple criteria (review queue size, merge-rule maintenance, scientific field coupling) and both `tablet-sync` and `review-export` will be sized around it, would you like me to also record it as a full decision doc at `docs/intent/record-store/decisions/concurrent-visit-edits.md` (linked from the Decisions table), or is the `Decisions & Alternatives` row in `record-store-design.md` sufficient?

**Next step**: Once you approve the LLD (with any edge-case triage and decision-doc preference), I will proceed to **Phase 3** to update `docs/intent/record-store/record-store-specs.md`.