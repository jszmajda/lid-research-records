Done. Written to `docs/intent/previews/decisions/eviction-policy.md` (frontmatter `node: previews`, no EARS IDs), and linked from the LLD's Decisions row.

The doc lays out context (the asymmetric eviction cost), five weighted criteria — scan resistance and reuse retention *major*; bookkeeping, adaptation, tunability lower — and one section per option with per-element verdicts. Selection picks 2Q as the only option strong on both major criteria, disqualifies LRU on weak scan resistance and aged frequency on weak adaptation, and names the two tenets it turns on (private bookkeeping; cache is never authoritative). The size split is explicitly left out of the decision as a tuning parameter.

That closes your doc offer, but Phase 2 isn't approved yet. Still open:

1. **LLD approval** — the Private Cache 2Q section, Decisions row, and Open Questions as they now stand (`docs/intent/previews/previews-design.md`).
2. **Edge-probe triage** — the six items from my last message: queue-size split default, oversized single sheet, two-queue eviction ordering, restart behavior, promotion under load, and eviction timing.
3. **Decision doc review** — anything to change in `eviction-policy.md`.

Approve as-is, or give numbered feedback. On approval I'll move to Phase 3 and update `previews-specs.md`.