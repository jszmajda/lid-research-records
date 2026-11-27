My recommendation is no: the table row already carries it, and I'd keep the full doc for something that clears a higher bar.

- **The test is the landed state, not the debate.** Would a cold reader of the finished design question 2Q or be tempted to reverse it? The row answers that in a few lines: editors alternate long screenings with repeated comparisons, 2Q protects the reused sheets, and the cost is two queues and a share to tune. A reader who wanted to revisit it has the criteria and the two alternatives in front of them.
- **The scope is one node.** The policy is private to the preview worker, and the API, render queue, and disk budget stay unchanged. No other design node is being sized around the result. That is the main condition that would justify a doc, and it isn't met here. How long the argument ran doesn't count toward the bar.
- **The decision isn't final.** The target share and the ghost-list question are still open, and a doc would either record them as open or go stale when tuning settles them. The LLD's Open Questions section is the better home.

A doc would be worth it if the choice had implications beyond previews. Moving to multiple workers, or exposing hit data to another node, would reopen it. If that happens, we can write one then, with real workload numbers behind it.

If you'd still like one for the team's benefit (for example, to put the three meetings and the thread to rest), it's your call and I'll write it. It would go in `docs/intent/previews/decisions/`, with the Decisions row linking to it.

Do you want the doc, or should I leave the row as is? Either way, the five open points from the design review are still waiting on your answers before I start the specs.