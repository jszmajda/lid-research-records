**Phase 2 (LLD) complete — stopping for your review.**

**Updates made:**
- `docs/intent/previews/previews-design.md` — the open-policy paragraph is now a concrete 2Q design: A1 (new, FIFO, 25% of budget initially) and A2 (reuse, LRU); promotion on an A1 hit; on admission pressure, evict A1's tail if A1 is over its share, else A2's LRU end. Reference definition excludes pending-shared requests. The three meetings' tradeoffs are recorded as a Decisions & Alternatives row (2Q vs LRU vs aged-frequency, plus the no-ghost-list variant and the A1 share) — I judged a full decision doc unnecessary since a row plus the deferred-tuning list settles it for a cold reader; say the word if you want the full doc.
- `docs/high-level-design.md` — "Its eviction policy remains open" updated to "with 2Q eviction." No cross-segment cascade: the review API is already explicitly blind to replacement policy.

**Edge-case probe (delegated to a blind reader) — top gaps for your triage, fix-in-LLD vs defer:**

1. **Promotion overflow**: promotion into A2 has no stated eviction trigger (the rule is written only for admissions).
2. **Post-completion burst hits**: do requests in a deduplicated miss burst count as A1 hits once they re-poll after completion? If yes, one burst promotes a sheet straight to A2.
3. **Failed-job ticket holders**: what does a poller observe after the shared job fails?
4. **Eviction fallback**: what if the rule names an empty A2, or "over its share" boundary (strictly greater?).
5. **Oversized admission**: a completed sheet too big for the budget even after full eviction.
6. **Queue-position ticket semantics**: does a fifth miss queued behind four renders still get a 202?
7. **In-flight hit vs eviction race**.

Gaps 3, 6 predate 2Q (they touch the pending/render-queue sections); 1, 2, 4 are 2Q-specific. Which should I settle in the LLD now, and which go to Open Questions? After your triage, I'll proceed to Phase 3 (EARS update — the existing PREVIEW-001..005 don't yet express the 2Q behavior).