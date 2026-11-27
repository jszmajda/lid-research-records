## Phase 2: LLD Update — 2Q Eviction Strategy

I've updated the previews design to finalize the 2Q cache eviction choice. Here's what changed:

**Updated Section: "Private Cache and Eviction"**

The design now specifies:
- **Queue A (new entries)**: FIFO eviction, capped at 3 GiB (25% of capacity)
- **Queue B (reused entries)**: LRU eviction, expands to fill remaining 9 GiB
- **Promotion rule**: Second access moves an entry from A to B with timestamp update; subsequent B accesses are LRU-only
- **Rationale**: Protects comparison sheets during sequential screenings while keeping bookkeeping cost bounded

**Context-free reading check**: The design now reads complete for a cold reader — the 2Q mechanism is named, both queue behaviors are explicit, the size split is concrete (3 GiB / 9 GiB), and the rationale explains why this choice was made over the alternatives.

**LLD-level edge-case probe** — gaps in the design:

1. **Timeout or cache clearing behavior**: The design doesn't specify what happens when an operator explicitly clears the cache or when the system restarts. Do entries persist across restarts, or is the cache ephemeral?
2. **Eviction tie-breaking in Queue B**: If multiple entries in B have identical LRU timestamps (clock granularity, batched operations), which one is evicted?
3. **Promotion state machine**: If an entry is being evicted from A while a second request for it arrives concurrently, does the second request see it as moved to B, promoted but pending eviction, or is the state undefined?
4. **Queue A threshold tuning**: The 25% split (3 GiB / 9 GiB) is specified, but there's no note on whether this is tunable per workload or if it's a fixed constant.

---

**Please review Phase 2 and confirm whether to:**
1. Record the 25% A/9 GiB B split as a fixed constant, or allow operator tuning per deployment
2. Address the three edge cases above in the LLD (explicitly state decisions) or defer them to Phase 3 EARS specs
3. Proceed to Phase 3 (EARS specs) to detail the 2Q behavior with more granularity