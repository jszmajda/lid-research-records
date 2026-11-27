2Q is recorded as the eviction policy in the previews design. I'm stopping here for your review before writing any specs. Three details inside 2Q were not settled by your choice, so I picked a value for each and need you to confirm or change them.

## What changed

- **`docs/high-level-design.md`**: one line. "Its eviction policy remains open" now reads "a private 12 GiB cache evicted with 2Q."
- **`docs/intent/previews/previews-design.md`**: the open-candidates paragraph is replaced by an Eviction section, a Decisions & Alternatives table, and two deferred questions.
- **Unchanged**: the review API docs, the preview endpoint, the render queue and the 12 GiB budget.

LRU and aged-frequency are recorded as a row in the Decisions table with the rationale. I did not write a standalone decision doc, because the choice only affects the preview worker.

## The new Eviction section

> The cache evicts with 2Q. Every cached sheet sits in exactly one of two queues:
>
> - **First-use queue** — FIFO in admission order. Every newly rendered sheet enters here.
> - **Reused queue** — ordered by most recent use. A sheet moves here the first time it is reused, and every later hit moves it to the most-recent end.
>
> Both queues hold only sheets that are on disk; the worker keeps no record of evicted keys.
>
> A sheet in the first-use queue is *reused* when it is served with a 200 at least 10 seconds after it was admitted. Earlier hits are the render being delivered to the requests that were waiting on its job ticket, which arrive within one or two retry intervals; they leave the sheet where it is. Without this window every sheet would count as reused on delivery, and a screening would fill the reused queue.
>
> The first-use queue's share of the budget is 25% (3 GiB, about 1,500 typical sheets). The share is worker configuration. The reused queue has no cap of its own and may grow into whatever the first-use queue is not using.
>
> To make room for a sheet being admitted, repeat until it fits:
>
> 1. If the first-use queue, counting the incoming sheet, holds more than its share, evict its oldest sheet.
> 2. Otherwise evict the least recently used sheet in the reused queue.
> 3. If the reused queue is empty, evict the oldest sheet in the first-use queue.
>
> During a long screening the first-use queue stays at its share, so each new sheet displaces an older one-use sheet and the reused queue is untouched. When little new footage is arriving, room comes from the cold end of the reused queue, which is how a finished production's comparison set ages out.

## Choices I made that are yours to confirm

1. **No memory of evicted sheets.** A sheet earns protection by being viewed again while it is still cached. Textbook 2Q instead remembers evicted keys and protects a sheet only when it is requested again after eviction. That would cost each comparison sheet one extra 450 ms re-render and add a second size to tune. This matches the "two queues and a size split" you described.
2. **Reuse means a 200 served at least 10 seconds after the render finished.** Every browser waiting on a pending ticket fetches the sheet within a retry or two of completion. If those fetches counted, every screening sheet would be promoted and the scan protection would be lost. Ten seconds is five retry intervals.
3. **First-use share is 25% (3 GiB), configurable.** That leaves 9 GiB a screening cannot touch. It is a starting value to revisit against pilot hit rates.

## Gaps from an independent read of the draft

I had a separate reader probe the draft for holes. None of these are applied yet; my suggested handling is in the last column.

| # | Gap | Suggested handling |
|---|---|---|
| 4 | Share is given in both bytes and sheet count. | Fix now: bytes. |
| 5 | A sheet larger than the first-use share, or a share of 0, leaves rule 1 with nothing to evict. | Fix now: fall through to rule 2. |
| 6 | The "reused queue is untouched" sentence is false if a screening starts while the reused queue holds more than 9 GiB; it shrinks until first-use reaches its share. | Fix now: correct the sentence. The behaviour is intended. |
| 7 | With free space, such as a cold start, the first-use queue can grow past 25%. | Fix now: say the share only governs which sheet is evicted, not a standing cap. |
| 8 | A first 200 that arrives after 10 seconds (slow or resumed poll) promotes a one-use sheet. | Accept and note it; it is rare and costs one misplaced sheet. |
| 9 | Several renders finishing together could count the same freed space. | Fix now: admissions make room one at a time. |
| 10 | Eviction of a sheet that is mid-response is not ordered against the response. | Fix now: an in-flight response completes. |
| 11 | Reused sheets for a superseded renderer version can never be hit, and leave only through the cold end of the reused queue. | Defer; purging on a renderer upgrade is a separate decision. |
| 12 | Queue membership after a worker restart is undefined. | Already listed as deferred in the doc. Say if you want it settled now, since a restart mid-screening could drop protection. |

Reply with numbers to change (for example "2: use 30 seconds, 12: settle now"), or approve as-is. On approval I'll apply the fix-now items and draft the EARS specs for eviction.