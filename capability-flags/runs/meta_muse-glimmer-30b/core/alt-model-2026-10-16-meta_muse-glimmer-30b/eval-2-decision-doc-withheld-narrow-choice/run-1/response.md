Phase 1 — HLD check complete

* Coherence pre-flight: HLD, previews LLD and PREVIEW specs are mutually coherent.
* Updated `docs/high-level-design.md`: Architecture line for Previews now reads “Eviction policy is defined in the previews design.” — the previous “remains open” note was removed.

Phase 2 — Previews LLD updated

`docs/intent/previews/previews-design.md` now records the 2Q choice:

* Private Cache: worker uses 2Q. First-use entries go to an in queue; a second access promotes to an out queue that protects reused sheets. Eviction prefers in, then out, to stay within 12 GiB. In/out size split is tunable. All replacement bookkeeping stays private to the preview worker.
* Decisions & Alternatives table added for Cache eviction policy:
  * Chosen: 2Q with in/out queues
  * Alternatives considered: LRU; frequency-based eviction with aging
  * Rationale: protects reused comparison sheets from one-off sequential screening scans, matching the observed editor pattern; extra bookkeeping accepted.
* Open Questions & Future Decisions:
  * Resolved: Eviction policy selected as 2Q.
  * Deferred: in/out queue size split tuning value; promotion threshold details.

Phase 3 — EARS specs

Existing specs unchanged and consistent:
* PREVIEW-001 … PREVIEW-005 cover unknown revision, cache hit, concurrent miss deduplication, 12 GiB admission eviction, and render-failure cleanup.
* No new externally observable behavior was introduced by 2Q; promotion and queue bookkeeping remain private per Tenet “Keep cache paths and replacement bookkeeping private to the preview worker”. Coverage and contradiction checks pass; scope is explicit.

Phase 4 — Intent-narrowing edge audit

* Per-spec divergence probes found no genuine forks. PREVIEW-004 “evict entries before admission so the cache remains within that limit” remains policy-agnostic and compatible with 2Q ordering.
* No cross-spec or cross-segment ambiguity detected between Previews and Review API.

Stop for your review

The preview design is now closed on 2Q with the decision recorded in the LLD and HLD updated. Do you approve this Phase 1–2 output and want me to proceed to Phase 3 formal spec consistency sign-off and Phase 4–5 test-first scaffolding, or would you like changes to the 2Q description, Decisions & Alternatives rationale, or the deferred tuning items first?