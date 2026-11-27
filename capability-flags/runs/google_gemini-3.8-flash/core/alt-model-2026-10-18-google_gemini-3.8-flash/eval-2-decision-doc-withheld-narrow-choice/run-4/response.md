I have updated the design documents to incorporate the 2Q cache eviction policy:

1. **`docs/high-level-design.md`**: Updated the Previews architecture bullet to reflect the selected 2Q eviction policy for the 12 GiB private cache.
2. **`docs/intent/previews/previews-design.md`**: Specified the 2Q structure (`A1in`, `A1out`, and `Am` queues), admission/hit dynamics, eviction mechanisms, and added the `Decisions & Alternatives` table capturing the rationale and considered alternatives (LRU, frequency-based eviction with aging).

---

### Phase 2: LLD Edge-Case Probe

Before moving to Phase 3 (EARS specs update), here is the edge-case probe covering structural gaps in the updated LLD:

1. **Ghost Queue (`A1out`) Sizing & Eviction**: How should capacity/retention for `A1out` descriptors be bounded (e.g., maximum entry count or byte-size tracking equivalent to 50% of cache entries), and what happens when `A1out` itself fills up?
2. **`A1in` Hit Promotion Semantics**: In standard 2Q (Full 2Q vs. Simplified 2Q), does a hit on an entry residing in `A1in` promote immediately to `Am`, or does it remain in `A1in` until evicted to `A1out` and re-referenced?
3. **Queue Split Allocation**: What default sizing split should be established between `A1in` and `Am` (e.g., 25% `A1in` / 75% `Am`, or configurable via worker environment settings)?
4. **Variable File Size Accounting**: Contact sheets average ~2 MiB but can vary; should queue boundaries and eviction thresholds be evaluated strictly by cumulative byte size against the 12 GiB limit, or by entry count?
5. **Decision Doc Bar**: This choice was selected from 3 competing options. Does this decision warrant a full standalone decision doc (`docs/intent/previews/decisions/cache-eviction-policy.md`), or is the `Decisions & Alternatives` table row sufficient?

Please let me know how you would like to address these points before we proceed to Phase 3.