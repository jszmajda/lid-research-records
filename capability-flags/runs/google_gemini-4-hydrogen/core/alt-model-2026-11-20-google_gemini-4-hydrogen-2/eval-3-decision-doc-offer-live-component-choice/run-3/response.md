Updated `docs/intent/record-store/record-store-design.md` for **whole-visit revisions** (Phase 2 — LLD):

- **Submission Envelope & Validation**: Defined `visit_id`, `plot_id`, `base_revision_id` (`null` for initial creation), `idempotency_key`, and `payload`, plus server-assigned `submission_id`, `author_id`, and `received_at`.
- **Revision Model & State Transitions**: Initial creation (`clean`), fast-forward edit when `base_revision_id` matches `current_revision_id` (`clean`), and concurrent edit when `base_revision_id` is stale or unresolved work exists (`unresolved` with `competing_revisions`). Only `clean` visits are export-eligible.
- **Review Resolution & History**: Coordinator resolution records `resolution_id`, `resolver_id`, `resolved_at`, `contributing_submission_ids`, and `resolved_revision_id`, advancing `current_revision_id`. Full submission and resolution history remains retrievable.
- **Downstream Cascade Obligations & Decisions**: Documented obligations for `tablet-sync` and `review-export`, and recorded the choice in `Decisions & Alternatives`.

### 1. Decision Doc Offer
Because the concurrency policy trades multiple criteria (review queue size vs. merge-rule maintenance and scientific integrity) and both `tablet-sync` and `review-export` will be sized around it, would you like me to record it as a full decision doc at `docs/intent/record-store/decisions/concurrency-policy.md` (linked from the Decisions table), or keep just the Decisions & Alternatives table row?

### 2. LLD Edge-Case Probe (for triage: fix in LLD vs. defer)
1. **Invalid `base_revision_id` transitions**: What happens if a non-null `base_revision_id` arrives for a nonexistent `visit_id`, `base_revision_id: null` arrives for an existing `visit_id` (with a new `idempotency_key`), or `base_revision_id` belongs to a different `visit_id` or unknown UUID?
2. **`plot_id` immutability**: Can a subsequent edit for an existing `visit_id` change `plot_id`, or is `plot_id` immutable per visit and mismatched edits rejected?
3. **Idempotency key scoping & equivalence**: Is `idempotency_key` scoped globally, per `author_id`, or per `visit_id`? Must `visit_id`, `plot_id`, and `base_revision_id` also match on retry (not just `payload`), and is list order in `observers`/`species_cover` significant?
4. **Consolidated revision in history**: When a coordinator submits a consolidated payload, what `base_revision_id` and `author_id` does it carry, and does it appear in submission history or only in the resolution record?
5. **Concurrent, partial, or stale resolutions**: What happens if two coordinators resolve concurrently, or if `contributing_submission_ids` is empty, references a non-pending ID, or omits a newly arrived competing revision?
6. **Resolution idempotency & role checks**: Should review resolution also require an `idempotency_key` for retries, and should the LLD explicitly state coordinator-role authorization for resolution?
7. **API error shapes & not-found behavior**: Should the LLD specify error response shapes/codes and behavior when retrieving/resolving an unknown `visit_id` or resolving an already-`clean` visit?

*(Note: `docs/high-level-design.md` still notes `record-store` as `Drafted; concurrency choice open`; I can update that status line once this LLD is settled.)*

Please review `docs/intent/record-store/record-store-design.md`, let me know your decision-doc preference and how to triage items 1–7, and confirm when you're ready to proceed to Phase 3 (`record-store-specs.md`).