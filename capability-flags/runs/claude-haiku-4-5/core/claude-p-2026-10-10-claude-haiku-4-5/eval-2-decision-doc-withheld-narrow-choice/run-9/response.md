## Phase 3: EARS Specification — 2Q Cache Replacement

I've updated the LLD and EARS specs to lock in the 2Q decision. Here's the consistency verification:

**Coverage**: All LLD behaviors are specified — initialization (PREVIEW-010), new entries (PREVIEW-011), promotion on reuse (PREVIEW-012), refresh in Outqueue (PREVIEW-013), Inqueue eviction trigger (PREVIEW-014), Outqueue eviction (PREVIEW-015), removal mechanics (PREVIEW-016), target drift (PREVIEW-017).

**Contradiction**: None detected. Queue transitions, access patterns, and eviction order form a coherent flow.

**Implicit scoping**: All specs are concrete. PREVIEW-012 and PREVIEW-013 clearly scope to first vs. second+ access. PREVIEW-014 and PREVIEW-015 are conditional on cache state. PREVIEW-017 explicitly clarifies the 30/70 split is approximate and drifts naturally.

**Context-free reading**: Each spec stands alone. Queue names and transitions are defined in the LLD and PREVIEW-010. No reliance on conversation context.

**Updated artifacts:**
- `docs/intent/previews/previews-design.md` — filled in the 2Q mechanics, added rationale for why this protects comparison sheets during screening scans, specified queue target sizes (30% / 70%).
- `docs/intent/previews/previews-specs.md` — added eight new specs (PREVIEW-010 through PREVIEW-017) covering queue initialization, promotion, refresh, and eviction order.

The design now specifies a complete, deterministic eviction algorithm. Proceed to Phase 4 (edge audit) and Phase 5 (tests) when you're ready, or flag any changes needed to the specs or LLD first.