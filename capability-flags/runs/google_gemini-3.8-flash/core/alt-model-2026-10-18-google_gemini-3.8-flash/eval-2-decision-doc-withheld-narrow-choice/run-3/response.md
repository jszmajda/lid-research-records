I have updated the design documents to incorporate the 2Q cache eviction decision.

### Summary of Changes

1. **High-Level Design (`docs/high-level-design.md`)**:
   - Updated the architecture entry for Previews to specify that the 12 GiB private cache uses 2Q eviction, resolving the previously open eviction policy.

2. **Previews LLD (`docs/intent/previews/previews-design.md`)**:
   - Replaced open eviction policy text under `## Private Cache` with the concrete 2Q design: probationary FIFO queue ($A1$) for initial admissions and an LRU queue ($Am$) for items receiving repeat access.
   - Added a `## Decisions & Alternatives` table documenting the choice of 2Q over LRU and frequency-based eviction with aging, capturing the rationale context-free.
   - Added `## Open Questions & Future Decisions` noting queue sizing/split parameter tuning ($A1$ vs. $Am$) as deferred to implementation.

---

### LLD Edge-Case Probe (Phase 2)

Before proceeding to Phase 3 (EARS specs update), please review the following component-level edge-case questions for the 2Q eviction design:

1. **2Q Variant & Ghost References ($A1_{in}$ vs. $A1_{out}$)**: Should we implement simplified 2Q (simple FIFO $A1$ resident queue promoting directly to $Am$ on a hit while resident) or standard full 2Q (which maintains an out-of-cache ghost reference queue $A1_{out}$ of keys to detect re-references after eviction from $A1_{in}$)?
2. **Eviction Target Selection**: When space must be reclaimed to admit a new sheet, should eviction preferentially drain the tail of $A1$ whenever $A1$ exceeds its target share (e.g. 25%), or strictly evict from $A1$ on $A1$ admissions and $Am$ on $Am$ promotions?
3. **Queue Sizing Metric**: Is the queue split governed by byte threshold (e.g., 3 GiB for $A1$ / 9 GiB for $Am$) or entry count, given that sheets have varying sizes around ~2 MiB?

Would you like to record this decision in a dedicated decision doc (`docs/intent/previews/decisions/eviction-policy.md`) or keep it as an LLD Decisions table row, and how would you like to resolve the probe questions before we proceed to updating EARS specs?