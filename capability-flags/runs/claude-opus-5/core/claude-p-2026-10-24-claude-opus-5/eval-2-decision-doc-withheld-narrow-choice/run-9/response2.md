Honestly? I don't think it does — and the reason is specifically that the argument was long, not despite it.

The LID test for a decision doc is read from where the decision *landed*, looking forward: would a cold reader re-litigate this without the full options-against-criteria workup in front of them? Not "was it hard to get here?" A table row can come out of a three-meeting argument; that's the normal case, not the exception. The length of the thread is a symptom, not the test.

Two things specifically point at the row here:

- **It's contained to one node.** Your HLD states that nothing outside the worker reads cache files, pins entries, or consumes eviction metadata, and all three options you sketched kept their changes inside the preview cache. No other design node gets sized around the result, so there's nothing downstream that needs to lean on the reasoning.
- **One line settles the reversal a cold reader would be tempted toward.** The temptation is "why not just LRU, this bookkeeping is a lot" — and "a screening pass touches thousands of sheets once each and would evict an LRU cache's entire comparison working set" answers it on the spot. A doc would mostly restate that at length.

There's also a mild cost to writing one: decision docs are meant to be rare, and a `decisions/` directory that fills up stops signalling which choices are actually live.

What I'd do instead, if the row feels too thin for the weight of the argument: the rationale cell is the place to spend a bit more. Right now it names the scan argument and the accepted cost; I could add the concrete numbers from your HLD — ~6,000 distinct clips viewed weekly against a 12 GiB / ~2 MiB budget of roughly 6,000 sheets — so a cold reader sees immediately that one week of screening can turn over the entire cache. That's the fact that makes 2Q obvious rather than fussy, and it fits in the cell.

That said, this is your call and you were the one in those meetings — if you want the doc, say so and I'll write it at `docs/intent/previews/decisions/cache-replacement-policy.md` with the three options, the criteria they were traded against, and the selection, and link it from the Decisions row.

Either way, the two open items from the last stop still need you: the HLD's stale "eviction policy remains open" line at `docs/high-level-design.md:14`, and which of the probe gaps to settle in the LLD now.