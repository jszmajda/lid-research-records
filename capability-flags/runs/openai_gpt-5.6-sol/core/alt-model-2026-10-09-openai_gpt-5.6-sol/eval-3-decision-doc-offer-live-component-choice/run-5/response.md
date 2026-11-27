Updated `docs/high-level-design.md` to reflect that:

- Record-store uses whole-visit revisions.
- Concurrent revisions require coordinator review.
- The record-store contract remains to be completed.
- Tablet-sync and review-export depend on that completed contract, not an unresolved policy choice.

Please review and approve this HLD update. Once approved, I’ll complete the record-store LLD and run its edge-case probe.