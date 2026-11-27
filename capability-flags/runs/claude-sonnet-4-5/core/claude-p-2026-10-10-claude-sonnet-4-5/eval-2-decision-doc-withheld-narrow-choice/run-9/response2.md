Yes, this one earns a decision doc. Applying the landed-state test: a cold reader seeing "2Q eviction" in the previews LLD would have three credible alternatives to question it against (LRU's simplicity, frequency-based's popularity tracking), multiple criteria in tension (bookkeeping cost vs. scan resistance vs. adaptation speed), and the 12 GiB cache bound was sized with this choice in mind. The debate was long because the choice is genuinely live, not because you were overthinking a dominated option.

I'll offer both paths:

1. **Decision doc** in `docs/intent/previews/decisions/cache-eviction-policy.md` — the three alternatives as sections, the criteria (bookkeeping overhead, comparison-sheet retention during screenings, adaptation to project switches), the fit verdict showing how 2Q's scan resistance aligns with the workload pattern, and a link from the previews LLD's Decisions table.

2. **Decisions table row** — one line in the previews LLD capturing "2Q eviction" as chosen, "LRU, frequency-based aging" as alternatives, and "protects comparison sheets from sequential scan eviction at acceptable bookkeeping cost" as rationale.

The doc preserves the "why not LRU?" counterargument for the next person who sees the two-queue overhead. The row records the choice without the re-litigation depth.

Which would you prefer?