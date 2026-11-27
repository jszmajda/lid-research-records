I've recorded the 2Q choice and finished the preview LLD for this phase. Here is the Phase 2 output.

**LLD updated — `docs/intent/previews/previews-design.md`** (the `## Private Cache` section, replacing the "policy is still open" prose):

> ### 2Q Eviction
>
> A long screening admits a stream of sheets that each get touched once; a comparison session revisits a small working set. In a single recency list the screening stream would push the comparison set out. The worker uses a 2Q policy to hold first-use sheets in their own queue so they evict one another, and reserves the reuse queue for sheets a session has returned to.
>
> Entries are keyed by clip ID, revision, and renderer version, and live in one of three structures:
>
> - **First queue** — a FIFO queue of entries touched once since admission. Holds the screening working set.
> - **Reuse queue** — an LRU queue of entries touched at least twice. Holds the comparison working set.
> - **Ghost list** — the keys, with no JPEG data, of entries recently evicted from the first queue, so a sheet that returns after being evicted is recognized.
>
> On admission, a completed sheet enters the head of the first queue. A cache hit in the first queue promotes the entry to the reuse queue; a cache hit in the reuse queue moves the entry to its most-recent end. If a request's key is found in the ghost list, its completed sheet is admitted directly to the reuse queue and the key leaves the ghost list.
>
> The first queue is capped at a fixed fraction of the 12 GiB budget (default 25%). On each admission the worker evicts until the incoming sheet fits:
>
> 1. While the first queue exceeds its cap, evict its oldest entry and record its key in the ghost list.
> 2. While the cache exceeds 12 GiB, evict the least-recently-used entry from the reuse queue.
> 3. If the reuse queue is empty and the cache still exceeds 12 GiB, evict the oldest entry from the first queue and record its key in the ghost list.
>
> The ghost list holds at most as many keys as the first queue can hold entries at its cap; the oldest key is discarded when it overflows. The split fraction is the only tunable parameter; queue capacities follow observed sheet sizes within the byte budget rather than a fixed entry count.

**Decision recorded** in the LLD's new `Decisions & Alternatives` table — *Cache eviction policy* → 2Q, over LRU and aged frequency, because 2Q confines the one-use screening stream to the first queue while reacting to a project switch immediately. Recorded as a table row, not a decision doc: the choice affects only this node, so a cold reader gets the tradeoff from the row alone.

**Coherence fix**: the HLD (`docs/high-level-design.md:14`) no longer says the eviction policy "remains open"; it now states the previews node owns a 12 GiB cache with a 2Q policy. The review-api node is untouched — 2Q keeps all bookkeeping private, so no cascade crosses into it.

**LLD-level edge-case probe** (run by a fresh, blind reader against this doc only). The gaps it found, most load-bearing first — please tell me which to fix in the LLD vs. defer as open questions:

1. A request that hits the **ghost list**: what does the client actually receive (a 202 ticket, since no JPEG exists), and when is the ghost check done relative to cache lookup and dedup?
2. A sheet **larger than the first-queue cap** (or larger than 12 GiB entirely): steps 1–3 would loop evicting the incoming sheet or could never satisfy the bound; no oversized-entry rule.
3. A **first-queue hit promoting to the reuse queue** that pushes total bytes over 12 GiB: eviction is specified only "on admission," so a promotion that grows the reuse queue has no corrective action.
4. **Ghost-hit admission** into the reuse queue: do the eviction steps (written for an incoming first-queue sheet) still run, and against which queue?
5. A **reuse-queue entry evicted by step 2**: its key is not ghosted, so a returning comparison sheet looks cold and re-enters the first queue.
6. **Ordering of insert vs. evict** on admission, and whether the incoming sheet counts toward "the first queue exceeds its cap" in step 1.
7. **Render completion vs. cache admission**: a request arriving between the two can miss, join a finished ticket, or re-render.
8. **A just-admitted or ticket-referenced sheet evicted before the client's 202 retry** fetches it — no pinning invariant.
9. **Render failure and the two-second retry contract**: the 202 holder's outcome isn't stated; PREVIEW-005 only covers a *later* request.
10. **Ghost-list capacity** is expressed in entries while the first-queue cap is a byte fraction over varying sheet sizes — the overflow target is dynamic with no defined evaluation instant.
11. **Renderer-version change**: whether prior-version entries are invalidated or left to pressure-based eviction.
12. **A revision deleted between the 404 check and render resolution** — which point is authoritative.
13. **Ghost-list semantics itself**: whether the ghost list is required for 2Q's stated benefit, or whether promotion-on-second-resident-hit alone suffices (it's the least-essential piece of the design).

Two things I need from you:
- **Approve the LLD update** (and the default 25% first-queue split, or name a different fraction).
- **Triage the probe**: which of the 13 gaps are LLD fixes now, and which are deferred open questions.

Stopping here for your review before I draft the EARS updates.