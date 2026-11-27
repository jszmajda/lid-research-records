Done. Decision doc written and linked from the LLD.

**Phase 2 — LLD Update Complete**

Updated `docs/intent/previews/previews-design.md` with:
- Detailed 2Q Cache Eviction section specifying queue behavior, promotion, and eviction rules
- Decisions & Alternatives table with link to the decision doc
- Open Questions & Future Decisions section

Created `docs/intent/previews/decisions/cache-eviction-policy.md` documenting the eviction policy choice with full context, decision elements (gates and weighted criteria), analysis of all three options, and selection rationale.

**LLD-level edge-case probe findings** (from earlier):

Before proceeding to EARS specs, which of these gaps should be resolved in the LLD?

1. **Queue membership tracking**: How is "accessed exactly once" vs "more than once" tracked?
2. **Concurrent promotion and eviction**: What happens when a preview in A1 is being accessed (triggering promotion to Am) at the same moment that A1 needs to evict it?
3. **Variable preview sizes**: Queues are sized in GiB (3 GiB and 9 GiB), but how is "at capacity" checked when preview sizes vary? What happens when a single preview larger than A1's capacity needs admission?
4. **Render completion for cached key**: What happens if a render job completes for a preview that was already cached while rendering was in progress?
5. **Cache corruption**: What happens if a preview is listed in a queue but its JPEG file is missing or corrupted on disk?
6. **Eviction and admission atomicity**: When promoting from A1 to Am requires evicting from Am first, can a concurrent request observe the preview in neither queue?
7. **Queue size enforcement across varying file sizes**: How is the 25%/75% capacity split balanced when file sizes vary?
8. **Warm cache startup**: When the preview worker restarts with cached files on disk, how are they distributed between A1 and Am?