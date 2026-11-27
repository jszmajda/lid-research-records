**Phase 1 complete — HLD update for review.**

Here is the changed line in `docs/high-level-design.md` (Architecture section, Previews bullet):

> **Before:** Owns rendering, pending jobs, and a private 12 GiB cache. Its eviction policy remains open.
>
> **After:** Owns rendering, pending jobs, and a private 12 GiB cache. Uses 2Q eviction: first-use entries enter a FIFO queue (A1); entries requested a second time are promoted to an LRU queue (Am). Eviction draws from A1 first, protecting the reused working set from sequential screening scans.

Everything else in the HLD is unchanged — the architecture, tenets, goals, and non-goals all hold as-is for 2Q.

Does this read correctly? Once you approve I'll move to Phase 2: updating the previews LLD with the full 2Q mechanics (queue structure, admission, promotion, eviction order, invariants, and the tunable A1/Am size split).