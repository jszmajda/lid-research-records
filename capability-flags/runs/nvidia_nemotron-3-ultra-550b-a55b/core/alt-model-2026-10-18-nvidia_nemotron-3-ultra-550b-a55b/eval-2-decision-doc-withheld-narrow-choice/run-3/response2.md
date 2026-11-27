Yes, this clears the bar. The earns-its-place test:

> **Would a cold reader of the landed system question the choice or be tempted to reverse it?**

- Three credible options (LRU, frequency+aging, 2Q) traded against multiple criteria (bookkeeping cost, scan resistance, project-switch adaptation, comparison-sheet protection)
- Other design nodes (12 GiB budget, 4-job render queue, fixed HTTP interface) are sized around this result
- A future maintainer facing a different workload would plausibly ask "why not LRU? simpler" or "why not frequency? protects popular clips"
- The 180-message thread is exactly the deliberation a decision doc memorializes

A table row settles "why this?" for an obvious choice. This choice stays *live* — a reader would re-litigate it without the full tradeoffs laid out.

I'll create it at `docs/intent/previews/decisions/eviction-policy-2q.md` (segment-level, owned by previews node). Want me to proceed?