I've locked in the 2Q decision at the LLD level. Here's what changed and what needs your review before I move to specs.

**`docs/high-level-design.md`** — removed the now-stale "Its eviction policy remains open" from the Previews architecture bullet.

**`docs/intent/previews/previews-design.md`** — replaced the three-way sketch with the landed design:

> Eviction uses 2Q. A newly admitted sheet enters `A1in`, a FIFO queue for first-use entries. A sheet accessed again while still resident promotes to `Am`, a recency-ordered queue for reused entries; a hit within `Am` moves the entry to its most-recent position. Both queues are bounded by a fraction of the 12 GiB budget. When admitting a completed sheet would exceed the budget, eviction takes from `A1in` first and only draws from `Am` once `A1in` is empty, so a long sequential screening displaces its own one-off sheets before it can displace another editor's comparison set. This is the two-queue form of 2Q — there is no separate ghost queue tracking recently evicted first-use keys. The change is confined to this replacement policy: the external interface, queue concurrency, and disk budget are unchanged.

Added a Decisions & Alternatives row recording LRU and frequency-aging as the rejected alternatives and why, and a Deferred open question for the `A1in`/`Am` size split (you'd flagged that as unresolved — "a size split we'll have to tune").

**Decision doc or stay a table row?** Three meetings and real tradeoffs went into this, and the size-split is still open and will get sized around whatever this decision implies — that's the kind of thing this workflow offers a full decision doc for (context, gated/weighted criteria, per-option analysis) instead of just the one-line row I added. I only offer this once: do you want the full doc, or is the table row enough to close this out?

**Gaps a blind read of the new design surfaced** (your call on which to settle now vs. defer):
1. Does A1in→Am promotion apply to in-flight renders, or only to fully admitted resident sheets?
2. No ghost queue means a sheet evicted from A1in and immediately re-requested re-enters A1in as if never seen — intended?
3. Can Am grow to crowd out A1in entirely before the 12 GiB cap is hit, or is each queue's fraction a hard sub-limit?
4. Within Am, is eviction order fully determined by "recency-ordered," including ties from near-simultaneous promotions?
5. Is Am promotion idempotent under concurrent hits on the same entry?
6. Does a failed render's dedup-map cleanup ever touch an unrelated cached entry's queue position (e.g., same clip, different revision)?
7. Is evict-then-admit atomic, or can a concurrent request see the cache under budget but still missing the entry?
8. Does a 202-retry poll on a pending key count as an Am hit/promotion, or only the eventual 200?
9. Until the size split is decided, is there a default fraction in effect, or is eviction behavior unspecified in the interim?

Once you weigh in on the decision-doc question and tell me which of these to fix in the LLD now versus leave as open questions, I'll finalize this phase and move to the EARS spec update.