I recommend keeping this as the **Decisions & Alternatives** table row in `previews-design.md` rather than creating a standalone decision doc.

In LID, the test for a decision doc is forward-looking from the landed state—not how hard or long the deliberation was:

1. **Bounded to a single node:** The HTTP contract (`200` / `202` / `404`), the 12 GiB disk cap, the four-slot render queue, and the `review-api` sibling are completely unaffected by the replacement policy. No other design node is sized around or constrained by this choice.
2. **A single row settles the "why":** A cold reader looking at the preview cache only needs to know why it uses 2Q instead of plain LRU (sequential screening scans evict active comparison sets) or aged frequency counts (counter/aging overhead and slow adaptation when switching projects). The table row captures that rationale completely without a multi-page breakdown.
3. **Avoids deliberation residue:** Writing a standalone doc because the team had three meetings and a 180-message thread would memorialize the history of the debate rather than the architectural need of the landed system.

That said, if you suspect future maintainers will still try to simplify 2Q back to LRU or re-litigate aged LFU unless the full evaluation against workload criteria is laid out, we can write `docs/intent/previews/decisions/eviction-policy.md` and link it from the table row.

Would you like to stick with the table row (and let me know how you'd like to handle the 5 edge-case questions above), or would you still prefer to create the standalone decision doc?