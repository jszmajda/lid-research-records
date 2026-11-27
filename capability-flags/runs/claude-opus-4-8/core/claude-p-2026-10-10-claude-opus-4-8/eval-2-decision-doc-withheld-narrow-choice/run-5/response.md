Phase 2 (LLD) — drafted for your review. **Stopping here before EARS.**

## What changed in `previews-design.md`

- **Context** rewritten to state the policy requirement in present intent (protect twice-touched entries from single-touch scan traffic) instead of "no policy is best / still open."
- **New "Cache Replacement (2Q)" section** making the policy concrete, since Phase 3 specs will be sized around it:
  - Two segments share the one 12 GiB budget — **A1** (recent first-use, FIFO) and **Am** (reused, LRU).
  - **Admission:** a completed sheet enters A1 as most-recent.
  - **Hit:** an entry in A1 is promoted to Am (the second touch is what marks it reused); an entry already in Am is moved to Am's most-recent.
  - **Eviction:** while over budget, evict A1's oldest if A1 exceeds its target share, else Am's LRU — so a long screening churns within A1 and leaves the comparison set in Am resident.
  - Interface, render queue/concurrency, cache key, dedup, and 12 GiB budget all explicitly unchanged; all segments stay private to the worker.
- **Decisions & Alternatives** table records 2Q over LRU and frequency-with-aging, plus one sub-choice I made for you — **simplified 2Q (no A1out ghost queue)**, on the grounds that a miss just re-renders in ~450 ms so a non-resident ghost queue buys little. Flagging that I settled it so you can veto; it's the one place I chose rather than asked.

## One decision I need from you (unsettled choice)

**`A1_TARGET_FRACTION` — the A1/Am size split.** This is the knob that trades off exactly what you care about: a *smaller* A1 protects the reused set harder but gives first-use sheets less room to earn a second touch before eviction; a *larger* A1 adapts faster when an editor switches projects but lets a screening reach deeper toward Am. I've drafted a **25% (3 GiB) default** into Open Questions as tunable. Keep 25%, or pick another split? (Only you can weigh the screening-protection vs. project-switch-adaptation balance here.)

## Two things to confirm

1. **Record as a full decision doc, or the table row alone?** The row is already in the LLD. This choice stays live for a cold reader — three credible options against several criteria (bookkeeping cost, scan resistance, project-switch lag, tuning) — so it clears the bar for a standalone decision doc at `docs/intent/previews/decisions/` if you want one that re-runs the judgment. My lean: the row is enough. Your call.
2. **HLD cascade (crosses into the root, so I'm pausing).** `high-level-design.md` still says *"Its eviction policy remains open."* That's now stale. The HLD deliberately stays policy-agnostic (per its private-bookkeeping tenet), so I'd change that clause to note the previews node owns the now-chosen policy **without** naming 2Q at the root — rather than describing the algorithm upstream. Want me to make that edit?

Once you've set the split and answered these, I'll cascade to the EARS specs (Phase 3) — PREVIEW-004 will need revising and new lines added for A1 admission, promotion-on-reuse, and the A1-vs-Am eviction order.