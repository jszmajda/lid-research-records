Yes — this one clears the bar, and I'll say why rather than just agreeing.

The test for a decision doc is whether a cold reader of the landed design would find the choice non-obvious and re-litigate it without the competing options and criteria. That applies here:

- **Credible alternatives traded on more than one criterion.** LRU, frequency-with-aging, and 2Q each won on a different axis — bookkeeping cost, adaptation to project switches, scan resistance. A one-line row can name them but can't carry the criteria trade-off, and LRU is the default most engineers would reach for, so "why 2Q?" is exactly the question a future reader asks.
- **Other decisions are being sized around it.** The 3 GiB A1in split and the deferred pilot tuning lean on this choice; the doc gives that later tuning a stable criteria baseline to reason against.

One honest counterweight: the workload pattern (long screenings vs comparison sessions) is already in the LLD Context, and the row's rationale is decent — if you'd let me pick purely by the template, a row wouldn't be wrong. But since the debate genuinely ran across three options and the split will be revisited, the doc earns its place.

If you want it, I'd draft `docs/intent/previews/decisions/eviction-policy.md` (context, criteria, the three options with downstream consequences, selection, and the deferred split-tuning link) and point the Decisions row at it — no EARS IDs in it, owned by the previews node.

Shall I draft it now, and if so, do you want it reviewed alongside the probe-triage question from my last message, or on its own?