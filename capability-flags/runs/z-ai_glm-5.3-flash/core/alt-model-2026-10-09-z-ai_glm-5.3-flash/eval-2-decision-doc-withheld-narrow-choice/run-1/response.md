Done — I've recorded 2Q and finished the previews LLD. Here's the Phase 2 output for your review.

## What changed

**`docs/high-level-design.md`** (two coherence fixes, no architecture change):
- "Its eviction policy remains open" → "with a 2Q replacement policy"
- Goal dropped the "for every eviction policy" clause, which only made sense while the policy was open

**`docs/intent/previews/previews-design.md`** — the Private Cache section now specifies 2Q:

- **Queues**: A1in (fresh sheets, one reference max, 3 GiB ≈ 1,536 sheets), Am (sheets referenced ≥2 times, LRU, 9 GiB ≈ 4,608 sheets), A1out (keys only, no data, 3,000 keys). The two data bounds sum to the 12 GiB budget, so the global limit holds by construction; each queue evicts within its own bound.
- **Admission**: render completing for a key in A1out → straight into Am (it was evicted once and asked for again — demonstrated reuse). Any other completed render → A1in.
- **Promotion**: any hit on a cached sheet moves it to Am's MRU end. A single reference never enters Am, so a screening scan can't displace the comparison set.
- **Eviction**: A1in overflow frees the oldest sheet's data and moves its key to A1out (dropping A1out's oldest key when full); Am overflow drops the LRU sheet and its key. Pending jobs and failed renders never touch the cache.
- **Decisions recorded** (rows, not a decision doc — the choice stays entirely inside the preview worker): 2Q over LRU and aged-frequency; a deliberate deviation from classic 2Q (hits in A1in promote — with ghost-only promotion, a comparison sheet's early references would all land in A1in and leave it unprotected during exactly the screenings you bought 2Q to survive); the 3/9 GiB split as initial values.
- **Open question**: tune the split and A1out bound against pilot hit rates.

## Edge-case probe (blind reviewer, LLD only)

Three gaps are **newly load-bearing under 2Q**:

1. **Restart semantics** — are the queue structures persisted or rebuilt on boot? (Unstated either way; now concretely 2Q-shaped.)
2. **Admission race** — can one job's admission/eviction race another's and mis-count against the bounds?
3. **Oversize sheet** — what if no eviction set can satisfy a queue's bound (e.g., a sheet larger than A1in's 3 GiB)?

Four are **pre-existing** unhappy-path gaps this change didn't create: ticket outcome after job failure/worker crash (retry forever vs. error), 404 timing and whether unknown revisions are negatively cached, dedup teardown when ticket-holders still hold a failed job's ticket, and renderer-version change between enqueue and completion.

## Before I go to Phase 3

1. Does the LLD read right to you — especially the second-reference promotion deviation? (Say the word and I'll revert to classic ghost-only promotion.)
2. Which probe gaps should I fold into the LLD now, and which defer as open questions? My suggestion: settle 1–3 in the LLD now (they're cheap and the specs will need them anyway); defer the four pre-existing ones or handle them as their own change.
3. On your OK, Phase 3 revises PREVIEW-004 to the per-queue eviction form and adds specs for admission/promotion/queue bounds.