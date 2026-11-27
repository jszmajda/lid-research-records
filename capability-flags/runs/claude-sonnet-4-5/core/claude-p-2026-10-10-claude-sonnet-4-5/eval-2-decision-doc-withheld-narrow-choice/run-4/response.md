**Phase 2 complete: LLD updated with 2Q decision**

I've updated `docs/intent/previews/previews-design.md` with:

1. **2Q Eviction Policy details** — two queues (25% first-use FIFO, 75% reuse LRU), ghost list for promotion tracking, and eviction order that protects comparison sheets from sequential screening scans.

2. **Decisions & Alternatives table** — records the three candidates (LRU, frequency-based, 2Q), the chosen approach, and the rationale tied to your workload pattern (sequential screenings alternating with comparison sets).

The decision is now fully documented in the table row. Given the depth of deliberation you mentioned, I can expand this into a standalone decision doc under `docs/intent/previews/decisions/eviction-policy.md` with the full options analysis, criteria, and selection rationale — the table row would then link to it. That's warranted when a cold reader would re-litigate the choice without seeing the competing tradeoffs.

Do you want me to write the full decision doc, or is the table row sufficient?