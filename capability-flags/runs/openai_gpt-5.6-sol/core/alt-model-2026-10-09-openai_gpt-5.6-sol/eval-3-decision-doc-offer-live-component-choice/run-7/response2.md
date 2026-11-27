Created `docs/intent/record-store/decisions/concurrent-visit-edits.md` and linked it from the LLD’s Decisions & Alternatives table.

The decision document covers:

- The strongest case for both whole-visit revisions and field-aware merging.
- Scientific coherence, review volume, maintenance, offline state, and explainability.
- Why field-aware merging remains credible if measured review volume becomes unsustainable.
- Tablet obligations around base revision IDs, complete payloads, retries, and `review_required`.
- Review/export obligations around complete revision comparison, provenance, stale-review detection, and CSV exclusion.

One state transition needs your decision next: if two tablets independently create the same visit UUID without a base revision, should the first arrival remain provisionally current while the visit enters review, or should neither revision become current until a coordinator resolves them?