Decision doc is written at `docs/intent/record-store/decisions/concurrency-policy.md`, and the LLD's Decisions & Alternatives row now links to it instead of carrying an inline rationale.

It covers:
- **Gate**: no silent discard — both options pass it, so it doesn't decide anything.
- **Criteria**: scientific-relationship risk and review workload (both major), implementation/maintenance burden (moderate), submission size/complexity (minor) — with each option scored against all four.
- **Selection**: whole-visit revisions wins because the scientific-relationship risk cuts against inspectability more sharply than a bigger queue cuts against coordinator workload — a wrong auto-merge is a correctness problem that might not surface until the partner questions the data, vs. a queue size the coordinators can see and staff around.
- **Downstream obligations**: tablet-sync must retain base revision IDs and surface the unresolved/pending state to workers; review-export must build the revision-comparison view, record coordinator identity + contributing submission IDs on resolution, and hold unresolved visits out of export.
- **When to revisit**: field-aware merge comes back into play only if the review queue becomes sustainably unsustainable *and* a merge rule could be scoped narrowly enough (e.g. observer-name corrections only, never species/cover-estimate fields) to bound the relationship risk — not before.

That closes out the record-store LLD. Next up whenever you're ready: tablet-sync and review-export designs, each built against the contract this node now defines.