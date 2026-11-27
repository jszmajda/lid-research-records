I wrote the decision doc at `docs/intent/record-store/decisions/concurrency-model.md`, and pointed the LLD's Decisions & Alternatives row at it.

It covers:
- **Decision elements**: scientific-relationship risk and review workload (major), implementation/maintenance burden and Friday export readiness (moderate) — each tied to a project tenet or goal.
- **Both options analyzed honestly**, including field-aware merge's real strengths (smaller review queue, faster export readiness) — it loses on the one major criterion that's a difference in kind, not degree: it can't tell a scientific relationship from two unrelated fields, no matter how the rules are tuned.
- **Selection**: whole-visit revisions, with the reasoning for why that criterion outweighs the other two.
- **Downstream obligations**: tablet-sync must retain base revision IDs and surface competing-revision outcomes to workers; review-export needs a revision-comparison view and must exclude unresolved visits from the CSV.
- **When to revisit**: if the review queue outgrows what two coordinators can clear before a normal Friday export, or data later shows most competing revisions touch disjoint fields anyway.

That still leaves the LLD-level edge-probe questions from before open — want to work through those now (first submission's base, 3+-way competing revisions, resolution reversibility, what a tablet sees mid-unresolved), or defer them as open questions in the LLD and move to Phase 3 EARS updates?