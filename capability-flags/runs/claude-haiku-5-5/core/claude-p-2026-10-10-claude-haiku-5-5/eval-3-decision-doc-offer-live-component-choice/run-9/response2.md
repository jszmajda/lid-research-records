I wrote the decision doc at `docs/intent/record-store/decisions/whole-visit-revisions.md`. Nothing else changed in this step.

**What it covers**
- **The decision and its context:** the record store treats each concurrent edit as a whole-visit revision. Concurrent submissions stay as competing revisions until a coordinator resolves them. No submission is discarded, and the record store never merges fields automatically.
- **Criteria:** each criterion names the HLD tenet it comes from. I added one criterion that the HLD doesn't name: the risk that coordinators clear a large review queue without reading it. It counts against whole-visit revisions, which is the reason I think the choice could be reversed.
- **Both options, with the same two example edits:** field-aware merging is described fairly, with its strengths: fewer review items and higher export readiness.
- **Why whole-visit wins:** scientific integrity matters more than review workload, because a combined visit that no worker submitted is harder to explain to the partner.
- **Why we'd still consider the other approach:** the doc names two measurable conditions to check over the first season. The first is coordinators clearing the queue without reading it. The second is Friday exports missing most plots because of unresolved visits. Either would reopen the decision.
- **What tablet-sync must accommodate:** keep the base revision ID for each local edit, keep the pending payload until the server acknowledges it, and show competing revisions on reconnection without merging fields.
- **What review-export must accommodate:** a field-level comparison view, an export set that excludes visits with unresolved competing revisions, and a report of which visits were excluded.

**Still open**
- **Decisions row:** the record-store LLD has no Decisions & Alternatives table yet. The row linking to this doc belongs with the Phase 2 LLD draft, which I'll do next.
- **Tenet:** I haven't added the proposed HLD tenet about keeping visits intact. The doc cites only the existing tenets, so it doesn't depend on that decision. Tell me whether to add it.

I'm stopping here for your review before Phase 2.