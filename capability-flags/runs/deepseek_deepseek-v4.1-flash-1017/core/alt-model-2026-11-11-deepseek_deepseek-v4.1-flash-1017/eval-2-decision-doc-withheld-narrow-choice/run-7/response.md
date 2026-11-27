I've settled the preview LLD on 2Q and updated `docs/intent/previews/previews-design.md` plus the HLD architecture line. The review API and render queue are unchanged; all new state is private to the preview worker.

**Private Cache — 2Q Eviction**
The cache maintains two live queues:
- **First-use queue** — sheets admitted after their first render; new entries enter at the tail.
- **Reused queue** — sheets that have proven reuse. A hit on a first-use sheet promotes it to the reused tail; a hit on a reused sheet moves it to the tail.

The first-use queue is capped at a configurable fraction of the 12 GiB budget; the reused queue uses the remainder. There are no ghost queues. On admission, exceeding the first-use cap evicts the first-use head; exceeding 12 GiB evicts first-use entries first, and the reused queue only when first-use is empty. A reused sheet therefore outlives first-use sheets while the first-use queue still has entries; if the reused queue alone fills the budget, a new first-use admission evicts from reused.

**Decisions recorded:** 2Q over LRU (sequential screenings evict comparison sheets) and aged frequency (counter maintenance, lag after project switches); two live queues over full ghost-queue 2Q; recency ordering within the reused queue.

**Deferred:** the first-use budget share (3 GiB / 25% proposed) and any future ghost history.

**LLD edge-case probe — gaps to triage:**
1. When a previously evicted sheet is re-rendered, does it re-enter first-use or return to reused?
2. Is single-queue membership guaranteed during promotion, and does promotion immediately free first-use capacity?
3. Does a request served from the shared dedup ticket count as a hit for promotion, or only a 200 served from cached bytes?
4. When both the first-use cap and total budget are exceeded, what is the operation order and how are freed bytes accounted?
5. What happens when one sheet is larger than the first-use cap, or larger than 12 GiB?
6. Is the reused remainder a hard cap, or can it borrow unused first-use space?
7. If both queues are empty and the sheet still cannot fit, is admission rejected, admitted over budget, or something else?
8. Are admission and eviction serialized across four simultaneous render completions, and can two individually fitting admissions jointly breach the budget?
9. What ordering applies between a hit/promotion and an eviction of the same sheet, and what prevents a 200 response from reading bytes that are unlinked mid-response?
10. What bounds and runtime-change behavior apply to the configurable fraction?
11. On restart, is private cache metadata cleared or rebuilt, and which queue do surviving files enter?
12. When the renderer version changes, are unreachable old-version entries purged or left to age out?
13. What happens to pending 202 tickets across a restart?
14. When is a completed sheet atomically published into a queue, and what if the temp-to-cache publish fails partway?
15. If an eviction delete fails, is the entry retained, retried, or dropped from the queue while its bytes still occupy storage?

Which of these should I fold into the LLD now, and which should go to Open Questions & Future Decisions? Also, should the first-use share start at 3 GiB (25%), or remain purely a tuning parameter for implementation? Once you rule, I'll finalize the LLD and move to the EARS update for the 2Q behavior.