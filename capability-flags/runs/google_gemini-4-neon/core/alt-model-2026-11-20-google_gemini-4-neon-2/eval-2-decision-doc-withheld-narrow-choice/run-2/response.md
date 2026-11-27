Updated `docs/intent/previews/previews-design.md` with the 2Q eviction policy and its `Decisions & Alternatives` entry, and removed the stale "Its eviction policy remains open." note from `docs/high-level-design.md`.

### Updated `docs/intent/previews/previews-design.md`

```markdown
---
parent: high-level-design
prefix: PREVIEW
---

# Previews Design

## Context

The worker renders one JPEG contact sheet per clip revision and renderer version. Long sequential screenings introduce many one-use sheets, while comparison sessions repeatedly revisit a smaller working set. Cache replacement must protect that reused working set without relying on external hints or pinning.

## Architecture

Expose `GET /internal/previews/{clip-id}/{revision}` with three outcomes: 200 and JPEG bytes, 202 and a job ticket with a two-second retry interval, or 404 for an unknown revision. This contract is fixed regardless of cache eviction policy.

Use a FIFO render queue with at most four active rendering jobs. Cache entries and all replacement-policy metadata belong exclusively to this worker. Other nodes do not access files, pin previews, inspect policy counters, or depend on entries remaining warm.

## Rendering and Deduplication

Resolve the immutable source revision before rendering. The cache key includes clip ID, revision, and renderer version. Concurrent misses for one key share a job ticket. Once rendering completes, subsequent requests can receive the JPEG directly. Failed jobs are removed from the deduplication map so a later request can retry.

## Private Cache

Cached JPEG data may occupy at most 12 GiB. Before admitting a completed sheet, evict enough existing sheets to remain within that bound. Temporary render output is kept separately and removed on completion or failure. Eviction never deletes source footage or changes job-ticket semantics.

### 2Q Eviction Policy

The worker manages the 12 GiB disk budget with a 2Q replacement policy composed of two resident queues and one metadata-only ghost queue:

- **Probation queue (`A1in`, FIFO)**: Newly rendered sheets that are not in `A1out` are admitted here. `A1in` holds first-use sheets from sequential screenings so they do not displace reused comparison sheets. Its target byte budget is a worker-private configuration parameter (initial default: 25% of the 12 GiB cache, 3 GiB). Evicting an entry from `A1in` deletes its JPEG from disk and records its cache key in `A1out`.
- **Ghost queue (`A1out`, FIFO, metadata only)**: Records keys recently evicted from `A1in` without storing JPEG bytes, bounded by entry count (initial default: 3,000 keys, roughly half the nominal 6,000-sheet capacity at 2 MiB per sheet). When a cache miss occurs for a key present in `A1out`, the entry is removed from `A1out` and the newly rendered sheet is admitted directly into `Am`.
- **Main queue (`Am`, LRU)**: Holds sheets that have demonstrated reuse. Its target byte budget is the remainder of the 12 GiB cache (initial default: 75%, 9 GiB). Cache hits on entries in `Am` move the entry to the most-recently-used position. Evicting from `Am` deletes the least-recently-used JPEG from disk without recording the key in `A1out`.

When admitting a sheet would exceed the 12 GiB limit, the worker evicts from `A1in` while `A1in` exceeds its byte budget, and otherwise evicts from `Am` (falling back to the other resident queue if the preferred queue is empty) until the new sheet fits within 12 GiB. Hits on entries currently resident in `A1in` serve the JPEG without moving the entry; promotion to `Am` happens only when a key evicted from `A1in` is requested again while still tracked in `A1out`.

All queue structures, eviction counters, and split parameters remain private to the preview worker.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|----------|--------|------------------------|-----------|
| Cache eviction policy | 2Q (`A1in` FIFO probation queue, `A1out` metadata-only ghost queue, `Am` LRU main queue) | LRU; frequency-based eviction with aging | Editors alternate long sequential screenings with repeated comparison of a smaller set of clips. 2Q isolates one-off screening sheets in `A1in` so sequential scans do not evict reused comparison sheets from `Am`. LRU has lower bookkeeping cost and adapts quickly on project switches, but a long sequential screening flushes the comparison working set. Frequency-based eviction with aging retains popular clips, but counter maintenance and aging add work and can keep stale favorites cached after editors switch projects. 2Q accepts two resident queues, a ghost queue, and a tunable size split to protect comparison sheets while keeping all replacement state private to the preview worker. |

## Open Questions & Future Decisions

### Deferred

1. Tune the `A1in` / `Am` byte-budget split and `A1out` entry limit using pilot cache hit-rate observations (starting from 25% / 75% and 3,000 ghost entries).
2. Decide whether 2Q queue metadata persists across worker restarts or rebuilds cold from disk on startup.
```

### Phase 2 LLD Edge-Case Probe

Please triage which of these gaps to specify in `previews-design.md` now vs. defer as open questions:

1. **`A1out` check timing across async rendering**: When a miss matches `A1out`, is `A1out` checked and popped at miss/enqueue time or at admission time? (If popped at enqueue and the render fails, a retry loses ghost status; if checked at admission, `A1out` may have evicted the key while queued.)
2. **Render failure visibility vs. infinite polling**: Since failed jobs are removed from the deduplication map and the API only defines `200`, `202`, and `404`, what happens when a client polling after `202` hits a repeatedly failing render — does it re-enqueue with `202` indefinitely, or should there be a failure status/shape?
3. **Render queue bounds and stuck jobs**: Is the FIFO render queue bounded (and if so, what error status is returned on overflow), and is there a timeout/cancellation transition for a hung render job?
4. **Read-vs-evict concurrency and simultaneous completions**: What happens if a `GET` resolves a cache hit just before a concurrent completion evicts and deletes that file? And what serialization invariant governs eviction, disk placement, cache indexing, and deduplication removal when multiple of the 4 active renders finish together?
5. **`A1in` budget check boundary and admission failures**: When deciding whether to evict from `A1in` vs. `Am`, is `A1in`'s byte budget checked before or including the incoming sheet? And what happens if a single rendered sheet exceeds 12 GiB or disk placement fails?
6. **`202` response contract and index-vs-disk divergence**: What is the concrete `202` payload/header shape (e.g., `Retry-After` header vs. JSON body field)? And if a key is present in `A1in`/`Am` metadata but missing or unreadable on disk, should it be treated as a cache miss and evicted from metadata?
7. **Orphaned temporary files and renderer-version upgrades**: How are leftover temp files cleaned up after a worker crash (and is temp storage bounded separately from the 12 GiB cache), and after a renderer upgrade do unreachable old-version sheets sit in `Am` until naturally evicted or get purged?

Let me know which gaps you want folded into the LLD vs. deferred, and whether you approve Phase 2 so we can move to Phase 3 (updating `docs/intent/previews/previews-specs.md`).