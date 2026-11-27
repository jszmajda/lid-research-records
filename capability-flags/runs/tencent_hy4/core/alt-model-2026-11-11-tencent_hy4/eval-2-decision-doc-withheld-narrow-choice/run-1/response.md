Coherence pre-flight passed: `PREVIEW-001`–`005` still trace to this LLD, the LLD matches the HLD architecture, and there are no tests/code yet (all specs are `[ ]` active gaps, so no test drift). I removed the now-stale "eviction policy is open" markers from both the HLD and this LLD. The 2Q choice stays at the previews leaf — not raised into the HLD — and the review-api segment consumes none of it, so no cross-boundary cascade is needed.

How the choice is recorded: a row in the LLD's new **Decisions & Alternatives** table (2Q chosen; LRU and aged-frequency named as rejected, with rationale). No decision doc and no offer for one — once landed, 2Q reads as a self-contained worker detail whose effects stay entirely inside the previews segment, so it doesn't clear the bar regardless of how long the debate ran.

**Phase 2 output — `docs/intent/previews/previews-design.md`** (for your review):
- *Context* reworded to state the scan-heavy / reuse-heavy constraint.
- *Private Cache* now specifies 2Q: new sheets enter a probationary FIFO queue; a second access while still in it promotes a sheet to a protected LRU queue; one-off screening sheets never reach the protected queue; eviction drains the probationary queue first and only then touches the protected one. The 12 GiB split between the queues is a tunable worker parameter. The `GET /internal/previews/...` outcomes, four-job render queue, 12 GiB bound, and all-private queue state are unchanged.
- *HLD*: removed only the stale "Its eviction policy remains open." clause.

**LLD-level edge-case probe** (delegated, surfaced — not resolved; several admit more than one reading, so per the workflow they go to you before any spec or test is written against them):
1. **"Access" for 2Q** — does a 200, a 202 job ticket, or the triggering request count? Does a just-admitted sheet need two further hits, or is its triggering request the first access? Do requests sharing one ticket count as accesses?
2. **Promotion / recency** — moved vs. copied out of probationary, recency reset on promotion, what refreshes the protected queue's LRU order, and can a protected entry demote back to probationary?
3. **Eviction order** — is the probationary queue strictly emptied before any protected eviction, or does eviction stop once enough bytes are freed? Is the eviction unit whole sheets only?
4. **The tunable split** — expressed as byte caps, a ratio, or entry counts; its default and range; a hard per-queue cap vs. only an eviction-order target; runtime adjustability and whether a change rebalances existing entries.
5. **Admission / atomicity** — is a sheet admitted at render completion or lazily, when does the job ticket leave the dedup map, can two entries for one key coexist, and are eviction + byte accounting + admission + dedup atomic under up to four concurrent completions (including a sheet larger than 12 GiB)?
6. **Bound coverage** — does 12 GiB include the "separate" temporary render output, and can an in-progress render transiently exceed it?

**STOP (Phase 2 boundary).** Please rule: (a) which of the six probe items to fix in the LLD now and which to defer as Open Questions, and (b) approve these LLD + HLD edits or give numbered corrections. I'll hold here and won't move to Phase 3 (EARS specs) until you do.