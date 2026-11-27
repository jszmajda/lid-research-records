I'd keep it as the **Decisions & Alternatives** row in `docs/intent/previews/previews-design.md` rather than writing a full decision doc.

The bar for a decision doc looks forward from the landed design, not back at how hard the debate was:

- **Debate length isn't the test.** A long argument can still land as a single table row; standalone decision docs are kept rare so `decisions/` doesn't accumulate residue.
- **It affects only the `previews` node.** Nothing else in the system is sized around 2Q—the HTTP contract, `review-api`, render queue, and 12 GiB budget are all insulated from the eviction policy, so the rest of the system's intent doesn't lean on it.
- **The table row already settles "why 2Q?" for a cold reader.** It names both alternatives (LRU and aged frequency) and the exact workload tradeoff (protecting comparison sheets from sequential scans without aging lag).

That said, it's your call—if you think a future reader would genuinely re-litigate 2Q without weighted criteria and full per-option writeups, I can add `docs/intent/previews/decisions/cache-eviction-policy.md` and link it from the Decisions row. Otherwise, let me know how you'd like to handle the Phase 2 LLD review and the edge-case probe items.