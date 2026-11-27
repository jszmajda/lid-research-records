I've finished the design work and am stopping at the Phase 2 boundary. Final message below.

---

Done — the preview design is finished. I'm stopping here for your review rather than rolling straight through EARS specs, tests, and code on "go ahead and finish": LID holds a mandatory stop at every phase boundary, and the design ~is~ what you asked me to finish.

**Pre-flight (new session) & Phase 1 — HLD.** Coherence check passed: specs trace to their LLDs, there's no code/tests yet (all `[ ]`), and both LLDs match the HLD's architecture. I fixed one stale line — `docs/high-level-design.md:14` said "Its eviction policy remains open"; it now just records that the worker owns its own eviction policy. The 2Q choice stays in the leaf: it's a private, single-node decision, so no HLD option re-sketch and no architecture change. The `review-api` segment, the fixed `GET /internal/previews/{clip-id}/{revision}` contract, and the FIFO render queue are untouched — no cross-segment cascade.

**Phase 2 — `docs/intent/previews/previews-design.md` finished.** Written as current intent, not as a record of the argument (no "last session", no meeting/thread, no "we chose 2Q over…" in the prose). Architecture, Rendering & Deduplication, and the 12 GiB Private Cache paragraph are unchanged. New/changed content:

- **Context** — why a scan-resistant policy fits: long sequential screenings vs. a reused comparison working set, re-render ≈450 ms.
- **Replacement Policy (2Q)** (`previews-design.md:26`) — probationary A1 (first use) + protected Am (reused); promotion A1→Am on a hit; eviction drains A1 first and Am only when A1 is empty, so one-use screening sheets can't displace comparison sheets; all bookkeeping private to the worker; HTTP contract, FIFO queue, and 12 GiB budget unchanged; A1/Am size split a tunable parameter.
- **Decisions & Alternatives** — one row: Chosen = 2Q; Alternatives = LRU, frequency-with-aging; Rationale = keep reused comparison sheets through big screenings, extra bookkeeping accepted because it stays private to the worker and is cheap next to a re-render.
- **Open Questions** — size split deferred to implementation.

I recorded the choice as that Decisions row, not a standalone decision doc: the test is whether the choice stays live for a cold reader with *other nodes sized around it*, and here it is private to one node with every other node explicitly unchanged. That's a recording call I've made, not a question I'm putting to you.

**LLD-level edge-case probe** — gaps inside this component for you to triage (pin down in the LLD now vs. defer):
1. Does "reuse" include a request that joined an already-pending render ticket while a sheet was still rendering, or only a hit on a fully cached entry?
2. When an evicted A1 key is requested again, does it re-enter A1, or is there a ghost/reconsideration list admitting it straight to Am?
3. Is Am bounded; can a cold Am entry be demoted/aged out; if Am is full but A1 is not, which queue takes a new admission?
4. Within each queue, is eviction FIFO or LRU, and does a hit on an Am entry change its position?
5. Is queue membership in-memory only or persisted across a worker restart; does the cache start empty on restart?
6. How is the 12 GiB budget divided between A1 and Am (fixed vs dynamic) — the tunable size split you flagged, currently parked as Deferred pending your ruling.

(Cross-component and cross-spec questions, e.g. interaction with the `review-api` specs, are Phase 4 — after this stop.)

**Please:**
(a) approve, or give numbered feedback on, the finished design and the HLD edit;
(b) triage the six gaps — which to fix in the LLD now, which to defer.

I'll hold here and won't draft EARS specs, run the divergence/edge audit, or write tests until you rule. Default is you reading this stop yourself; say the word if you'd prefer a zero-context or delegated reader instead.