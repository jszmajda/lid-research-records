Recorded your 2Q selection and finished the previews LLD. Here is the Phase 2 output for your review.

**Decisions & Alternatives row added** (previews-design.md) — chosen: 2Q with an A1/Am split; alternatives LRU and frequency-with-aging rejected with rationale. No standalone decision doc: the choice affects only this node, and no other design node is sized around it. Say the word if you want it promoted to a decision doc anyway.

**Eviction Policy: 2Q section** (replaces the open-candidates paragraph):

- **A1 (first-use queue)** — holds a sheet after its first render or a fresh render. When A1 exceeds its size cap, the sheet at A1's front is evicted.
- **Am (main queue)** — holds sheets reused at least once. A hit in Am moves the sheet to Am's MRU end. When the total cache exceeds 12 GiB, the sheet at Am's LRU end is evicted first.
- A hit in A1 promotes the sheet to Am; no duplicate across queues. Eviction order: drain A1 to its cap first, then evict from Am's LRU end until within 12 GiB. A sheet evicted from Am re-enters A1 as first-use on its next miss.
- A1's size cap is the tunable parameter that shields comparison sheets during screenings: it starts at 25% of budget (3 GiB, ~1,500 sheets at 2 MiB) and is tuned after the pilot. All bookkeeping stays private to the worker.

**HLD updated**: "Its eviction policy remains open" → "under a 2Q eviction policy."

**LLD edge-case probe** — gaps to triage (fix in LLD now, or defer as open questions):

1. **Concurrent-hit promotion**: two simultaneous hits in the same A1 entry — is promotion idempotent, and does a hit that races an A1 eviction still promote?
2. **Failed render re-admission**: after a render failure releases its dedup entry, the eventual re-render re-enters A1 as first-use — is that intended, or should a retry count as reuse?
3. **Renderer-version bump**: same clip/revision re-rendered under a new renderer version is a new key and lands in A1 as first-use — confirm this is wanted rather than inheriting the old entry's Am position.
4. **Over-budget while A1 under cap**: eviction then comes solely from Am's LRU end, so a hot screening burst could drain Am's tail while A1 holds scan sheets — confirm the ordering is intended (2Q standard) or whether you want a size-preservation rule.
5. **What counts toward 12 GiB**: only admitted, completed sheets; pending render output is separate temp storage — confirm.

Approved as-is, I'll cascade to the EARS specs (new PREVIEW-006+ covering the 2Q mechanics) next, and stop there for review before tests.