**Phase 2: Record-Store LLD**

Updated `docs/intent/record-store/record-store-design.md` with the whole-visit revision design.

It now defines:

- Complete immutable revisions, each based on a prior revision.
- A stale-base submission as a retained competing revision rather than an overwrite.
- An unresolved visit as having no usable current state.
- Append-only review outcomes that record the coordinator, considered revisions, and selected current revision.
- Tablet-sync obligations: retain the base revision ID, send the full payload, retry idempotently, and show review-pending status.
- Review/export obligations: compare full competing payloads and lineage, withhold unresolved visits from CSV export, and preserve traceability from export back to revision and review outcome.
- A Decisions & Alternatives table that records why whole-visit revisions were chosen and why field-aware three-way merge remains a credible future option but is not selected now.

The field-aware alternative is retained as a design alternative because it could reduce review volume by combining independent changes. It remains unsuitable for this release because it needs maintained merge rules and field-level provenance, and it could automatically combine scientifically related changes without recognizing that relationship.

**LLD Gap Probe**

The LLD-level probe identified these decisions to make or explicitly defer:

1. May a coordinator create a new manually composed complete revision while resolving a conflict, or must they select one submitted revision?
2. If a new submission arrives while a coordinator is resolving a visit, should the resolution fail and be retried against the expanded conflict set, or resolve only the revisions it explicitly considered?
3. What is the idempotency-key scope and what precisely constitutes an identical submission?
4. Must an initial submission omit a base revision, and must every later revision have exactly one valid parent revision?
5. What atomic rule prevents two simultaneously received submissions based on the same current revision from both becoming current?
6. Should plot-reference validation use the catalog state at submission receipt, or the catalog version the worker had offline?
7. Which stable error and status shapes must the API expose for invalid bases, idempotency mismatches, unknown visits, unresolved visits, and invalid review operations?

The first question changes the scientific meaning of review and needs your decision before the LLD can be final. My default reading of “keep each submitted visit intact” is that a coordinator selects one submitted revision, rather than composing a new record, but the current wording supports either.

Should the LLD require coordinators to select a submitted revision only, or allow them to create a manually composed complete revision during resolution?