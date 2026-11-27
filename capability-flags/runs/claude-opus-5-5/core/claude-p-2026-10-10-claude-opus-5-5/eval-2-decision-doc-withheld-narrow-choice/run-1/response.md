2Q is written into the preview design, but it isn't finished yet: two choices inside 2Q are yours to make, and I've left them as open questions in the doc rather than pick for you. Nothing is committed, and I haven't touched the specs, tests or code.

## What changed

**`docs/high-level-design.md`**: one sentence. The Previews entry now reads "a private 12 GiB cache with 2Q eviction" instead of "Its eviction policy remains open." Nothing else in the HLD needed to move.

**`docs/intent/previews/previews-design.md`**: the open-policy paragraph is replaced by this section.

> ## Eviction
>
> The cache evicts with 2Q. Every cached sheet belongs to exactly one of two queues:
>
> - **First-use queue**: FIFO. A completed sheet enters here on admission.
> - **Reused queue**: LRU. A sheet moves here from the first-use queue once it is reused, and each later request moves it to the most-recent end.
>
> A size split divides the 12 GiB budget into a first-use share and a reused share, both measured in cached JPEG bytes. The split is a worker configuration value, read at startup, so it can be tuned per production without a code change.
>
> When room is needed, the worker evicts the oldest sheet in the first-use queue while that queue holds more than its share, and otherwise the least recently requested sheet in the reused queue. If the queue selected by that rule is empty, it evicts from the other. A screening therefore churns through the first-use share and cannot displace reused sheets beyond it, while the reused queue can still use space the first-use queue leaves idle.
>
> Queue membership, ordering, and the split are replacement bookkeeping: none of it appears in the preview endpoint's responses, the job ticket, or the render queue.

The same file also gets:

- **A Decisions & Alternatives row** recording 2Q over LRU and aged frequency, with the reasons: screening scans evict comparison sheets under LRU, aged frequency lags a project switch, and the accepted price is two queues plus a split to tune.
- **A reworded Context sentence** saying the cache favors keeping the comparison set warm over minimal bookkeeping.

I recorded the choice as a table row, not a standalone decision doc, because it affects only the preview worker. The review API design is untouched.

## Two decisions I need from you

1. **What counts as "reused"?** Every cold sheet is requested at least twice: the 202, then the browser's retry two seconds later. If that retry counts as reuse, every screened sheet is promoted and 2Q behaves like LRU.
   - **(a) Promote on a later request while still in the first-use queue, ignoring the retries that collect a just-rendered sheet.** This protects a comparison sheet from its second real viewing, but we have to define "collecting retry" (for example, requests within a few seconds of admission).
   - **(b) Classic full 2Q.** Hits in the first-use queue never promote; a sheet is promoted only when it is requested again after being evicted, tracked by a list of recently evicted keys. There is no retry rule to define and scan resistance is strongest, but each comparison sheet costs one extra ~450 ms re-render and there is a third structure to size.
   - I recommend (a): it matches the "two queues and a size split" you signed up for and protects comparison sheets soonest.

2. **Starting value for the split.** I suggest 25% first-use and 75% reused, which is 3 GiB (about 1,500 sheets) and 9 GiB (about 4,500 sheets). Tune from there.

## Gaps for you to triage

An independent edge-case read of the design turned up these. For each, say whether to fix it in the design now or defer it; my suggested default is in parentheses.

1. **Eviction before pickup**: a just-admitted sheet is evicted before the waiting browser's retry arrives. (Fix now: the retry gets a fresh 202 and a re-render, since a miss is ordinary behavior.)
2. **Concurrent completions**: several of the four render jobs finish at once and each evicts only enough for itself, so together they could exceed 12 GiB. (Fix now: evict-then-admit is serialized.)
3. **Eviction during a response**: a sheet is chosen for eviction while it is being served. (Fix now: the in-flight response completes.)
4. **Worker restart**: the design doesn't say whether queue membership survives. (Fix now: surviving files count toward the budget and re-enter as first-use; nothing is persisted.)
5. **Renderer upgrade**: old-version sheets can never be hit again but may sit in the protected reused queue. (Fix now: purge them at startup.)
6. **Sheet that can't be admitted**: it is larger than the space eviction can free, or a file delete fails. (Defer: unlikely at 2 MiB against 12 GiB.)

Reply with your picks for the two decisions and the triage — "your recommendations and defaults" is enough — and I'll fold them into the design and move on to the EARS specs for your review.