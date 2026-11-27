I have updated the High-Level Design and the Previews LLD to adopt the 2Q replacement policy:

1. **HLD (`docs/high-level-design.md`)**: Closed the open eviction policy under Previews in favor of 2Q.
2. **LLD (`docs/intent/previews/previews-design.md`)**: Replaced the open candidate discussion with 2Q mechanics ($A1$ FIFO in-queue, $Am$ LRU main queue, and $A1_{out}$ ghost queue) and recorded the rationale and alternatives considered in the `Decisions & Alternatives` table.

---

### Phase 2 LLD-Level Edge-Case Probe

Before moving to Phase 3 (EARS specs), please review these LLD-level edge cases:

1. **$A1_{in}$ vs. $Am$ Size Partitioning**: What default size split between the FIFO admission buffer ($A1_{in}$) and the main LRU queue ($Am$) should be established (e.g., 25% $A1_{in}$ / 75% $Am$, or 50% / 50%)?
2. **Ghost Queue ($A1_{out}$) Bound**: How large should the key-only ghost buffer be bounded relative to total cached items (e.g., tracking up to 50% of maximum cache entry capacity), and what eviction discipline applies to the ghost buffer itself (FIFO)?
3. **Queue Promotion Trigger**: Should hit promotion from $A1_{in}$ to $Am$ happen immediately on a cache hit within $A1_{in}$, or only when re-referenced via $A1_{out}$ after eviction from $A1_{in}$ (Simplified 2Q / 2Q vs. Full 2Q)?
4. **Decision Doc Bar**: Does the 2Q eviction choice warrant a dedicated standalone decision doc (`docs/intent/previews/decisions/cache-eviction-policy.md`), or is the row in the `Decisions & Alternatives` table sufficient?

How would you like to resolve these points before we proceed to EARS specification updates?