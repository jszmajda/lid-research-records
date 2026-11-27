Written: `docs/intent/record-store/decisions/whole-visit-revisions.md`, linked from the LLD's Decisions & Alternatives table and Downstream Contract.

It covers both options in full, including field-aware merge's strongest case and why it stays credible: it wins on review volume, export readiness, and submission size, and becomes the better choice if the queue becomes unmanageable, full snapshots become costly, or safe species-entry merge rules plus field-level provenance become feasible. It also records the criteria and tenets, what whole-visit forecloses, and the revisit triggers.

The downstream section spells out the accommodation:
- Tablet-sync tracks base revision IDs, sends complete snapshots, treats stale bases as review work, and needs no merge rules.
- Review-export builds whole-revision comparison, resolves by selecting one revision, re-checks status at export time, and keeps provenance revision-level.

The five forks from my last message are still open — resolution shape, plot mutability, root collision, cover encoding, and editing unresolved visits. The doc records the current defaults. Reply with answers or approval, and I'll fold them in before moving to tablet-sync and review-export.