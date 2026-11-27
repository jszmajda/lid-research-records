I have updated `docs/intent/previews/previews-design.md` (and removed the stale open-eviction-policy note in `docs/high-level-design.md`) to specify 2Q replacement and record the selection against single-queue LRU and aged frequency-based eviction in the LLD's `Decisions & Alternatives` table. Because cache eviction is completely private to `previews` and no other node sizes around or depends on it, a table row suffices rather than a standalone decision doc.

### Updated `docs/intent/previews/previews-design.md` (Private Cache & Decisions)

```markdown
## Private Cache

Cached JPEG data may occupy at most 12 GiB. Before admitting a completed sheet, evict enough existing sheets to remain within that bound. Temporary render output is kept separately and removed on completion or failure. Eviction never deletes source footage or changes job-ticket semantics.

Cache replacement uses 2Q to separate one-off screening accesses from repeatedly compared sheets:

- **Probation queue (`A1in`)**: Holds newly rendered sheets on their first admission in FIFO order. Bounded to a configured share of the 12 GiB budget (e.g., 25% / 3 GiB). When `A1in` exceeds its budget, the oldest sheet in `A1in` is evicted from the cache, and its key is recorded in the ghost queue (`A1out`).
- **Ghost queue (`A1out`)**: Tracks keys (metadata only, no JPEG bytes on disk) recently evicted from `A1in` in FIFO order, bounded by entry count (e.g., 3,000 keys, roughly matching the sheet capacity of `A1in` at ~2 MiB per sheet).
- **Protected queue (`Am`)**: Holds sheets promoted after a repeat request, managed by LRU within the remaining cache budget (e.g., 75% / 9 GiB).
- **Access and admission transitions**:
  - A cache hit in `Am` moves the entry to the MRU position of `Am`.
  - A cache hit in `A1in` leaves the entry in `A1in`.
  - On a cache miss where the preview is rendered and admitted: if the key is present in `A1out`, remove it from `A1out` and admit the rendered sheet directly into `Am` (evicting from `Am` by LRU if needed); otherwise admit the rendered sheet into `A1in` (evicting from `A1in` FIFO to `A1out`, or from `Am` if total cache bytes would exceed 12 GiB).

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Cache eviction policy | 2Q (FIFO probation `A1in` + ghost history `A1out` + LRU protected `Am`) | Single-queue LRU; frequency-based eviction with aging (LFU with decay) | Editors alternate long sequential screenings of one-use sheets with repeated comparisons of a small working set. Single-queue LRU has minimal bookkeeping and adapts quickly on project switches, but sequential screening scans flush comparison sheets. Aged frequency counts retain popular sheets across scans, but counter maintenance and aging add ongoing overhead and retain stale favorites after editors switch projects. 2Q isolates first-use screening traffic in `A1in` while keeping revisited comparison sheets in `Am`, trading bounded two-queue bookkeeping and partition-size tuning for scan resistance within the preview worker's private cache. |
```

### Phase 2 LLD Edge-Case Probe

Before we proceed to Phase 3 (updating `previews-specs.md`), please review the updated LLD and tell me how you'd like to handle these LLD-level edge cases (fix in the LLD now vs. defer to Open Questions):

1. **In-cache hits while still in `A1in` (Simplified 2Q vs. Full 2Q)**: If an editor compares a clip twice within a short window while the sheet is still resident in `A1in` (before a screening scan pushes it out to `A1out`), should a hit in `A1in` promote the sheet immediately to `Am`, or strictly follow canonical 2Q where `A1in` hits do not promote and promotion only happens via `A1out` after eviction from `A1in`?
2. **Concrete partition budgets (`A1in`, `Am`, and `A1out`)**: Should the LLD fix exact target budgets for the 12 GiB cache (such as 3 GiB `A1in` / 9 GiB `Am` and 3,000 keys in `A1out`), or keep them as configurable worker parameters?
3. **Cross-partition byte pressure**: Because contact sheets vary in byte size, when `Am` is below its target share and `A1in` is full (or vice versa), should each queue enforce a hard byte cap independently, or evict from `A1in` only when `A1in` exceeds its target threshold while total cache size exceeds 12 GiB?
4. **Worker restart / cold-start state**: When the preview worker restarts with existing JPEG files on disk, should it rebuild queue state, place discovered files into `A1in` / `Am`, or clear/re-index the cache directory on startup?
5. **Oversized or corrupted render output**: What happens when a single rendered sheet exceeds the `A1in` cap (or fails to write to cache storage after rendering succeeds) — should it still be served on the completing request without caching, or fail the job?

Please let me know your preferences on these items and whether you approve the Phase 2 LLD updates to move to Phase 3 (EARS specs).