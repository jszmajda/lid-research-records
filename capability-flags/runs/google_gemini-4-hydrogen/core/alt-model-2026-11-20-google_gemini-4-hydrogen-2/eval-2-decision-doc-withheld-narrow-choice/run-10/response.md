Updated the preview design for **2Q** cache eviction (Phase 2 — LLD):

- **`docs/high-level-design.md`**: Removed the stale `"Its eviction policy remains open."` sentence under `## Architecture` so the HLD remains coherent with the LLD.
- **`docs/intent/previews/previews-design.md`**: Replaced the open-policy text with the 2Q design (`A1in` FIFO probation queue targeting 25% / 3 GiB, `A1out` key-only FIFO ghost list, and `Am` LRU protected queue targeting 75% / 9 GiB within the 12 GiB JPEG budget), added the `Decisions & Alternatives` table, and added `Open Questions & Future Decisions` and `References`.

### Updated `docs/intent/previews/previews-design.md`

```markdown
---
parent: high-level-design
prefix: PREVIEW
---

# Previews Design

## Context

The worker renders one JPEG contact sheet per clip revision and renderer version. Long sequential screenings introduce many one-use sheets, while comparison sessions repeatedly revisit a smaller working set. The cache replacement policy must protect the comparison working set from being displaced by sequential scans without changing the external preview contract.

## Architecture

Expose `GET /internal/previews/{clip-id}/{revision}` with three outcomes: 200 and JPEG bytes, 202 and a job ticket with a two-second retry interval, or 404 for an unknown revision. This contract is fixed regardless of cache eviction policy.

Use a FIFO render queue with at most four active rendering jobs. Cache entries and all replacement-policy metadata belong exclusively to this worker. Other nodes do not access files, pin previews, inspect policy counters, or depend on entries remaining warm.

## Rendering and Deduplication

Resolve the immutable source revision before rendering. The cache key includes clip ID, revision, and renderer version. Concurrent misses for one key share a job ticket. Once rendering completes, subsequent requests can receive the JPEG directly. Failed jobs are removed from the deduplication map so a later request can retry.

## Private Cache

Cached JPEG data may occupy at most 12 GiB. Temporary render output is kept separately and removed on completion or failure. Eviction never deletes source footage or changes job-ticket semantics.

The cache uses **2Q** replacement, partitioning the 12 GiB JPEG budget between two data queues and tracking recently evicted first-use keys in a small metadata-only ghost list:

- **Probation queue (`A1in`, FIFO)**: Holds newly rendered sheets on first admission, targeting 25% of the cache budget (3 GiB). When `A1in` exceeds its target share, entries are evicted in FIFO order to make room, and their cache keys are recorded in `A1out`.
- **Ghost list (`A1out`, FIFO)**: Holds cache keys (no JPEG bytes) recently evicted from `A1in`, bounded by entry count (e.g., 2,000 keys). If a cache miss occurs for a key present in `A1out`, the key is removed from `A1out` and the newly rendered sheet is admitted directly to `Am` rather than `A1in`.
- **Protected queue (`Am`, LRU)**: Holds reused sheets, targeting 75% of the cache budget (9 GiB). Cache hits in `Am` refresh the entry to most-recently-used. Cache hits in `A1in` promote the entry to the most-recently-used position in `Am`.

Before admitting a completed sheet, the worker evicts enough existing entries so total cached JPEG bytes remain within 12 GiB:

- If `A1in` is at or above its 3 GiB target (or `Am` is empty), evict from `A1in` first (recording keys in `A1out`).
- Otherwise, evict the least-recently-used entry from `Am`.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|----------|--------|------------------------|-----------|
| Cache eviction policy | 2Q (two-queue replacement with `A1in`, `A1out`, and `Am`) | LRU; Frequency-based eviction with aging | Separates one-off screening scans (`A1in`) from reused comparison sheets (`Am`), preventing long screenings from flushing the active working set while keeping all replacement state private to the worker. LRU has lower bookkeeping and adapts fastest on project switches, but sequential scans evict active comparison sheets. Frequency-based eviction with aging retains popular clips, but counter-aging adds maintenance work and lags when editors switch projects. |

## Open Questions & Future Decisions

### Resolved
1. ✅ Cache eviction policy: 2Q selected to protect comparison working sets during sequential screenings.

### Deferred
1. Tune the `A1in` / `Am` byte split (initial 25% / 75%) and `A1out` ghost-list capacity based on pilot cache hit-rate telemetry.

## References

- `docs/high-level-design.md`
- `docs/intent/previews/previews-specs.md`
```

---

### LLD-Level Edge-Case Probe (for your triage)

1. **Worker restart / crash recovery:** What happens to existing cached JPEGs and orphaned temp files on disk when the worker restarts (rebuild `A1in`/`Am`, wipe, or reconcile)?
2. **Concurrent read vs. eviction:** What happens when a cached JPEG is evicted while a concurrent `200` response is still streaming its bytes?
3. **Concurrent job completions:** What happens when multiple of the 4 active render jobs finish simultaneously and run pre-admission eviction concurrently (needs serialization or capacity reservation to hold the 12 GiB ceiling)?
4. **Oversized entry:** What happens if a single rendered JPEG exceeds the 3 GiB `A1in` target or the 12 GiB total budget?
5. **`A1in` → `Am` promotion overflow:** Are the 3 GiB / 9 GiB queue targets soft (allowing `Am` to grow up to 12 GiB when `A1in` is small) or hard caps requiring immediate `Am` eviction on promotion?
6. **`A1out` check timing:** Is `A1out` membership checked/claimed when the miss starts rendering, or when the completed sheet is admitted (in case `A1out` turns over while the job is queued)?
7. **Eviction before polling client returns:** What happens if an admitted sheet in `A1in` is evicted before a polling client (that received `202`) returns?
8. **Unbounded render queue:** What happens if the FIFO render queue grows unboundedly while 4 jobs are active (any queue-depth cap or `503` backpressure)?
9. **Sync vs. async revision resolution & render failure shape:** Is unknown-revision resolution (`404`) synchronous on `GET`, and what happens if a job fails after returning `202`?
10. **Temp disk usage:** Is temporary render output bounded separately from the 12 GiB cache budget?

---

**Phase 2 stop:** Please review the updated `previews-design.md` and let me know:
1. Which of the probe items (1–10) should be resolved in the LLD now vs. deferred to `Open Questions & Future Decisions` (or out of scope for this change).
2. Whether you approve `previews-design.md` (with any edits) so I can proceed to **Phase 3** (updating `docs/intent/previews/previews-specs.md`).