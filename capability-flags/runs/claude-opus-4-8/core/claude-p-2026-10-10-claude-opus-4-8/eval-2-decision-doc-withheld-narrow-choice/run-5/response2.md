Done — the decision doc is written and linked.

## `docs/intent/previews/decisions/cache-replacement-policy.md`

- **Context** states the budget, the two access shapes, and the one domain fact that bends the choice (a miss re-renders in ~450 ms, so eviction costs recomputation, not a storage stall). The fixed contract/dedup/queue/budget are named as background, not differentiators.
- **Decision Elements** — no gates (nothing eliminates an option in contention), four weighted criteria: scan resistance (major), project-switch adaptation (moderate), bookkeeping cost (moderate), tuning burden (minor).
- **Options in the Domain** — LRU, frequency-with-aging, and simplified 2Q each get a prose entry with a per-criterion verdict; 2Q carries a concrete demonstration (the 2,000-sheet screening churning through A1 while a 30-sheet comparison set sits protected in Am).
- **Selection** — 2Q wins on the one major criterion by construction; LRU is strong everywhere *except* the criterion that matters most; frequency-with-aging is dominated. Costs and foreclosures laid out.

It reads cold: present tense, no trace of the thread — someone opening it in a year gets the judgment, not the history.

## Two things still open from the last stop

1. **`A1_TARGET_FRACTION`** — still needs your ruling. I've drafted **25% (3 GiB)** into the LLD's Open Questions as tunable. Keep it, or pick another split? (This is the screening-protection vs. project-switch-adaptation knob — your call to weigh.)

2. **HLD cascade (crosses into the root).** Two edits I'd make there, both needing your go-ahead:
   - Replace the stale *"Its eviction policy remains open"* line — keeping the HLD policy-agnostic, just noting the previews node owns the now-settled policy without naming 2Q upstream.
   - The decision doc surfaced a **candidate missing tenet** — something like *"a long single-touch screening must not evict a reused working set."* The whole decision turns on that, yet no HLD tenet carries it today. Want to add it under `## Tenets`? (It passes the defensible-opposite test — a different project could reasonably optimize for raw hit-rate instead.)

Once you've set the split and answered the HLD questions, I'll cascade to the EARS specs (Phase 3): revise PREVIEW-004 and add lines for A1 admission, promotion-on-second-touch, and the A1-before-Am eviction order.