Yes — this clears the "earns-its-place" bar. From the landed state:

- Three credible alternatives (LRU, frequency+aging, 2Q) traded against **multiple criteria**: scan resistance, working-set protection, bookkeeping cost, tuning complexity, project-switch adaptation
- Downstream nodes are sized around it: queue split (25/75), promotion trigger (2nd access), no demotion
- A cold reader would plausibly re-litigate: "Why not LRU? Simpler." or "Why not frequency? Also protects repeats."

The LLD table row captures the headline; a decision doc would preserve the full criteria-weighted analysis so future maintainers don't have to reconstruct it.

Want me to create it at `docs/intent/previews/decisions/eviction-policy-2q.md`?