You're right — this does meet the bar for a decision doc.

Applying the test: **would a cold reader question this choice?** Yes. Seeing 2Q implementation with two queues, a 25/75 split to tune, and promotion bookkeeping, a future maintainer might reasonably ask "why not just use simple LRU?" The extra complexity isn't self-evidently necessary without the full tradeoff analysis.

The decision has:
- Three credible alternatives (each viable, not one-dominates-all)
- Multiple weighted criteria (bookkeeping cost, scan resistance, project-switch adaptation, working set protection)
- A tunable parameter (the queue split) that will invite second-guessing
- Real downstream implications (two queue data structures, promotion logic, eviction selection order)

The 180-message thread and three meetings aren't the test — but they're evidence that this choice *stays live*. The structure won't document itself.

**Recommendation: write the decision doc.** It'll memorialize the criteria and why 2Q's scan protection outweighed its bookkeeping cost — the judgment a table row can't capture at resolution.

Should I draft it at `docs/intent/previews/decisions/cache-eviction-policy.md`?