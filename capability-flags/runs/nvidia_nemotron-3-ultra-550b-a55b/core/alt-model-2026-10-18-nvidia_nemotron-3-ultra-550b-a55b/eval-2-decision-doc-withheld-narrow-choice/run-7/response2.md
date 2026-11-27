Decision doc created at `docs/intent/previews/decisions/001-2q-eviction-policy.md` and linked from the LLD.

**Back to Phase 4 — three open questions from the edge audit:**

1. **PREVIEW-007 promotion timing**: "Accessed again" = strictly a *subsequent* request (not the admission request), correct?

2. **PREVIEW-009/010 eviction granularity**: Evict one entry per loop iteration, or calculate bytes-to-free and batch-evict? (Both satisfy spec; former simpler, latter fewer iterations.)

3. **Renderer version in cache key**: Renderer version bump → new key entering A1 fresh (not promoted from old version's Am entry), correct?

Please confirm or provide alternatives, then I'll finalize Phase 4.