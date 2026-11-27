Phase 1 — HLD check complete.

Coherence pre-flight:
- HLD `docs/high-level-design.md` exists and covers preview worker architecture, cache budget, and tenets.
- LLD `docs/intent/previews/previews-design.md` traces to HLD: private cache, fixed HTTP contract, 12 GiB bound.
- EARS `docs/intent/previews/previews-specs.md` PREVIEW-001..005 trace to the LLD and HLD; no drift detected.

HLD findings for the 2Q decision:
- The change is internal to the Preview worker’s private cache bookkeeping. The review API contract, architecture, tenets, and goals are unchanged.
- Current HLD line 14 states “Its eviction policy remains open.” With the 2Q selection confirmed, that statement will become stale.

No architectural change is required; the HLD can remain as-is with a note, or we can update line 14 to remove the “remains open” phrasing to keep the HLD context-free.

Do you approve proceeding to Phase 2 — update the Previews LLD to lock in 2Q eviction, Decisions & Alternatives table, and LLD-level edge-case probe?