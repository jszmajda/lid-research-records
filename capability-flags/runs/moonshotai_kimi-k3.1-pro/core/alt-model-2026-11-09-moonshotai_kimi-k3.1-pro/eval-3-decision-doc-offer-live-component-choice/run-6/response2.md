Updated the record-store design and EARS specs:

- `docs/intent/record-store/record-store-design.md`
  - Resolves the concurrency, idempotency, reopening, retrieval, and error-handling gaps.
  - Explains why field-aware three-way merge remains credible: it reduces review volume and submission sizes, and could be reconsidered if those become demonstrated operational problems.
  - Details tablet obligations: complete-payload submissions, retained base revision IDs, stable retry keys, competing-revision handling, and no automatic rebasing.
  - Details review/export obligations: complete-revision comparison, exact expected-head sets, stale-resolution reloading, provenance, and exclusion of unresolved visits from CSV.

- `docs/intent/record-store/record-store-specs.md`
  - Expanded from 6 to 28 requirements covering preservation, revision state, retrieval/history, resolution, and failures.
  - Preserved the existing IDs and revised their wording where needed.

**Consistency report:** The specs cover the LLD’s behaviors without identified contradictions. Current versus unresolved states are explicitly scoped, and the requirements can be read independently of their section headings.

Please review and approve the EARS draft. Next is the intent-narrowing edge audit before any tests or implementation.