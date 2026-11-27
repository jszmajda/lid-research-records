I'd say no. A row in the previews LLD's Decisions & Alternatives table is enough, and I'd still lean that way after the three meetings and the thread.

**Why a row**

- **The test is the landed state, not the debate.** A decision doc earns its place when a cold reader would still re-litigate the choice without seeing the options and criteria. Once the LLD says "2Q, because long screenings produce one-use sheets and comparison sheets are the ones worth protecting," that reads as a reasoned choice. How long it took to decide doesn't count.
- **One node is affected.** Every consequence stays inside the preview cache. The API, render queue, and disk budget don't move, and no other node is sized around the result. Docs in this skill are kept for choices that other nodes are about to be built around.
- **The row can hold what a reader would need.** It can name LRU and frequency-with-aging as the alternatives, give the scan-resistance rationale, and say that the queue split is tuned against observed workloads. That answers the "why not LRU?" question in a line.

**The case for a doc**

The context section says the right policy varies by production. A future reader might be tempted to swap policies if a workload shifts. That's real, but it's a "revisit if X" note, and it fits in the row or under Open Questions. It doesn't need a standalone document.

**It's your call.** If you still want a full decision doc, say so and I'll write it. I'd put it at `docs/intent/previews/decisions/`, following the decision-doc template, and link it from the LLD's Decisions row. Since the three options are already sketched, it would be quick to produce.

Which would you like: the row only, or the doc plus the row?

My earlier questions are still open:

1. Do you approve the HLD edit?
2. Do you want the candidate tenet added?
3. Do you have a starting 2Q queue split, or should I sketch options?