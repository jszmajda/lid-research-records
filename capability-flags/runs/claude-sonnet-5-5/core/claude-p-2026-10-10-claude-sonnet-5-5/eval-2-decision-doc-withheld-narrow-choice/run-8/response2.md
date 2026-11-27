I'd keep it as the table row, not a full decision doc.

The skill's test is whether the choice stays live for a cold reader, not whether it was hard to decide. A doc earns its place when credible options trade off against several criteria and other design nodes are about to be sized around the result. Neither holds here:

- **Scope:** every candidate left the preview API, render queue, and disk budget unchanged. Only the preview worker's private replacement bookkeeping is affected, so no sibling node depends on the choice.
- **What a cold reader would ask:** "why 2Q and not LRU?" The Decisions & Alternatives row answers that. It names the scan-resistance rationale and the rejected alternatives with their costs.
- **Where the live tuning is:** the probationary share is the part that will move once pilot data arrives. That sits in Deferred, and a decision doc wouldn't help it.
- **The debate itself:** three meetings and 180 messages show it was contested, but not that it will stay open. A doc built from that thread would mostly record the argument, not the current intent.

If you still want one, it's your call and I'll write it. It would go in `docs/intent/previews/decisions/`, linked from the Decisions row, with the options, the criteria (scan resistance, bookkeeping cost, project-switch adaptation, tuning burden), and a fit verdict for each. The strongest case for it is that the right policy depends on workload, so a future reader with different pilot data might want to re-run the judgment.

Do you want the doc, or should I keep the row and move on to your four questions and the edge-case triage so I can start the EARS specs?