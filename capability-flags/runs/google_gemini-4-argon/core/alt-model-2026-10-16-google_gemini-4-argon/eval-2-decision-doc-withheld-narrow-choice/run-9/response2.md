I recommend keeping it as the `Decisions & Alternatives` table row in `previews-design.md` rather than creating a standalone decision doc.

In LID, the test for a decision doc is forward-looking from the landed state—whether a future cold reader would re-litigate the choice and whether other design nodes are sized around it—rather than how long or hard the deliberation was:

1. **Bounded strictly to one node**: Per the HLD tenet (*Keep cache paths and replacement bookkeeping private to the preview worker*) and the fixed `200`/`202`/`404` HTTP contract, `review-api` and all other components are completely insulated from the eviction algorithm, queue structure, and size split. No other node leans on this choice.
2. **One line of domain rationale settles it**: For a cold reader looking at `previews-design.md`, the table row already explains why plain LRU (vulnerable to sequential screening scans) and aged frequency counts (counter maintenance and stale favorites across project switches) were rejected in favor of 2Q.

If you still want a full decision doc at `docs/intent/previews/decisions/cache-eviction-policy.md`, I can draft one right away (per *the user is always right*). Otherwise, we can keep the table row and proceed with triaging the five Phase 2 edge-case questions above. Which would you prefer?