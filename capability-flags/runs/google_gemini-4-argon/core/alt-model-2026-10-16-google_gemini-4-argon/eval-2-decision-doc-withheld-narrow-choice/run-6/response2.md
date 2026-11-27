I recommend keeping this as a row in `previews-design.md`'s **Decisions & Alternatives** table rather than writing a standalone decision doc.

In LID, the test for a decision doc looks forward from the landed design rather than back at how hard the debate was: *would a cold reader of the landed system re-litigate the choice without a full multi-option analysis, and do other design nodes depend on or size themselves around the result?* Here:

- **Bounded to one leaf**: As both `high-level-design.md` and `review-api-design.md` establish, replacement tracking is strictly private to the preview worker—the HTTP contract (`200`/`202`/`404`), 12 GiB disk budget, render queue concurrency, and sibling `review-api` node are identical under LRU, aged frequency, and 2Q.
- **One line of rationale settles "why this?"**: A future reader looking at the 2Q queues in `previews` only needs to know why plain LRU or frequency counters weren't used (protecting repeated comparison sets against sequential screening scans without cross-project frequency lag). The table row in `previews-design.md` captures that trade directly where a maintainer of the cache will read it.
- **Debate history isn't what the doc records**: The 3 meetings and 180-message thread are deliberation history; once stripped to context-free present intent, the tradeoffs among LRU, aged frequency, and 2Q fit cleanly in the LLD's table without a separate file to maintain.

That said, if you anticipate future pressure to revisit the eviction algorithm and want the full criteria-and-options breakdown (`docs/intent/previews/decisions/cache-eviction-policy.md`) so a future maintainer can re-run the judgment, I can write one—just say the word.

How would you like to proceed on that, and how would you like to handle the Phase 2 LLD questions (1–5) above?