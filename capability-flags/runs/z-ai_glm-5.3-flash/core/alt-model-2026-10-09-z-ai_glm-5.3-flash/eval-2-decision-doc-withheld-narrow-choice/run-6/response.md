Done drafting — here's the stop for your review.

## Phase 2 — Previews LLD (docs/intent/previews/previews-design.md)

The open-policy paragraph is replaced with the 2Q design:

- **Queues**: A1 first-use queue, FIFO, capped at 3 GiB; Am main queue, LRU, capped at 9 GiB; the 12 GiB total is unchanged. A keys-only **ghost list** (max 2048 keys, no JPEG data) remembers recently evicted A1 entries.
- **Movement**: first render → tail of A1 (overflow evicts A1's head into the ghost list). Second access to an A1 entry → promoted to Am's MRU position. A miss whose key is in the ghost list → admitted straight to Am on render completion — this is what shields reused comparison sheets from screening scans. Am overflow evicts its LRU entry; ghost overflow discards its oldest key.
- **Fixed contract**: HTTP outcomes, job tickets, the 4-job render queue, and the private-to-worker rule are untouched; failed jobs never reach any queue.
- Added a **Decisions & Alternatives** table (eviction policy; fixed splits vs. single pool) and an Open Questions entry deferring tuning of the 3/9 GiB split and 2048-key bound to post-pilot observation.
- HLD line for Previews updated from "eviction policy remains open" to naming 2Q. Review API needs no change (fixed interface, no eviction coupling) — no cross-segment cascade.

## Phase 3 — Specs (previews-specs.md)

Added seven `[ ]` specs under a new within-leaf facet, `PREVIEW-EVICT-001..007`: admission to A1 vs. ghost-hit admission to Am, A1→Am promotion, A1/Am cap evictions, ghost bound, and keys-only/12 GiB invariants. PREVIEW-001–005 unchanged (PREVIEW-004's 12 GiB bound is now realized by EVICT-004/005).

**Consistency report**: coverage — every LLD mechanism maps to a spec; contradiction — none (004 states the total bound, EVICT specs the mechanism); scoping — A1/Am/ghost/quantities named inline in each line, so specs survive grep without section context; context-free — no conversational residue.

**Phase 2 edge-probe gaps for you to triage** (fix in LLD now vs. defer):
1. An Am entry evicted from Am does **not** re-enter the ghost list (only A1 evictions feed it) — confirm.
2. A hit on an Am entry refreshes its LRU position — currently implied, not spec'd.
3. Ordering under concurrent admissions against a queue cap (single eviction point vs. transient overshoot) — I'd defer as an implementation detail.

## Two things for you

1. **Decision doc?** The 2Q choice was contested across three meetings and other design (queue sizes, tuning constants) is sized around it, so a cold reader could re-litigate it. I've recorded it as a Decisions row already; I can also memorialize it as a full decision doc under `docs/intent/previews/decisions/`. Want one, or is the row enough?
2. **Probe triage**: resolve gaps 1–3 now or defer?

On your approval of this stop, next is Phase 4 (intent-narrowing edge audit: divergent readings of the EVICT specs), then tests-first.