Under the skill's *earns-its-place* heuristic, we evaluate from the landed state looking forward, rather than looking back at the deliberation:

> **Would a cold reader of the result find the choice non-obvious — would they question it, or be tempted to reverse it, not knowing why it went this way?**

A full decision doc is warranted when a decision stays genuinely live across multiple competing criteria, or when a future reader would re-litigate it without the full trade-offs recorded. 

Here, however:
1. **The change is entirely internal**: The replacement policy is strictly private to the preview worker; the external HTTP API, render queue concurrency, disk budget (12 GiB), and job-ticket semantics remain completely unchanged.
2. **Dominant rationale**: The mix of long sequential screenings and tight comparison loops directly eliminates basic LRU (which suffers scan thrashing) and frequency-with-aging (which lags project switches and adds counter overhead). 2Q directly addresses both without external side effects.
3. **Settled upon landing**: A cold reader inspecting the preview cache needs only to know that 2Q protects comparison sheets from screening scans without counter maintenance—which is captured concisely in the LLD's **Decisions & Alternatives** table.

A long or heated debate during deliberation is a common symptom, but once landed, this decision reads cleanly in the LLD table without a standalone document. That said, if you want a formal record of the three options and criteria to prevent future re-litigation, I can draft `docs/intent/previews/decisions/cache-eviction-policy.md`. 

Would you like to stick with the LLD table row, or proceed with creating the decision doc?