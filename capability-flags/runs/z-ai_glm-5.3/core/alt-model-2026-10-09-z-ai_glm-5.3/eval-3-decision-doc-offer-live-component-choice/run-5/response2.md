Written: `docs/intent/record-store/decisions/concurrent-edit-policy.md`, linked from the LLD's Decisions & Alternatives row. It covers the shared gate and criteria, both options at their strongest honest representation, why merge remains credible — with explicit reopen conditions (chronically unmanageable queue at first-season volume, or coordinator staffing growth) — and the downstream obligations: tablet-sync tracks base revision IDs, submits complete payloads, and explains "accepted but pending review" outcomes to workers; review-export gets the side-by-side revision comparison, resolved-only export eligibility, and the pre-Friday queue view.

Still open from the Phase 2 stop:

1. **Resolution amendment** — may a coordinator modify fields while resolving (a coordinator-authored revision atop the chosen one), or is resolution strictly pick-one?
2. **First submissions to an archived plot** — does the store reject them, or is the catalog's new-visit picker rule sufficient?

Answer those (or defer them), and on your approval of the design I'll proceed to Phase 3: updating the REC specs — REC-001–006 stay valid; new specs for base-revision handling, the frozen current, resolution semantics, and the rejected-submission log.