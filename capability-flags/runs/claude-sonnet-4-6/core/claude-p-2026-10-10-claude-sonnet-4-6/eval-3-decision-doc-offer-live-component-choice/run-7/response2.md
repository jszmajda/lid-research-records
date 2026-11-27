Written to `docs/intent/record-store/decisions/concurrency-policy.md`. Here's what's in it:

**Context** — frames the problem as the server's inability to infer scientific field relationships, establishes what's at stake (an incorrect combined record reaching the export), and names what this choice controls downstream.

**Decision Elements** — six criteria. Scientific correctness risk, preservation of worker intent, and review volume are all major; implementation complexity, tablet submission requirements, and review decision quality are moderate. Scientific correctness risk names the tenet it turns on explicitly.

**Options** — both given their strongest honest representation:
- *Whole-visit revisions*: simple ID comparison on the server, full visit payload submitted, coordinator sees complete alternatives, every concurrent edit creates review work
- *Field-aware three-way merge*: most concurrent edits resolve automatically, substantially smaller queue, but server-constructed combined records bypass coordinator review, merge rules can't reliably capture field pairs with scientific relationships (species code ↔ cover estimate being the concrete example), and tablet change-tracking adds device-side complexity

**Selection** — turns explicitly on scientific correctness risk and worker-intent preservation. Names field-aware merge as the credible revisit path, but only if the team consciously decides to accept the scientific risk for known field pairs.

**Downstream obligations** spells out exactly what tablet-sync and review-export will have to accommodate: `base_revision_id` tracking and the "competing revision exists" surface on tablets; revision comparison screen and export exclusion of unresolved visits on the review-export side.

Still at the Phase 2 stop. Ready to proceed to Phase 3 (EARS spec updates) on your approval.