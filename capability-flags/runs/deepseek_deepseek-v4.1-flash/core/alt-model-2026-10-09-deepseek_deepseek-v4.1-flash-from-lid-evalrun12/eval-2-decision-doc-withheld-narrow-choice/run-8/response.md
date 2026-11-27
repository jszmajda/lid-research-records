Phase 2 (LLD) is drafted around your 2Q choice. Everything stays inside the preview worker, so the review API is untouched. The choice affects only the previews node, so I recorded it as a Decisions & Alternatives row rather than offering a full decision doc.

**Files changed**
- `docs/intent/previews/previews-design.md` — rewrote *Private Cache* to specify 2Q, added a *Decisions & Alternatives* row (2Q vs LRU vs aged frequency), added *Open Questions & Future Decisions*.
- `docs/high-level-design.md` — removed the now-stale "Its eviction policy remains open" note (coherence fix).

**New LLD section — Private Cache → Eviction Policy: 2Q**

> The cache uses the 2Q policy, which separates sheets used once from sheets used more than once so a one-off screening scan does not displace the comparison working set.
>
> Two queues hold cached entries:
> - **First-use queue** — sheets admitted but not yet requested a second time, ordered oldest-first.
> - **Reused queue** — sheets requested again since admission, ordered least-recently-used first.
>
> A completed sheet enters the first-use queue. A cache hit on a sheet in the first-use queue promotes it to the reused queue. Eviction removes the oldest entry from the first-use queue; only when that queue is empty does eviction remove the least-recently-used entry from the reused queue. A long sequential screening therefore churns through the first-use queue while sheets an editor has already revisited survive in the reused queue.
>
> The reused queue holds the larger share of the 12 GiB budget; the split between the two queues is a tunable parameter (see Open Questions). Queue membership and all replacement bookkeeping stay private to the preview worker; no other node reads or configures it.

**Decision recorded (row):** chosen 2Q — first-use + reused queues, evict first-use before reused; alternatives LRU (cheap, but scans evict the comparison set) and aged frequency (protects popular clips, but counter maintenance and lags a project switch). All three leave the interface, queue concurrency, and disk budget unchanged.

**Two forks I need your ruling on**
1. **Ghost queue.** Canonical 2Q keeps a ghost queue (A1out) of recently evicted first-use keys so a re-request after eviction is recognized as reuse. Your "two queues" description omits it. Include it, or keep the two-queue form above?
2. **Queue split.** Deferred as tunable — do you want a starting ratio named (e.g. reused ≈ 75% / first-use ≈ 25%), or leave it entirely to pilot tuning?

**Phase 2 edge-case probe** (delegated to a blind reader; findings summarized, not applied — a clean pass means no counterexample found, not proof):

1. Does the render-triggering miss itself count as the first use, or does the next request already promote?
2. A hit on an entry already in the reused queue — does it refresh recency?
3. Insertion position within each queue (admission and promotion) is unspecified; only the eviction ends are.
4. Is the 12 GiB a single global cap with the split as a soft target, or two hard per-queue caps?
5. "Only when first-use is empty" can conflict with the 12 GiB bound — which rule wins?
6. What if one completed sheet can't be accommodated by evicting every eligible entry?
7. Can an entry be evicted while mid-response to a request?
8. Interleaving/atomicity between a promotion and an eviction in the same admission cycle.
9. Dedup-map entry on render *success* is unstated; and what a ticket holder gets if the sheet is evicted before retry.

Which of these should I fix in the LLD now versus defer as open questions — and do you approve the LLD so I can move to Phase 3 (EARS)?