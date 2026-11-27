Honestly? My read is that this is a table-row case, not a decision-doc case — and I'd be doing you a disservice to just nod.

The doc's test isn't "was it hard?" — it's: **once this lands, would a cold reader find the choice non-obvious, question it, or be tempted to reverse it, not knowing why it went this way?** A long, hard argument is a *symptom* that the choice was contested in the room, not evidence it stays live once written down. The skill is explicit that a table row can come out of a very long debate.

Two things point the same way here:

- **It affects only this node.** Every option changed nothing but the preview worker's private replacement bookkeeping — same interface, same four-job concurrency, same 12 GiB budget. The `review-api` node can't even see the policy. That "affects only its own node" is a stated disqualifier for a full doc.
- **It lands as self-evident.** Once 2Q is written down as "separate first-use from reuse so scans don't churn the comparison set," that's a recognized cache policy a reader accepts; the one-line rationale in the row ("keeps a screening from evicting the comparison working set; LRU and aged-frequency alternatives noted") is enough for them to reconstruct *why*, not *what*.

So my recommendation: keep the Decisions row already in the LLD, and let the 2Q section's mechanism prose carry the detail. If a future workload actually threatens the split parameter, the *size-split tuning* is the thing that earns real space — and that's already filed as a deferred question.

That said, you're always right — if you want a full doc anyway, say so and I'll write `docs/intent/previews/decisions/eviction-policy.md` (owned by the previews node, no EARS IDs), lay out the three options against criteria, and link it from the row. Cost is a rare-artifact precedent: once one lives there, later readers expect the next consequential preview decision to have one too.

Which way do you want it — row (my recommendation) or full doc? And with that settled, do you still confirm the 2Q LLD + HLD tweak, and want me to triage the probe gaps and move to Phase 3 EARS?