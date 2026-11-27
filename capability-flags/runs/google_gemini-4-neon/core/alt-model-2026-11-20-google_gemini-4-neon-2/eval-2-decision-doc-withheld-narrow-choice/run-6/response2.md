I'd recommend **keeping it as the `Decisions & Alternatives` row** rather than writing a standalone decision doc.

The test for a decision doc is forward-looking from the landed design, not how long the debate ran:

- **Contained to one node:** 2Q is completely private to the preview worker. No other design node (`review-api`, the HTTP contract, the render queue, or the 12 GiB budget) is sized around it or needs to understand the tradeoff.
- **One row settles the cold reader's question:** A future reader wondering "why 2Q over LRU or aged frequency?" gets the workload rationale and the accepted tradeoff right in `previews-design.md`, and if production data later argues for another policy, swapping it is a local change inside the cache.
- **Debate length isn't the bar:** A long argument often still lands cleanly as a table row; keeping decision docs rare avoids accumulating docs for local, reversible choices.

That said, it's your call—if you'd still like a full decision doc at `docs/intent/previews/decisions/cache-eviction-policy.md`, say the word and I'll draft it. Otherwise, let me know how you'd like to handle the Phase 2 LLD edits and edge-case probe items before we move to Phase 3.