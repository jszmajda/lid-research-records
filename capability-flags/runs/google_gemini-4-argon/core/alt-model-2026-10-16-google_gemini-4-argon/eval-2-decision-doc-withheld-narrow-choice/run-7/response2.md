I don't recommend a standalone decision doc here; the row in `previews-design.md`'s `Decisions & Alternatives` table is the right fit.

In LID, the test for a decision doc is forward-looking from the landed state—not how long the deliberation took to reach it:

1. **Strictly local scope**: The replacement policy stays entirely inside the preview worker's private cache. No sibling node (`review-api`), external API contract, queue concurrency, or disk budget is sized around or coupled to it.
2. **One-line rationale settles the "why" for a cold reader**: Given the workload stated right in the LLD (long sequential screenings mixed with repeated comparisons of a small working set), why 2Q was chosen over plain LRU (scan vulnerability) and aged frequency counters (decay bookkeeping and slow adaptation on project switches) fits cleanly in the table row without leaving a live cross-cutting tradeoff that future readers would need to re-run from scratch.

Under the user-is-always-right tenet, if you still want `docs/intent/previews/decisions/cache-eviction-policy.md` written out anyway, say the word and I will draft it. Otherwise, we can keep it as the table row in `previews-design.md`—and whenever you're ready, let me know your thoughts on the 5 LLD edge-case questions above so we can wrap up Phase 2 and move to Phase 3 (EARS specs).