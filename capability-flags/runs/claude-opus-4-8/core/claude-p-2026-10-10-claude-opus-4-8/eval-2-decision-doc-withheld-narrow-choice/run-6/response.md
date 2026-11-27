Phase 2 is drafted. Here's what changed and what needs your call before I cascade onward.

## Decision recorded
I set the previews LLD's replacement policy to **2Q** and wrote a **Decisions & Alternatives** row capturing 2Q over LRU and aged-frequency, with the "accept extra bookkeeping to protect comparison sheets during big screenings" rationale. I did **not** open a standalone decision doc: by your own framing the choice affects only the preview cache (no other node is sized around it), so the rule here is to record the row, not a doc. Say the word if you'd rather have the full doc anyway.

I also removed the now-stale "eviction policy remains open" note from the HLD (one line) — it's resolved, so leaving it would be residue.

## What the 2Q section now says
- **Recent queue** (FIFO) for first-use sheets, **Reused queue** (LRU) for sheets requested again, **Ghost list** of evicted recent-queue keys (no bytes, outside the 12 GiB budget).
- First miss → recent queue; a ghost-list hit → reused queue; eviction prefers recent-queue victims while recent > `Kin`, else reused-queue LRU; the 12 GiB bound is hard and overrides `Kin`.

## Edge-case probe — please triage
A delegated probe raised gaps in the 2Q mechanism. Three of these are genuinely your call (I've parked them in **Open Questions → Deferred**, not silently decided):

1. **Promotion-on-hit** — classic 2Q only promotes a sheet to the reused queue *after* it's evicted and re-requested (via the ghost list); a sheet re-requested *while still in the recent queue* stays FIFO. Your workload (comparison sessions revisiting the same small set) may argue for promoting on the second hit directly. Which do you want?
2. **`Kin`/`Kout` defaults and tuning** — I've seeded `Kin` ≈ 25% of 12 GiB and `Kout` ≈ the recent-queue's entry count, tuning deferred to pilot. OK as a starting point?
3. **Restart behavior** — replacement metadata is in-memory, so a worker restart empties both queues and the ghost list. Acceptable for the pilot, or do you want persistence?

The rest are drafting-precision gaps. My proposed readings (standard 2Q) — tell me to fold any of these into the LLD now, or defer:
- **Evict-until-fit vs drain-to-`Kin`**: evict only until the new sheet fits, picking each victim from the recent queue while it exceeds `Kin`, otherwise from the reused queue (not "always drain recent to `Kin`"). *This tightens prose that currently reads two ways — I'd fix it.*
- **Admission ordering**: reserve the new sheet's size, evict until free, then admit; a sheet larger than `Kin` enters and sits over its target legally, the hard 12 GiB bound still governs.
- **Reused-queue evictions**: do **not** ghost LRU victims (classic 2Q); only recent-queue evictions become ghosts.
- **Ghost consumed on promotion**: a key is removed from the ghost list when it promotes.
- **Renderer-version change**: a new version is just a new key; the old entry ages out normally, no active invalidation.
- **Shared job ticket**: concurrent misses resolve to one admission counted as a single first-use.

Once you've triaged these, the next stop is **Phase 3 (EARS)** — PREVIEW-004 needs rewording and I expect 2–3 new spec lines for queue-class eviction ordering and reuse promotion. That's within the previews segment, so cascade is free, but I'll stop for your review at each phase rather than running straight through. How do you want to handle items 1–3 and the precision fixes?