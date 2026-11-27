2Q is now written into the previews design, recorded as a row in its Decisions & Alternatives table with LRU and aged-frequency as the rejected alternatives. Nothing is committed, and the EARS specs are untouched until you approve this.

## What changed

- **`docs/high-level-design.md`**: removed the stale sentence "Its eviction policy remains open." Nothing else in the HLD needed to change, since the policy stays private to the worker.
- **`docs/intent/previews/previews-design.md`**:
  - Replaced the open-candidates paragraph with the `### Eviction: 2Q` subsection below.
  - Added the Decisions & Alternatives table.
  - Added one deferred open question, on tuning the share.
  - Reworded the last sentence of Context to say the cache is designed so a screening's one-use sheets cannot push comparison sheets out.

### Eviction: 2Q (as drafted)

> Cached sheets are held in two queues, and every cached sheet is in exactly one of them:
>
> - **First-use queue** — sheets that have been served at most once since they were rendered. Ordered by admission time; being served does not reorder it.
> - **Reused queue** — sheets that have been served more than once. Ordered by most recent serve.
>
> A completed render is admitted to the tail of the first-use queue. Rendering is not a use: because a miss answers 202, the first 200 that hands the sheet to a requester is its first use and leaves it where it is. Any later 200 for that sheet is a reuse and moves it to the most-recent end of the reused queue; further serves from the reused queue refresh its position there. A sheet never moves back from the reused queue to the first-use queue.
>
> The first-use queue has a share of the 12 GiB budget, measured in bytes of JPEG data. When room is needed for an admission, victims are chosen one at a time until the new sheet fits, re-applying these rules for each victim:
>
> 1. If the first-use queue, counting the sheet being admitted, would hold more than its share, evict its oldest sheet.
> 2. Otherwise evict the least recently served sheet in the reused queue.
> 3. If the reused queue is empty, evict the oldest sheet in the first-use queue.
>
> The share steers victim selection only. It does not reserve space: while the cache is under 12 GiB nothing is evicted, whichever queue is larger.
>
> The first-use share is 25% of the budget (3 GiB, about 1,500 typical 2 MiB sheets), leaving about 9 GiB (about 4,600 sheets) of reused sheets that a screening cannot displace: admissions take space from the reused queue only while the first-use queue is below its share. It is a worker configuration value, read at startup and not exposed through the preview interface.
>
> The consequence that matters for editors: once the first-use queue has filled its share, a screening of any length churns only that queue, so the most recently served 9 GiB of reused sheets are displaced only by other reused sheets. The cost is that reused sheets from a finished project leave only as newly reused sheets push them out, so a project switch warms up more slowly than under plain recency ordering.

### Decisions & Alternatives rows

| Decision | Chosen | Alternatives | Rationale (short) |
|---|---|---|---|
| Eviction policy | 2Q | LRU; frequency with aging | Protects comparison sheets from screening scans; the extra queue and tunable share are the accepted price. |
| Promotion trigger | Second serve while still cached | Full 2Q, which promotes only on a re-request after eviction, tracked by a list of evicted keys | Protects a sheet as soon as it is revisited, with no second 450 ms render and no third structure. |
| First-use share | 25%, configurable | Even split; smaller share | A starting value, to be tuned against pilot traffic. |

## Two choices I made that are yours to confirm

1. **Promotion trigger.** I used the two-queue variant you described, where a second serve promotes. Full 2Q is stricter about what counts as reuse but costs comparison sheets an extra render.
2. **The 25% share.** This is the classic 2Q starting point, not something derived from your traffic.

## Gaps from a cold-read probe

A subagent read only the two design docs and raised these. For each, tell me whether to fix it in the design now, defer it to Open Questions, or drop it.

1. **What counts as a serve.** Two editors polling the same job ticket, or one browser reloading, produce a first and second 200 and promote a sheet nobody compared. Enough of that and screening sheets leak into the reused queue. Options include counting per editor or requiring a minimum gap between serves; this one bears directly on your reason for choosing 2Q.
2. **Worker restart.** Nothing says whether queue membership and order survive a restart, are rebuilt from the files, or the cache starts cold.
3. **Renderer version change.** Old-version sheets become unreachable but sit in the reused queue until pushed out; there is no purge.
4. **Share edge values.** There is no valid range. At 0% a just-rendered sheet can be evicted before its requester's two-second retry; at 100% the policy inverts.
5. **Concurrency.** Up to four renders can finish at once, and the design does not say whether evict-and-admit is atomic or whether a sheet being served can be chosen as a victim.
6. **Failure between eviction and admission.** It is unstated whether the victims are already gone and whether the job counts as failed.
7. **Oversized sheet.** No outcome is given for a sheet larger than the first-use share.
8. **Failed renders (not caused by 2Q).** A ticket-holder polling after a failure just gets another 202; there is no failure signal or retry cap for a revision that always fails to render.

My recommendation is to fix 1, 2 and 4 in the design now, defer 3, 5, 6 and 7 to Open Questions, and treat 8 as a separate change.

Please give me a ruling on the two choices and the eight gaps, or approve as is. Once the design is approved I'll move to the EARS specs: PREVIEW-004 needs to name the victim order, and promotion and the share need new lines.