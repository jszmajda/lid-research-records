Updated `docs/intent/previews/previews-design.md` to specify the 2Q replacement policy (and removed the stale "remains open" note in `docs/high-level-design.md` to keep the HLD coherent). Because the replacement policy is private to the preview worker and affects no other node, it is recorded in the LLD's **Decisions & Alternatives** table rather than a separate decision doc.

### Summary of Changes

- **`docs/high-level-design.md`**: Removed `"Its eviction policy remains open."` from the Previews entry under `## Architecture`.
- **`docs/intent/previews/previews-design.md`**:
  - **Context & Architecture**: Framed the sequential-screening vs. comparison-working-set workload and kept the HTTP contract independent of internal replacement.
  - **Private Cache — Replacement Policy (2Q)**: Defined `A1in` (FIFO, initial 25% byte budget), `A1out` (ghost FIFO of evicted `A1in` keys, sized to 50% of nominal ~6,000-sheet capacity), and `Am` (LRU, initial 75% byte budget), along with admission and eviction rules within the 12 GiB JPEG bound.
  - **Decisions & Alternatives**: Recorded `2Q` over `LRU` and `frequency-based eviction with aging`.
  - **Open Questions & Future Decisions**: Marked the eviction policy resolved and deferred tuning of the `A1in`/`Am` split and `A1out` capacity to pilot telemetry.

### LLD Edge-Case Probe (for Triage)

A blind probe of `docs/intent/previews/previews-design.md` surfaced these internal gaps. Please indicate which to fix in the LLD now versus defer as open questions:

1. **2Q eviction loop under empty `Am`**: What happens when `total + S > 12 GiB`, `A1in` is at or below its 25% byte budget, and `Am` is empty (e.g., all cached data is in `A1in` during a cold scan)?
2. **Oversized sheet**: What happens when a single rendered sheet has size $S$ exceeding the `A1in` budget (3 GiB) or the 12 GiB cache bound?
3. **Concurrent read vs. eviction**: What happens when a cache hit reads a JPEG file in `A1in` or `Am` concurrently with the eviction loop deleting that file?
4. **Admission visibility**: What happens when a request arrives after rendering finishes but while eviction and file move into the cache are still in progress?
5. **Worker restart / crash**: On restart, are the 12 GiB cache and 2Q metadata (`A1in`, `A1out`, `Am`) wiped or reconstructed from disk, and how are orphaned temp files and pre-restart `202` tickets handled?
6. **Renderer version upgrade**: When a new renderer version deploys, are prior-version JPEGs purged on startup or displaced lazily by 2Q?
7. **`202` schema & failure visibility**: What is the exact `202` response schema, and when a background render fails and is removed from the deduplication map, does a client's 2-second retry silently enqueue a new job or surface the prior failure?
8. **Source unavailability vs. unknown revision**: If source footage for a known revision is temporarily unreachable (or a render fails), what HTTP status is returned?
9. **Render queue bounds & hung jobs**: Is the FIFO render queue depth bounded (and what status is returned if full), and are active render jobs timed out to reclaim slots?
10. **Deduplication race & temp storage**: What synchronization prevents duplicate enqueues on simultaneous misses, and is temporary render storage bounded separately from the 12 GiB cache?

---

**Phase 2 Stop:** Please review `docs/intent/previews/previews-design.md` (and the `docs/high-level-design.md` line update), triage the probe items above (fix in LLD vs. defer), and confirm when you're ready to proceed to **Phase 3 (EARS specs)**.