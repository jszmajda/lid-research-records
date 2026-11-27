2Q is written into the previews design; nothing is committed, and I've stopped before specs because the design needs your sign-off first.

## What changed

**`docs/high-level-design.md`** — one line. The Previews entry no longer says the eviction policy is open; it now reads "a private 12 GiB cache whose eviction protects reused comparison sheets from one-off screening scans." Review API is untouched.

**`docs/intent/previews/previews-design.md`** — the "still open" paragraph is replaced by a new `## Eviction` section, a Decisions & Alternatives table, and one deferred question (tuning). The design now says:

- **Two queues.** Every admitted sheet enters a FIFO first-use queue. A sheet that is reused moves to a reused queue ordered by most recent hit. Each sheet is in exactly one queue.
- **Accounting.** The 12 GiB bound covers both queues together, measured in bytes rather than entry counts.
- **Victim selection.** When admission needs space, evict one sheet at a time until the new one fits:
  1. If the first-use queue (counting the incoming sheet) exceeds its share, or the reused queue is empty, evict the oldest first-use sheet.
  2. Otherwise evict the least recently hit reused sheet.
- **Effect during a screening.** The first-use queue sits above its share, so the screening's own one-use sheets are the victims and the comparison sheets stay.
- **Decisions table.** 2Q over LRU and aged frequency is recorded as a row with the rationale you gave; bytes over counts is a second row.

## Two choices I made that are yours to rule on

1. **What counts as "reused."** The retry that collects a freshly rendered sheet after a 202 is itself a cache hit. If any hit promoted a sheet, every screened sheet would promote itself and 2Q would protect nothing.
   - **Drafted:** a hit promotes a first-use sheet only after a promotion grace period since admission, initially 10 s. Hits inside it serve the JPEG and change nothing.
   - **Alternative:** full 2Q's ghost queue, which remembers evicted first-use keys and promotes a sheet when it is requested again. I rejected it as a third structure we don't need, since a sheet survives about 1,500 later admissions in the first-use queue.
   - **Cost of the draft:** a quick flip back to the previous clip within 10 s doesn't count as reuse.
2. **The size split.** The first-use share is 3 GiB (25%, about 1,500 typical sheets), leaving up to 9 GiB for reused sheets during a screening. This is the conventional 2Q starting point, not a measured number. Both it and the grace period are worker config read at startup.

## Gaps from the edge-case probe

A blind reader of the design raised these. For each, tell me "fix in the design" or "defer"; my suggestion is in the last column.

| # | Gap | Suggestion |
|---|---|---|
| 1 | Worker restart: are on-disk sheets re-adopted, into which queue and in what order, or discarded? | Fix: re-adopt everything into the first-use queue by file time; no persisted queue state |
| 2 | Rule 1 fires but the first-use queue is empty (incoming sheet larger than the share), or a sheet exceeds the whole bound | Fix: fall through to the reused queue; a sheet over the bound is not cached |
| 3 | Up to four renders can finish at once; evict-then-admit isn't stated as serialized, so two admissions could jointly exceed 12 GiB | Fix: serialize admission |
| 4 | A hit races eviction of the same sheet (mid-stream read, or promotion while it is being selected as victim) | Fix: an in-flight response completes; queue changes are serialized with admission |
| 5 | Admission fails after victims are already evicted | Fix: treat as a failed job; lost space is accepted |
| 6 | Order of dedup-entry removal versus admission, and double admission of one key | Fix: admit before releasing the dedup entry |
| 7 | Renderer version change strands old-version sheets, and stale reused ones leave slowly | Defer |
| 8 | Config edge cases: share of 0, share at or above the bound, share lowered below current occupancy | Fix: validate at startup; occupancy corrects on the next admission |
| 9 | Grace period precision: starts at cache insertion or render completion, which clock, and a slow waiter collecting after 10 s | Fix: starts at insertion, monotonic clock; slow-waiter promotion accepted |
| 10 | Queue entry exists but the JPEG is missing or unreadable | Fix: treat as a miss, drop the entry, re-render into first-use |

Gaps 3–6 and 10 predate 2Q, but the eviction specs will lean on them.

## What I need from you

- Approve or change the promotion rule (choice 1) and the 3 GiB / 10 s starting values (choice 2).
- Triage the ten gaps; "take all your suggestions" is a fine answer.

Once you approve, I'll fold the fixes into the design and draft the EARS specs for eviction (new `PREVIEW-006` onward; `PREVIEW-004` stays as the bound) for your next review.