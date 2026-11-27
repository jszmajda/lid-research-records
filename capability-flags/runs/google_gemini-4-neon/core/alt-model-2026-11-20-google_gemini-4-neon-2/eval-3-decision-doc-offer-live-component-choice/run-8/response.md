Updated `docs/intent/record-store/record-store-design.md` for **Phase 2 (LLD)** around whole-visit revisions. Stopping here for your review before updating EARS specs (Phase 3).

### Summary of `record-store` LLD changes

- **Revision model & visit states**: Every worker submission (`kind: submission`, `base_revision_id`) and coordinator resolution (`kind: resolution`, `resolved_revision_ids`) creates an immutable whole-visit revision preserving the complete payload (`plot_id`, `observation_date`, `observers`, `species_cover`, `notes`), author/coordinator ID, and server receipt time. A visit is `current` (export-eligible) when it has one active head revision, and `needs_review` (excluded from export) when two or more competing active heads exist.
- **Transitions**: Initial creation (`base_revision_id: null`), linear fast-forward update (matching the sole active head), concurrent branching edit (earlier `base_revision_id` or arrival during `needs_review` keeps competing heads intact), and coordinator resolution (explicitly names `resolved_revision_ids` so a late-arriving edit during review stays in `needs_review` rather than being silently absorbed).
- **Contract operations**: Defined `Submit visit revision`, `Get current visit state`, `Get visit history`, `List unresolved visits` (with competing heads and nearest common ancestor), and `Resolve competing revisions`, plus validation and `idempotency_key` semantics.
- **Downstream obligations**: Documented `tablet-sync` and `review-export` contracts as cascade obligations owned by `record-store`; neither sibling node has been touched.
- **Decisions & Alternatives**: Recorded whole-visit revisions (vs. field-aware three-way merge), explicit `resolved_revision_ids` on resolution, and excluding `needs_review` visits from export.

---

### Decision doc offer

The concurrency policy choice (whole-visit revisions vs. field-aware three-way merge) stays genuinely live for a cold reader — both options trade real criteria (coordinator queue size vs. merge-rule maintenance and whole-visit scientific integrity), and both `tablet-sync` and `review-export` are about to be sized around it.

Would you like to record this as a standalone decision doc at `docs/intent/record-store/decisions/concurrent-visit-edits.md` (linked from the LLD's Decisions & Alternatives row), or keep just the Decisions & Alternatives table row as currently drafted?

---

### Phase 2 LLD edge-case probe (for triage)

An independent probe of `docs/intent/record-store/record-store-design.md` surfaced these internal gaps. For each, let me know which to settle in the LLD now vs. defer as open questions:

1. **Invalid lineage / duplicate creation**: What happens if `base_revision_id: null` arrives for an existing `visit_id` (new idempotency key), or if `base_revision_id` does not exist / belongs to another visit?
2. **Degenerate or stale `resolved_revision_ids`**: What happens if `resolve` passes an empty list, duplicate IDs, a single head (e.g., coordinator editing a `current` visit or partially resolving a `needs_review` visit), or an ID that was already superseded?
3. **Per-visit atomicity**: Must concurrent mutations to the same `visit_id` (e.g., two fast-forward submissions racing, or a submission racing a resolution) execute atomically/serializably?
4. **Idempotency key scoping & replay**: Is `idempotency_key` scoped per `(author_id, operation)` or globally? Does payload equivalence include `base_revision_id` / `resolved_revision_ids`? Can a *rejected* key be retried with corrected input, and does replaying an *accepted* key return the original `review_state` at acceptance time?
5. **`plot_id` immutability & archived plots**: Can a later revision change `plot_id` to a different valid plot, and can an *initial* visit creation (`base_revision_id: null`) reference an already-archived plot?
6. **Payload completeness**: Which fields are required vs. optional (e.g., empty `observers`, empty `species_cover`, null `notes`), and where does schema validation stop short of out-of-scope botanical validation?
7. **Nearest common ancestor (LCA) in multi-head DAGs**: When `List unresolved visits` has 3+ active heads or multiple incomparable LCAs after prior resolutions, should it return `null`, a set, or a deterministic single ancestor?
8. **Filtering & ordering**: When filtering `List unresolved visits` by site or date range and competing heads disagree on `plot_id` or `observation_date`, does the visit match if *any* head matches? What ordering is guaranteed for `Get visit history` and `active_heads`?
9. **Unknown `visit_id`, role boundaries & error taxonomy**: What happens on unknown `visit_id` for reads/resolve, can coordinators also call `submit`, and which distinct rejection categories must the contract expose?

---

### Next step

1. Review `docs/intent/record-store/record-store-design.md` and let me know any edits.
2. Confirm whether you want the standalone decision doc or just the Decisions & Alternatives row.
3. Triage the edge-case probe items above (fix in LLD vs. defer).
4. Also let me know if you'd like `docs/high-level-design.md` updated to clear the `concurrency choice open` status once this LLD is approved.

Once you approve Phase 2, I will proceed to **Phase 3** to update `docs/intent/record-store/record-store-specs.md`.