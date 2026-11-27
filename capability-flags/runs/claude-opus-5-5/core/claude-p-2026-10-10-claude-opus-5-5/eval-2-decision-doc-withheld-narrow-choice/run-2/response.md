2Q is written into the preview design; nothing is committed, and I've stopped before touching the specs so you can rule on the draft.

## What changed

- **`docs/high-level-design.md`**: one line. "Its eviction policy remains open" now reads "a private 12 GiB cache with 2Q eviction." Nothing else in the HLD or the review API needed to move.
- **`docs/intent/previews/previews-design.md`**: the open-candidates paragraph is replaced by the section below, and the Context paragraph now states the goal (keep comparison sheets warm through a screening). LRU and aged frequency are recorded as rejected alternatives in a new Decisions table, with the reasons from your sketch.

### Eviction Policy: 2Q (as drafted)

> Every cached sheet belongs to exactly one of two queues, and the 12 GiB bound applies to their combined size.
>
> - **Probationary queue** — sheets that have been rendered but not yet reused, ordered by admission time. Serving a sheet from this queue does not change its position.
> - **Protected queue** — sheets that have been reused, ordered by most recent request.
>
> A completed sheet is always admitted to the probationary queue. A request served from the probationary queue promotes the sheet to the most-recent end of the protected queue, provided the request arrives after the sheet's first-view window has passed. A request served from the protected queue moves the sheet to the most-recent end. Promotion moves a sheet between queues without changing the cache's total size, so it never causes an eviction.
>
> **First-view window.** A miss returns 202, and the browsers that were waiting collect the finished sheet on their next retry. Those collections are the sheet's first viewing, not reuse, and the worker cannot tell them apart from later requests by caller because the review API forwards requests without editor identity. Requests within 60 seconds of a sheet's admission therefore do not promote it. The window also absorbs an editor stepping back one clip during a screening.
>
> **Choosing what to evict.** When admitting a sheet would take the cache past 12 GiB, the worker evicts one sheet at a time until the new sheet fits:
>
> 1. While the probationary queue holds more than its share of the budget, evict its oldest sheet.
> 2. Otherwise evict the least recently requested sheet in the protected queue.
> 3. If the queue selected by these rules is empty, evict from the other.
>
> A screening therefore recycles the probationary queue and leaves the protected queue untouched; protected sheets are evicted only when reused sheets alone outgrow the space the probationary share leaves them.
>
> **Probationary share.** The share is 25% of the budget (3 GiB, about 1,500 typical sheets), leaving about 4,500 sheets' worth for the protected queue. A sheet earns protection if it is requested again before roughly 1,500 newer sheets are admitted behind it. At 6,000 distinct clips a week that is more than a working day of team-wide viewing, comfortably longer than the gap between an editor's first look at a clip and their return to compare it. The share and the first-view window are worker configuration read at startup; neither is reachable through the preview interface.
>
> **Restart.** Queue membership and ordering are held in worker memory. On startup the worker places every sheet found on disk in the probationary queue, ordered by file modification time, with its first-view window already passed. Reused sheets regain protection on their next request.

## Calls I made that are yours to overrule

Choosing 2Q left four things unsettled. I picked a default for each and recorded it in the Decisions table.

1. **When a sheet becomes protected.** I chose promotion on a second request while the sheet is still cached. Textbook 2Q instead promotes only after a sheet has been evicted once and requested again. That resists scans slightly better, but every comparison sheet pays a second render and a 2-second wait before it is protected, and it adds a third structure to size.
2. **The 60-second first-view window.** Without something like it, the browser's own retry after a 202 counts as reuse and every sheet is promoted on first viewing, which defeats the policy. 60 seconds is my starting number.
3. **The 25% probationary share**, measured in bytes. This is the size split you expected to tune; it is listed as a deferred question to revisit against pilot hit rates.
4. **Queue state is not persisted across restarts.** Everything on disk restarts as probationary.

## Gaps from a cold-read probe

A subagent read only the design file and looked for holes; it looked hardest at the eviction loop under four concurrent renders and at the restart paragraph. I have not applied any of these. Tell me which to fix in the design and which to defer.

| # | Gap | My recommendation |
|---|-----|-------------------|
| 1 | After a restart, the comparison sheets have the oldest file times, so the eviction rule removes them first. | Fix: this undercuts the point of the policy. Either persist which sheets were protected, or update file time on each request. |
| 2 | "Holds more than its share" doesn't say whether the incoming sheet counts. If it doesn't, a full cache can evict a protected sheet for a one-use sheet. | Fix: count the incoming sheet. |
| 3 | Up to four renders can finish at once, and the design doesn't say that check-evict-admit is one atomic step. The cache could overshoot 12 GiB. | Fix: admissions are serialized. |
| 4 | Between "render complete" and "sheet admitted", a request might find neither a ticket nor a cached sheet and start a duplicate render. | Fix: the ticket is released only after admission. |
| 5 | A sheet evicted before the waiting browser collects it: is that a plain miss, or is the sheet held until collected? | Fix as a plain miss (new 202, new render); no pinning. |
| 6 | The victim is being streamed, or is requested mid-eviction. | Fix: an in-flight response completes; a request after the victim is chosen is a miss. |
| 7 | Startup finds the disk over budget, truncated files, orphaned temp output, or sheets from an old renderer version. | Fix: delete temp output and unreadable or old-version sheets, then evict down to budget. |
| 8 | Both queues are empty and the sheet still doesn't fit; no valid range for the share. | Fix: serve the sheet uncached; share must be strictly between 0% and 100%. |
| 9 | Which instant counts as "admission" for the 60-second window, and which clock. | Fix: queue insertion, monotonic clock. |
| 10 | How the 12 GiB is counted, and what happens if deleting a victim fails. | Defer as an open question. |

## Not done yet

`previews-specs.md` is unchanged. Today only PREVIEW-004 mentions eviction, and it says nothing about which sheet goes. Once you approve the design (as is, or with numbered changes), I'll draft the new PREVIEW specs for the queue behaviour and stop again for your review.