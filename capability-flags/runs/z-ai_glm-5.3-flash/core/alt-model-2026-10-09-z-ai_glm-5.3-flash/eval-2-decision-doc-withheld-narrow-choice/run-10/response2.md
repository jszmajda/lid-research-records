Honestly? I'd say no — and here's why. The test for a decision doc is how the choice reads *after it lands*, not how hard it was to reach: would a cold reader re-litigate it, and are other design nodes about to be sized around the result? This choice fails both. The eviction policy lives entirely inside the preview worker — no other node reads cache files or consumes eviction metadata, and nothing else gets sized around it. The Decisions & Alternatives row already records all three options and the scan-resistance-vs-bookkeeping rationale a future reader would need. Three meetings and 180 messages is deliberation heat, not landed non-obviousness — writing that history into a doc is exactly the residue the docs-carry-current-intent rule strips. A directory full of decision docs is a smell, and this one wouldn't earn its place.

That said, it's your call and your repo — if you want the doc anyway, I'll write it (context, criteria, the three options, selection) in `docs/intent/previews/decisions/` and link it from the row.

Either way, the Phase 2 stop still needs your ruling before I cascade to EARS:

1. Decision doc: skip, or write it?
2. The five probe gaps from my last message — fix in the LLD now, defer as open questions, or a mix?