I have updated `docs/high-level-design.md` and `docs/intent/previews/previews-design.md` to incorporate the 2Q eviction policy selection, its queue structure ($A1_{in}$, $A1_{out}$, $Am$), and the Decisions & Alternatives rationale.

### Edge-Case Probe (Phase 2)
1. **$A1_{out}$ capacity and eviction**: Should $A1_{out}$ track ghost entries up to a fixed count (e.g., matching the item capacity of $A1_{in}$) or a time-bounded window, and what eviction rule applies when $A1_{out}$ fills?
2. **Ghost-hit render concurrency**: When an access hits an identifier in $A1_{out}$, the sheet's file bytes were previously evicted and must be re-rendered. Does this trigger the standard 202 job-ticket deduplication flow before moving the entry to $Am$ upon render completion?
3. **Queue size budgeting**: Should the 12 GiB disk limit be partitioned into fixed byte quotas for $A1_{in}$ and $Am$ (e.g., 25% / 75%), or should eviction dynamically evict from $A1_{in}$ first until a minimum threshold is reached?

### Decision Doc Bar
This choice is private to the preview worker and does not alter external interfaces, queue concurrency, or disk budgets. A row in `Decisions & Alternatives` captures the rationale context-free. Would you prefer to keep this recorded in the LLD table as drafted, or would you like a full standalone decision doc (`docs/intent/previews/decisions/cache-eviction-policy.md`)?

Please let me know your thoughts on the edge cases and whether we should proceed to Phase 3 (EARS specs).