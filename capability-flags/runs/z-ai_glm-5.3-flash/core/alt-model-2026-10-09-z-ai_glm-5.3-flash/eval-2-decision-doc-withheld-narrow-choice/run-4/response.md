The 2Q decision is now landed through the previews segment. Here's what changed, and where I need your ruling.

## What landed

**HLD** (`docs/high-level-design.md`): the Previews node no longer says "eviction policy remains open" — it names the 2Q policy.

**LLD** (`docs/intent/previews/previews-design.md`): the open-candidates paragraph is replaced by an "Eviction Policy: 2Q" section — A1 (FIFO first-use, ≤3 GiB) and Am (LRU reused, ≤9 GiB), promotion on second access, eviction-before-admission, no ghost queue, renderer-version-obsolete sheets evicted by the ordinary rules. Plus a Decisions & Alternatives row recording 2Q over LRU and aged frequency, and the 3/9 split parked as a tunable under Open Questions.

**Specs** (`previews-specs.md`): PREVIEW-004 (total-budget eviction) unchanged; added PREVIEW-006 through 012 covering A1 admission, promotion/refresh, Am-tail eviction on admission and promotion, eviction never touching jobs/source, and the split bounds.

**Consistency notes** — already fixed in the draft, for your awareness: I standardized on evict-before-admission to match PREVIEW-004 (the earlier draft admitted-then-evicted), and split the Am-eviction rule into admission-side (009) and promotion-side (012) specs, since one compound spec read two ways.

## Needs your ruling before tests are written

1. **Scan-bleed boundary.** With A1 filled exactly to its split, every further admission evicts from Am — so under a continuous one-use screening, Am *does* bleed one entry per admission (standard 2Q behavior; it doesn't fully wall off the comparison set). Acceptable as-is, or do you want Am evicted only when A1 cannot supply a victim — a variant that needs its own rule?
2. **Ticket requests don't count as reuse.** I narrowed promotion to only requests answered with the JPEG (200); a 202 while the sheet is mid-render doesn't promote. Confirm, or should ticket issuance count?
3. **Failed renders.** Eviction done to make room is not rolled back if the render later fails — the cache ends up under-filled rather than over-budget. Confirm.

## Two asks

- **Decision doc?** The 2Q choice cleared the bar for one offer: credible alternatives, multiple criteria, and the split parameter sizing work around it. Say the word and I'll write `docs/intent/previews/decisions/eviction-policy-2q.md` linked from the Decisions row; otherwise the row stands alone.
- **Phase review.** Please review the LLD section and specs 006–012 above. Once you rule on the three forks, next stops are Phase 4 (cross-spec audit against review-api) and then tests-first implementation.