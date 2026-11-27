I'd stick with the **Decisions & Alternatives** table row in `docs/intent/previews/previews-design.md` rather than a full decision doc:

1. **Affects only one node**: Cache replacement is private to the preview worker (`docs/high-level-design.md` and `review-api-design.md` depend only on the fixed HTTP interface), so no sibling nodes are sized around this choice.
2. **A row settles the cold-reader question**: A future reader seeing a mixed screening + comparison workload only needs to know why 2Q beat LRU (scan resistance) and aged frequency (counter/aging overhead and project-switch lag)—which the single table row already answers.
3. **Debate length isn't the bar**: Long deliberations often end in a table row; full decision docs are reserved for choices that stay live across multiple nodes or would otherwise be re-litigated.

That said, it's your call—if you'd still like a standalone decision doc at `docs/intent/previews/decisions/cache-eviction-policy.md` linked from the table, say the word and I'll write it. Otherwise, let me know how you'd like to triage the Phase 2 probe items and whether we're ready for **Phase 3 (EARS specs)**.