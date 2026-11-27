The previews design is finished — 2Q is now specified. Here's the updated design for your review.

## What changed

**`docs/intent/previews/previews-design.md`** — the open-policy paragraph is replaced with a concrete 2Q mechanism:

- Two worker-private queues: **A1in** (FIFO, first-use; every newly completed sheet enters at its tail) and **Am** (LRU, reused sheets). A hit on an A1in sheet promotes it to Am's front; a hit in Am refreshes Am's front.
- Eviction serves admission only: over-budget admissions take from A1in's head first, then Am's LRU end once A1in is empty. A sheet evicted from A1in without a second request never reaches Am — so a long sequential screening cycles inside A1in while your comparison sheets stay resident in Am.
- **A1in bound: 3 GiB (25% of the 12 GiB budget)** as a starting value, byte-based, tunable. Evicted-then-re-requested sheets re-render and re-enter as fresh first-use.
- A Decisions & Alternatives row records 2Q over LRU and frequency-with-aging (the aging option was rejected for counter maintenance and stale retention after project switches). Since this choice stays inside the previews node, I recorded it as a table row rather than a decision doc.
- Deferred: tuning the 3 GiB split from the pilot's observed screening mix.

**`docs/high-level-design.md`** — "eviction policy remains open" replaced with the settled 2Q description.

## Edge-case probe — please triage

A fresh reviewer probed the drafted design; these are the gaps it found, grouped. Tell me which to fix in the LLD now and which to defer as open questions (or say "your judgment" and I'll triage):

1. **Budget accounting** — Are in-flight render bytes counted toward 12 GiB before admission? What if one sheet alone exceeds the 3 GiB A1in bound or the space a single Am LRU eviction frees? Does promotion-to-Am that would exceed budget trigger Am eviction, and does the 12 GiB / 3 GiB rule precedence get stated?
2. **Races and duplicates** — A completed render for a key already cached (re-admit vs double-count); a lookup racing that entry's eviction; a 202 ticket whose job's key is evicted mid-flight; old tickets held by concurrent requesters after a failed render releases the dedup entry.
3. **Lifecycle** — Worker restart (queue metadata vs cached bytes on disk — can the 12 GiB bound silently break?); renderer-version siblings of one revision (independent entries?); ordering of evict-then-write when the write fails mid-way.

## Next step

Once you triage (or approve as-is), I'll cascade to the EARS specs (`previews-specs.md`) — new PREVIEW-00x lines for the 2Q behavior and the bound — with a consistency report, and stop for your review there before any tests.

Which probe gaps go into the LLD now, and which defer?