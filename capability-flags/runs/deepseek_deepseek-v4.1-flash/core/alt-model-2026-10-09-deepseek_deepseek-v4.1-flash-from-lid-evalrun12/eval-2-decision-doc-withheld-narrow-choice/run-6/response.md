Phase 2 (LLD) is done — here is the previews design with the eviction policy settled on 2Q.

**`docs/intent/previews/previews-design.md` — new `### Eviction policy (2Q)` under Private Cache**

> The cache replaces entries with a two-queue policy that separates sheets seen once from sheets that are reused. Two queues hold cached entries:
> - **Probation queue** — a sheet enters here when it is first admitted after rendering. Entries are ordered oldest-first.
> - **Protected queue** — a cache hit on a sheet while it is in the probation queue promotes that sheet here. A hit on a sheet already in the protected queue refreshes its position. Entries are ordered least-recently-used first.
>
> When admitting a completed sheet would exceed the 12 GiB bound, the worker evicts from the probation queue oldest-first, and only when the probation queue cannot supply enough space does it evict from the protected queue least-recently-used first. A long sequential screening therefore cycles through the probation queue and evicts its own one-use sheets before any reused comparison sheet is touched.
>
> The probation and protected queues partition the 12 GiB budget; the split is a worker-internal parameter left to tuning. The policy reads and updates only its own queues and exposes no counters, queue membership, or size split to the review API or to clients. It does not change the HTTP interface, the render queue's four-job concurrency, or the 12 GiB disk budget.

**Decisions & Alternatives** — added a row recording 2Q over LRU and aged frequency, with the scan-resistance rationale. **Open Questions & Future Decisions** — eviction policy marked resolved; three items deferred. I also fixed the HLD line that still called the policy open (`docs/high-level-design.md:14`), since it no longer reflects current intent.

**LLD-level edge-case probe** (triage these — fix in the LLD now or defer):
1. **Queue-size split** — the tuning parameter has no default. Do we set one (e.g. a fixed probation share) or leave it purely configurable?
2. **Oversized single sheet** — what if one sheet alone exceeds the probation queue's share of the budget? Admit into protected, evict everything else, or reject?
3. **Two-queue eviction ordering** — when one admission needs space from both queues, is the order probation-then-protected strictly, or is it budget-driven during a single admission?
4. **Worker restart** — queue position is lost on restart; the cache is non-authoritative, so is that simply acceptable (no persistence)?
5. **Promotion under load** — if a hit promotes a sheet into a full protected queue, is that promotion itself an admission that triggers eviction, or is promotion allowed to overflow until the next admission?
6. **Eviction timing** — eviction is described as happening at admission; confirm it runs synchronously under the same lock as the render-completion handoff rather than as a background pass.

One offer: this choice stayed genuinely live across three options and a long debate, so a cold reader could re-litigate it. Want me to record it as a full decision doc at `docs/intent/previews/decisions/eviction-policy.md` (context, gates/criteria, per-option analysis, selection), or is the Decisions row enough?

Please approve the LLD as-is or give numbered feedback. On approval I'll move to Phase 3 and update `previews-specs.md` (PREVIEW-004 covers eviction generically; 2Q likely needs lines for promotion-on-reuse and eviction order).