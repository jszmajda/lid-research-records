Under the skill's decision doc heuristic, we evaluate whether a full decision doc earns its place from the landed state, looking forward:

*Would a future reader, looking at the code and design cold, find 2Q non-obvious and be tempted to reverse or re-litigate it without the full trade-offs recorded?*

**Verdict: Yes, it earns a decision doc.**

While the choice feels settled after the team's debate, a cold reader looking at the preview worker in the future would likely ask:
- Why take on the multi-queue complexity, tuning parameters, and ghost-queue overhead of 2Q rather than a standard, off-the-shelf LRU?
- Why not use frequency/LFU-style tracking if the goal was retaining popular comparison sheets?

Because 2Q is a specialized algorithm chosen specifically to balance sequential screening scans against iterative comparison sets—and relies on parameters that will need tuning—having a standalone decision doc (`docs/intent/previews/decisions/cache-eviction-policy.md`) laying out the criteria, alternatives, and trade-offs will preserve that rationale and prevent future re-litigation.

Shall I draft the full decision doc at `docs/intent/previews/decisions/cache-eviction-policy.md` and link it from `previews-design.md`?