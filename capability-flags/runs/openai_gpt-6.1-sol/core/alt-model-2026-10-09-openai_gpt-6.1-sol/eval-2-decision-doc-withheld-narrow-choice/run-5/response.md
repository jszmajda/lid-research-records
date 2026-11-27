I’ve recorded **2Q** in `docs/intent/previews/previews-design.md`, with the rationale: protecting comparison sheets during sequential screenings is worth the extra bookkeeping and tuning. This local choice fits in the design’s Decisions & Alternatives table.

One detail needs your judgment before I can finish the mechanics: **what counts as reuse?**

- **Resident two-queue variant:** a genuine cache hit promotes a first-use sheet into the reused queue. Comparisons get protection immediately, but render-completion polling must not accidentally count as comparison reuse.
- **Full 2Q:** keep a bounded history of evicted first-use keys; requesting one again earns admission to the reused queue after rendering. This adds history bookkeeping, and repeated hits before eviction leave the sheet in the first-use queue.

**Which interpretation do you want?** I recommend the resident variant for immediate protection of actively compared sheets.

The design probe also identified details to settle or explicitly defer: queue sizing and borrowing, oversized-sheet admission, restart recovery, concurrent admission and eviction, and completed-ticket behavior after eviction. The HLD still describes eviction as open; its summary needs synchronization with the selected policy.

The document edit passes `git diff --check`. EARS drafting waits for the design choices above.