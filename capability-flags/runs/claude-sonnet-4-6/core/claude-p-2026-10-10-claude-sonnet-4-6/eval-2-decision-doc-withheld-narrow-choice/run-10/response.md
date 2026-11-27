**Phase 1 — HLD update**

One sentence changed in `docs/high-level-design.md`:

> **Before:** "Owns rendering, pending jobs, and a private 12 GiB cache. Its eviction policy remains open."
> **After:** "Owns rendering, pending jobs, and a private 12 GiB cache with 2Q eviction."

The rest of the HLD is unaffected — no tenets, goals, or non-goals reference the eviction policy, and the external interface contract is unchanged.

Does that read correctly to you? Approve and I'll move to Phase 2 — drafting the 2Q mechanism into the LLD with an edge-case probe.