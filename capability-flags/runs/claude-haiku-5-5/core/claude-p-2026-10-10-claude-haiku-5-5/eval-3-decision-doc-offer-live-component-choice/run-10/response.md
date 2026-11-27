**Phase 1 (HLD check): whole-visit revisions**

I changed one line in `docs/high-level-design.md`. The record-store row's state now reads "Drafted; whole-visit revisions selected, contract pending" instead of "concurrency choice open." Nothing else in the HLD needs to change. The architecture, tenets, and goals still hold under this choice.

One tension to decide on: the tenet "Prefer workflows two coordinators can operate without a dedicated systems administrator" is the one this choice leans against. Competing revisions add review work for the two coordinators. You've accepted a bigger review queue, so I'd record the choice as taken against that tenet's workload cost, not as consistent with it. Do you want that recorded?

**Decision record:** This choice will stay live for a cold reader, since the field-aware merge option is credible and tablet-sync and review-export will be sized around it. Would you like it recorded as a decision doc at `docs/intent/record-store/decisions/concurrency-policy.md`, with a Decisions & Alternatives row in the record-store LLD as the alternative? Or just the row?

Phase 2 (the record-store LLD rewrite, which drops the "OPEN" section) and Phase 3 (the REC spec updates) are next. I haven't drafted them yet, so please approve this phase first. Reply with:
1. Approve or change the HLD line.
2. Yes or no on the decision doc, or just the row.
3. Whether to record the tenet trade-off in the decision.