Now I'll perform the post-draft consistency verification and intent-narrowing edge audit to identify any gaps before the user review stop.

**Consistency Verification:**

- **Coverage**: All behaviors described in the LLD (2Q structure, promotion, A1-first eviction, split ratio) map to specs. ✓
- **Contradiction**: No specs contradict each other. ✓
- **Implicit scoping**: All specs apply to the cache management subsystem; scopes are clear. ✓
- **Context-free reading**: Each spec stands alone without relying on conversation context. ✓

**Intent-Narrowing Edge Audit — Divergence Probes:**

I found several genuine forks where the specs admit multiple plausible readings:

1. **Within-queue eviction order (PREVIEW-008, PREVIEW-006)**: The spec says "evict entries from A1 first" but does not specify the order *within* A1 or A2. Is it oldest-first (FIFO), or least-recently-used within the queue?

2. **A2 access semantics (PREVIEW-007)**: When an entry already in A2 is accessed again, what happens? The spec is silent on whether it's reordered or marked fresh.

3. **Strict vs. soft capacity split (PREVIEW-009)**: The spec uses "occupies" language—does a 24% A1 / 76% A2 split violate the spec, or is the 25%/75% a target that can drift within reasonable bounds?

4. **What triggers a reaccess count (PREVIEW-007)?** Is it any `GET /internal/previews/...` request that hits the cache, or only successful renders? If a request comes during rendering, does it count?

These are choices your intent should settle before tests and code follow them.

---

## Phase 2 & 3 Review

**Updated LLD (`previews-design.md`)**: Finalized the 2Q decision with implementation mechanics (A1/A2 queues, 25%/75% split, promotion rule, eviction order).

**Updated EARS Specs (`previews-specs.md`)**: Added six new specs (PREVIEW-006 through PREVIEW-009) capturing queue structure, promotion behavior, eviction priority, and split ratio.

Please review the updated design and specs, then address the four divergence forks above—your answers will anchor the test-first phase to come.