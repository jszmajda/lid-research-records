No implementation code exists yet — this is a greenfield design. The design is now complete across the arrow. Let me do a final coherence verification:

**HLD → LLD → Specs trace:**
- HLD Key Design Decision: 2Q chosen ✓
- LLD: Details A1in/Am queues, 25%/75% split, promotion on 2nd access, no demotion ✓
- Specs: PREVIEW-006 through PREVIEW-014 cover admission, promotion, hit-refresh, per-queue caps, total-limit eviction order, byte accounting, no demotion, cache key ✓

**Cross-segment**: Review API specs unchanged; preview worker interface fixed per HLD tenet "Keep cache paths and replacement bookkeeping private" ✓

**Consistency report:**
| Pair | Status | Notes |
|------|--------|-------|
| HLD ↔ LLD | Consistent | HLD decision recorded; LLD expands with mechanism |
| LLD ↔ Specs | Consistent | Every LLD mechanism has a spec; no spec without LLD basis |
| Specs ↔ Specs | Consistent | No contradictions; PREVIEW-009 (total-limit) and PREVIEW-010 (per-queue) are distinct triggers |

The preview design is complete with 2Q eviction. Ready for your review — any adjustments before we consider this phase closed?