I've written 2Q into the previews design and stopped there for your review, because an independent read of the draft turned up one question I can't settle for you. Nothing is committed, and the specs are untouched until you approve the design.

## What changed

- **`docs/high-level-design.md`**: one line. "Its eviction policy remains open" now says the cache evicts with 2Q.
- **`docs/intent/previews/previews-design.md`**: the open-candidates paragraph is replaced by an Eviction Policy section, a Decisions & Alternatives table and one deferred question (tuning the split from pilot traffic).

The review API design needed no change.

## The design as drafted

- **Two queues**: a first-use queue (FIFO by admission) and a reused queue (LRU). New renders enter first-use, and the first cache hit moves a sheet to reused.
- **Split**: first-use targets 25% of the 12 GiB (3 GiB, about 1,500 sheets), set at worker startup. The 25% is my starting number, not something we had agreed.
- **Eviction**: if first-use is over its share, evict its oldest sheet; otherwise evict the least recently used reused sheet. If the chosen queue is empty, evict from the other.
- **Restart**: queue state lives in memory, and surviving files all restart as first-use.
- **Recorded alternatives**: LRU and aged frequency, as rows in the previews design's decisions table.

## The question I need you to answer

**What counts as "reuse"?** A miss returns 202, and the browser retries the same URL two seconds later. As drafted, that retry is a cache hit, so every screening sheet would be promoted the moment it is delivered and 2Q would protect nothing. The options:

- **A. Grace window (my recommendation)**: hits within about 30 seconds of admission count as delivery, not reuse. This keeps two queues and the fixed HTTP contract, and a comparison sheet is protected from its second real viewing.
- **B. Full 2Q**: remember recently evicted first-use keys and promote only a sheet that is requested again after eviction. There is no timing rule, but it adds a third structure, and every comparison sheet pays one extra 450 ms render before it is protected.
- **C. Retry carries the ticket**: the worker ignores ticket redemptions. This is the most exact, but it changes the internal contract the review API depends on, which the design calls fixed.

## Other gaps, with what I'd do

Tell me which of these to change; "all as recommended" is fine.

1. **Over-claimed protection.** The reused queue is only protected up to its 9 GiB; if it has grown past that, a screening does trim it. The new HLD line also says screenings "cannot displace" comparison sheets, which reads like a retention promise the non-goals rule out. I'd reword both as a tendency bounded by the share.
2. **Renderer upgrade.** Old-version sheets sitting in the reused queue are unreachable but would rarely be evicted, which leaves an effective 3 GiB cache during the next screening. I'd purge other-version sheets at worker startup.
3. **Restart order.** "Oldest file first" puts long-lived comparison sheets first in line for eviction after a restart. I'd accept that for the pilot and say so plainly in the rationale; the alternative is persisting the list of reused keys.
4. **Share bounds.** At 0% or 100% the policy degenerates. I'd have the worker refuse to start outside 5–50%, and never admit a sheet that would not fit even with both queues empty.
5. **Concurrency.** Up to four renders can finish together. I'd state that admissions run one at a time, and that evicting a sheet mid-response lets that response finish.
6. **Tuning data.** The deferred tuning needs per-queue hit rates. I'd say the worker reports these in its own logs, so no other node reads the counters.

Once you answer the reuse question and triage the six, I'll revise the design and move on to the specs. `PREVIEW-004` will need rewording, and the queue rules need new spec lines.