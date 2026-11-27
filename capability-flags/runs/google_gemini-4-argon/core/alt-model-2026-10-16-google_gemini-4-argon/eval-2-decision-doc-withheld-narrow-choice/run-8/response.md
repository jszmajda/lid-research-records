I have updated `docs/intent/previews/previews-design.md` to specify 2Q cache replacement and recorded the choice, considered alternatives (LRU, frequency-based eviction with aging), and rationale in the `Decisions & Alternatives` table (and removed the stale "eviction policy remains open" note from `docs/high-level-design.md`). Because the eviction policy is strictly internal to the preview worker (`review-api` does not size around or depend on it), a table row in the LLD suffices without a separate standalone decision doc.

### Updated LLD (`docs/intent/previews/previews-design.md`)

```markdown
---
parent: high-level-design
prefix: PREVIEW
---

# Previews Design

## Context

The worker renders one JPEG contact sheet per clip revision and renderer version. Long screenings introduce many one-use sheets; comparison sessions repeatedly revisit a smaller working set. The mix varies by production, so no eviction policy is best for every observed workload.

## Architecture

Expose `GET /internal/previews/{clip-id}/{revision}` with three outcomes: 200 and JPEG bytes, 202 and a job ticket with a two-second retry interval, or 404 for an unknown revision. This contract is fixed regardless of cache eviction policy.

Use a FIFO render queue with at most four active rendering jobs. Cache entries and all replacement-policy metadata belong exclusively to this worker. Other nodes do not access files, pin previews, inspect policy counters, or depend on entries remaining warm.

## Rendering and Deduplication

Resolve the immutable source revision before rendering. The cache key includes clip ID, revision, and renderer version. Concurrent misses for one key share a job ticket. Once rendering completes, subsequent requests can receive the JPEG directly. Failed jobs are removed from the deduplication map so a later request can retry.

## Private Cache

Cached JPEG data may occupy at most 12 GiB. Before admitting a completed sheet, evict enough existing sheets to remain within that bound. Temporary render output is kept separately and removed on completion or failure. Eviction never deletes source footage or changes job-ticket semantics.

The cache uses 2Q replacement to isolate comparison working sets from one-off sequential screening scans. Newly admitted sheets enter a first-in, first-out probation queue (`A1in`), while ghost keys in `A1out` track recently evicted probation entries without retaining their JPEG bytes. A hit on a key in `A1out` (or a repeat hit according to the promotion rule) promotes the sheet into the main LRU queue (`Am`), protecting repeatedly compared sheets from being flushed by long linear scans. All queue pointers, ghost keys, and size-split parameters remain internal to the preview worker.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|----------|--------|------------------------|-----------|
| Cache eviction policy | 2Q (two-queue replacement) | Plain LRU; frequency-based eviction with aging | Editors alternate long sequential screenings with repeated comparisons of a small clip set. Plain LRU has minimal bookkeeping and adapts quickly when editors switch projects, but a sequential screening scan flushes the comparison working set. Frequency-based eviction with aging retains popular clips, but counter maintenance and decay add overhead and can hold yesterday's favorites across project switches. 2Q separates first-use entries from reused entries at the cost of maintaining two queues (`A1` and `Am`) and tuning their capacity split, keeping all complexity private to the preview worker without changing the HTTP contract, render queue, or 12 GiB disk budget. |
```

---

### Phase 2 LLD Edge-Case Probe

Before moving to Phase 3 (EARS specs), please review the updated LLD and indicate how you want to resolve or defer these internal gaps in `previews-design.md`:

1. **2Q queue sizing & ghost-list (`A1out`) variant**:
   - What capacity split should divide the 12 GiB budget between the FIFO probation queue (`A1in`) and the protected LRU queue (`Am`) (e.g., 25% `A1in` / 75% `Am`), and how should `A1out` be bounded (by entry count, e.g., 3,000 ghost keys, or by virtual byte size)?
   - Should a hit while an entry is *still resident* in `A1in` promote it immediately to `Am` (simplified 2Q), or should `A1in` strictly ignore hits and only promote when a key is re-requested and rendered while present in `A1out` (canonical 2Q, avoiding promotion from rapid double-fetches)?
2. **Oversized or variable-size sheet admission**:
   - Sheets vary in byte size (~2 MiB typical). When admitting a sheet into `A1in` or promoting to `Am`, does eviction target the sub-queue's soft byte target first and fall back to the other queue if needed to keep total JPEG bytes ≤ 12 GiB? What happens if a single rendered sheet exceeds the `A1in` budget (or 12 GiB)?
3. **Cache state & disk reconciliation on worker restart**:
   - On startup, does the preview worker wipe cached JPEGs and start with empty 2Q queues, scan the cache directory to seed `A1in`/`Am`, or persist 2Q metadata alongside the files?
4. **Render queue backpressure & failure response**:
   - Is the FIFO render queue unbounded behind the 4 active workers, or does it cap pending jobs?
   - When a render job fails and releases its deduplication ticket (`PREVIEW-005`), what status code does the next polling request receive if it arrives before/after failure (e.g., does the next request immediately re-enqueue and return 202 with a new job ticket, or can an error state be returned)?

Which of these would you like to settle in the LLD now versus record under `Open Questions & Future Decisions` (Deferred), and do you approve the LLD to proceed to Phase 3 (EARS specs)?