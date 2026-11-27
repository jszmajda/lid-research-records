Agreed — it earns one, and it's written: `docs/intent/previews/decisions/eviction-policy-2q.md`, linked from the Decisions row in `previews-design.md`.

It follows the standard structure: Context (the screening-vs-comparison workload mix and why the miss cost matters), Decision Elements (scan resistance as the major criterion; bookkeeping cost, adaptation to workload shift, and structural simplicity as moderate/minor), the three options each given their strongest honest representation with per-criterion verdicts, and a Selection that names why 2Q beats aged frequency — same scan resistance, no per-hit counters or decay pass, immediate adaptation after a project switch — and closes the tenet loop: the *bookkeeping stays private to the worker* tenet is what makes 2Q's extra structure affordable. It also records the re-run trigger: revisit if reused sheets still get displaced, or if bookkeeping measurably hurts render throughput.

Still open from the last stop, before we move to Phase 4:

1. **Probe triage** — resolve now or defer: (a) Am evictions don't re-enter the ghost list (only A1 evictions feed it); (b) Am hits refresh LRU position (implied, not spec'd); (c) ordering under concurrent admissions against a queue cap — I'd defer as an implementation detail.
2. **Approval** to proceed to Phase 4, the intent-narrowing edge audit over the new EVICT specs.