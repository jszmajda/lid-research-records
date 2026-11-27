**Phase 1 (HLD check) is done. Please review before I draft the previews LLD.**

**HLD check:** The change stays inside the previews node. The HLD's architecture, tenets, goals, and non-goals still hold, and the review API boundary is unchanged. The only stale line was the one saying the eviction policy "remains open," so I removed that sentence in `docs/high-level-design.md`:

```diff
-- Previews: ... Owns rendering, pending jobs, and a private 12 GiB cache. Its eviction policy remains open.
+- Previews: ... Owns rendering, pending jobs, and a private 12 GiB cache.
```

**Decision record:** The 2Q choice affects only the previews node, so I won't offer a standalone decision doc. It will go in the previews LLD's Decisions & Alternatives table, with LRU and frequency-with-aging recorded as the rejected alternatives and why.

**Open question for Phase 2:** 2Q needs two values that no document settles yet: the share of capacity given to the first-use queue, and how many evicted entry keys the history queue remembers. Tell me if you have a preference. Otherwise I'll propose defaults at the Phase 2 stop, with the tradeoff for each.

Reply with approval or numbered changes, and I'll draft the LLD and the Phase 2 probe.