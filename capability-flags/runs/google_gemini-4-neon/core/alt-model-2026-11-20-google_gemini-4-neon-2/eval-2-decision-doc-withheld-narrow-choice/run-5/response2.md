I'd recommend keeping it as the `Decisions & Alternatives` row in `docs/intent/previews/previews-design.md` rather than writing a full decision doc.

The bar for a decision doc is forward-looking from the **landed** design, not how long the debate took:
- **Strictly local blast radius:** Nothing outside `previews` is sized around 2Q—the HTTP contract, render queue, 12 GiB budget, and `review-api` are all invariant to the eviction policy (and the HLD tenet keeps replacement bookkeeping private to the worker).
- **The table row already answers "why 2Q?":** A cold reader can see the alternatives considered (LRU, frequency-based eviction with aging) and the exact trade-off (protecting comparison sheets from sequential screenings at the cost of extra queue bookkeeping and a tunable split).

That said, it's your call—if you think a future maintainer will still re-litigate LRU vs. aged frequency vs. 2Q without the full weighted criteria laid out, say the word and I'll draft `docs/intent/previews/decisions/cache-eviction-policy.md` and link it from the LLD row. Otherwise, we can keep the row and triage the Phase 2 edge-case probe items above.