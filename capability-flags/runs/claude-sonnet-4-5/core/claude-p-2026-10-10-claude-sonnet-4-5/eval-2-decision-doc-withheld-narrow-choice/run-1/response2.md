Created `docs/intent/previews/decisions/cache-eviction-policy.md` with the full analysis — four weighted criteria (scan resistance as major), all three options with demonstrations and per-criterion verdicts, and the selection rationale linking back to the HLD tenet.

The LLD's Decisions & Alternatives table now links to it:

| Decision | Chosen | Alternatives Considered | Rationale |
|----------|--------|------------------------|-----------|
| Cache eviction policy | 2Q (two-queue) with 25% A1 / 75% Am split | LRU, frequency-based with aging | Protects comparison sheets from sequential scan eviction. See [decisions/cache-eviction-policy.md](decisions/cache-eviction-policy.md) for full analysis. |

The decision doc captures why 2Q wins (scan resistance outweighs adaptation lag), the 25%/75% split rationale, and what it obligates downstream. A cold reader can reconstruct the judgment if workload patterns change.

Does the decision doc capture the tradeoffs correctly? Ready to proceed to Phase 3 (EARS specs)?