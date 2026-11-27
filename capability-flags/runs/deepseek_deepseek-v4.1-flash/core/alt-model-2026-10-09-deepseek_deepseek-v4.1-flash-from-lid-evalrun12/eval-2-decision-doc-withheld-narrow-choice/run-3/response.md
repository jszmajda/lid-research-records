I stopped at the previews LLD boundary rather than running straight through to EARS and tests — the 2Q design still has a fork that's yours to settle, and specs written now would pin a reading you haven't chosen.

**HLD** — Replaced the stale "eviction policy remains open" line at `docs/high-level-design.md:14` with the selected policy. No architecture change, so nothing else moved. The review API segment is untouched: its design already forbids it from reading cache paths, counters, or policy config, and 2Q keeps all of that private.

**LLD** (`docs/intent/previews/previews-design.md`) — Drafted the 2Q mechanism: entries are admitted to a bounded FIFO **A1in**; a hit promotes to LRU **Am**; a hit in Am refreshes it; admission evicts A1in (oldest first) down to its target, then Am (LRU), until back under 12 GiB. Recorded the choice as a Decisions & Alternatives row against LRU and aged frequency, with the "replacement bookkeeping stays private" tenet as the tie-breaker. I kept it as a row, not a standalone decision doc — the choice affects only this node and the row already carries the tradeoff. Say the word if you'd rather promote it to a full doc.

Two things I did **not** decide for you:

1. **A1in/Am split.** 2Q needs a target share for A1in out of the 12 GiB. Bigger A1in gives a freshly rendered sheet more time to earn a second request; smaller A1in resists a screening scan harder but can evict a lightly reused sheet before its reuse arrives. Candidates: 10% / 25% / 50%.
2. **Fixed vs. adaptive.** Keep the split a tuned constant (two queues, as sketched), or use textbook 2Q with an **A1out ghost list** that resizes A1in based on how often evicted keys get reclaimed — less manual tuning, more bookkeeping. "Accept the extra bookkeeping" could mean either.

Pick a split and a variant — or tell me to choose a default and mark it tunable — and I'll set it in the LLD, write the PREVIEW eviction specs, and run the edge audit before any tests.