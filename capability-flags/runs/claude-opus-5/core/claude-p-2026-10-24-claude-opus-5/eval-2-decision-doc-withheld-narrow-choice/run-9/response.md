I landed 2Q in the previews LLD and ran the Phase 2 edge probe (delegated to a blind reader given only the two previews docs). Stopping here for your review before any EARS work.

## What changed in `docs/intent/previews/previews-design.md`

- **New `## Cache Replacement` section** — the three queues (FIFO first-use queue holding bytes, LRU reuse queue holding bytes, FIFO ghost queue holding keys only), what happens on a request in each, and the admission/eviction order. The 12 GiB budget covers both resident queues together; the first-use queue carries an additional byte share of that budget; ghosts cost no JPEG bytes.
- **Context** rewritten to say *why* replacement has to survive a screening pass, rather than that the mix varies and no policy wins.
- **New `## Decisions & Alternatives` table** with four rows: the policy choice (2Q over LRU and aged frequency, extra bookkeeping accepted); promotion requiring a ghost hit rather than a second access; byte accounting rather than entry counts; ghost keys scoped per renderer version.
- **New `## Open Questions & Future Decisions`** — 2Q resolved, three items deferred.
- The external contract, render-queue concurrency, and disk budget sections are untouched.

One note on how I recorded it: I put the policy choice in the Decisions table rather than a standalone decision doc. The LID bar for a decision doc is whether other design nodes get sized around the result — and your HLD is explicit that nothing outside the worker reads cache files, pins entries, or consumes eviction metadata, so this one is contained to its own node no matter how long the argument ran. Say the word if you'd rather have the full doc anyway.

## Two things I need from you

**1. The HLD still says the policy is open.** `docs/high-level-design.md:14` reads "Its eviction policy remains open." That's now stale, but it's the root node, so I didn't touch it. Proposed replacement for that clause: "Owns rendering, pending jobs, and a private 12 GiB cache with 2Q replacement." Want me to make that edit?

**2. Probe gaps — which to settle in the LLD now, which to defer?** The sharpest ones the 2Q machinery introduced:

1. Admission order: the new section says admit then evict; PREVIEW-004 says evict *before* admission so the cache is never momentarily over budget. These read differently — which is intended?
2. No eligible victim: total is over 12 GiB, but the first-use queue is at or under its share and the reuse queue is empty. The eviction rule as written has nothing to take.
3. Mixed-provenance dedup: one ordinary miss and one ghost hit for the same key share a job ticket — which queue does the single sheet land in?
4. Ghost-entry drop timing: is the ghost removed when the hit is recognized, or only on successful admission? If the re-render then fails, the reuse evidence is gone for good.
5. Share boundary: is the first-use share a strict or inclusive cap — does hitting it exactly trigger eviction?
6. Eviction during an in-flight read: nothing says whether a resident entry is pinned while its bytes are being served.

Three more it surfaced are pre-existing, not from this change — your call whether to fold them in while we're here: what HTTP outcome a request gets when its shared render job *fails* (the contract fixes only 200/202/404); what a client polling a ticket from a failed job receives; and whether revision resolution precedes the cache lookup, when a cached sheet exists for a revision that no longer resolves.

Reply with numbers to fix now vs. defer, or just "defaults" and I'll bring you a recommendation per item at this same stop.