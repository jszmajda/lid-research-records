Phase 2 draft is done. Here's where it stands, then the edge-case probe for your triage.

## What I changed in `previews-design.md`

- Replaced the "eviction policy is still open" paragraph with a **Replacement Policy** section specifying 2Q with three worker-private structures — **Recent** (FIFO, first-render sheets), **Reused** (LRU, sheets requested again after aging out), and **Ghost** (keys only, no bytes). A sheet earns the long-lived Reused queue only by surviving eviction and being asked for again, so a sequential screening scan can't push the comparison set out.
- Added a **Decisions & Alternatives** row recording 2Q over LRU and aged-frequency, with the scan-resistance rationale. Per the skill's bar this is a row, not a decision doc: all three options kept every change inside the preview worker, so the choice affects only this node and nothing downstream is sized around it — even after the long thread.
- Set defaults `Kin` = 3 GiB (¼ of budget) and `Kout` ≈ 6,000 keys, flagged as worker-internal constants.

I did **not** touch EARS yet — the new mechanism needs specs (Phase 3), which is the next stop.

## Edge-case probe (LLD-level gaps, for you to triage)

A blind read of the drafted design surfaced these. I've split them by whether the 2Q choice created them or they pre-date it. Tell me which to resolve in the LLD now and which to defer — I'm not choosing readings for you.

**A. Created by the 2Q design — I'd recommend settling these before specs:**

1. **When is the admit destination decided — request time or completion time?** A key can be in Ghost when the request arrives but its ghost entry could be dropped (past `Kout`) during the render. Does the completed sheet still land in Reused, or fall back to Recent?
2. **Dedup vs. the four-case table.** A key with an in-flight render is neither resident nor (necessarily) in Ghost. Does the dedup map short-circuit the classification entirely, and what's its precedence relative to the Ghost/Recent/Reused checks? Related: two sharers of one ticket may have classified the same key differently (one saw Ghost, one didn't) — which classification wins, and who removes the Ghost key?
3. **Is `Kin` a hard ceiling or a soft target?** On an all-one-use workload where nothing is ever reused, does Recent stay capped near 3 GiB (leaving ~9 GiB idle), or may it overshoot into Reused's share while Reused is empty? The two readings give very different cache utilization.
4. **Victim queue empty.** If the rule says evict Reused but Reused is empty (or vice-versa), is there a fallback to the other queue, or can admission block/fail?
5. **A sheet larger than `Kin`'s share** (or pathologically large). Is the share evaluated including or excluding the incoming sheet, and what happens when no eviction can satisfy both the 12 GiB bound and the share rule at once?
6. **Reused eviction leaves no Ghost key** (classic 2Q): an LRU-evicted comparison sheet re-enters via Recent, not Reused, losing its reuse history. Intended for the working set this policy is meant to protect?
7. **Reclamation atomicity** across up to four near-simultaneous completions — do reclaim-then-admit sequences serialize, or can they transiently over/undershoot 12 GiB and read `Kin` against an inconsistent snapshot?

**B. Pre-existing in the component — the probe flagged them but the 2Q choice didn't create them. Fold into this pass, or leave for their own change?**

8. The HTTP contract (200/202/404) has **no failure outcome**: a deterministically failing render is removed from the dedup map and re-renders on the next poll, so a client could get 202 forever at the 2-second interval. No cap/backoff/terminal error is stated.
9. **When 404 vs. 202 is determined** — is revision resolution synchronous on the GET (404 on first request) or inside the queued job (first response is 202, 404 only on a later poll)?
10. **No backpressure on the render queue** beyond "four active jobs" — no cap on queued jobs or saturation behavior.

**STOP for your review.** Reply with which A-items to resolve (and how you'd like them to read), and whether to pull any B-items into this LLD pass or leave them. Once the LLD is settled I'll cascade to the EARS specs (Phase 3), which is the next stop.