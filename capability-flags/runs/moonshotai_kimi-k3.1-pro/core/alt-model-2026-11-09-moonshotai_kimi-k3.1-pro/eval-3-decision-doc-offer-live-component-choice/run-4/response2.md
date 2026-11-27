Added `docs/intent/record-store/decisions/whole-visit-revisions.md` with the full trade-off analysis, including why field-aware three-way merging remains credible if review volume becomes unmanageable.

The record-store LLD now also specifies:

- Store-wide atomic idempotency-key reservation.
- Idempotent submission and resolution retries.
- Committed-snapshot retrieval and deterministic ordering.
- Access rules, structured errors, and validation precedence.
- Precise resolution provenance.
- Concrete tablet-sync obligations: base revision IDs, complete payloads, persisted retry keys, and honest handling of unresolved acceptance.
- Concrete review/export obligations: whole-revision comparison, stale-review refresh, resolution retries, and exclusion of unresolved visits from CSV exports.

The follow-up design probe found one remaining ambiguity: when a resolution simultaneously targets a resolved visit, a non-competing revision, and a stale head set, the LLD does not say whether `visit_not_unresolved`, `revision_not_competing_head`, or `stale_competing_heads` takes precedence. Should I define that precedence now, or defer it to implementation?