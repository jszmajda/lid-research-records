`docs/intent/previews/previews-design.md` is updated with the 2Q cache replacement design and a `Decisions & Alternatives` row (because the replacement policy stays private to `previews` and leaves `review-api` and the HTTP/queue contracts unchanged, it is recorded as an LLD table row rather than a standalone decision doc). I also removed `"Its eviction policy remains open."` from `docs/high-level-design.md` so the HLD stays coherent with the settled LLD.

### Updated `docs/intent/previews/previews-design.md`

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

Cached JPEG data may occupy at most 12 GiB. Temporary render output is kept separately and removed on completion or failure. Eviction deletes only cached JPEG data and private queue metadata; it never deletes source footage or changes job-ticket semantics.

Cache replacement uses a worker-private 2Q policy with two queues keyed by clip ID, revision, and renderer version:

- **Probationary queue (FIFO)**: Newly rendered sheets enter at the head of the probationary queue on cache admission. Single-use sheets from sequential screenings age toward the tail and are evicted in FIFO order without entering the protected set.
- **Protected queue (LRU)**: When a request hits an entry in the probationary queue, the worker promotes it to the most-recently-used head of the protected queue. Subsequent hits on a protected entry refresh its position at the head of the protected queue.

A configurable probationary target share partitions the 12 GiB cache budget between the two queues while allowing either queue to use idle space until total cached JPEG data reaches 12 GiB. Before admitting a completed sheet whose size would push total cached JPEG bytes past 12 GiB, the worker evicts entries until space is available: if the probationary queue is non-empty and either admitting the sheet would leave probationary bytes above the probationary target share or the protected queue is empty, evict from the tail of the probationary FIFO queue; otherwise evict the least-recently-used entry from the tail of the protected LRU queue.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|----------|--------|------------------------|-----------|
| Cache eviction policy | 2Q (worker-private probationary FIFO queue for first-use sheets and protected LRU queue for reused sheets) | Single-queue LRU; frequency-based eviction with aging | Editors alternate long sequential screenings of single-use sheets with repeated comparisons of a small clip set. Single-queue LRU has minimal bookkeeping and adapts quickly when editors switch projects, but a long screening scan evicts active comparison sheets. Frequency-based eviction with aging retains popular clips, but adds counter and decay maintenance and can hold stale favorites after a project switch. 2Q isolates one-off screening scans in the probationary queue while keeping reused comparison sheets warm in the protected queue, with all replacement tracking kept private to the preview worker. |

## Open Questions & Future Decisions

### Deferred
1. Initial probationary target share of the 12 GiB cache budget.
```

---

### Phase 2 LLD Edge-Case Probe

Before moving to Phase 3 (`previews-specs.md`), please review the LLD above and let me know which of these internal gaps/choices to resolve in `previews-design.md` now versus defer under `Open Questions & Future Decisions`:

1. **First `200` delivery after `202` vs. 2Q promotion**: On a cold miss, the caller receives `202` and retries ~2 seconds later to fetch the rendered sheet. If that initial `200` fetch counts as a probationary hit, every single-use screening sheet will immediately promote to the protected queue on its completion poll. Should a newly admitted probationary entry not promote on its initial `200` delivery (promoting only on a subsequent hit), and if multiple callers shared the `202` ticket, do their completion polls count as one initial delivery or as reuse?
2. **Queue size split and ghost history (`A1out`)**: Do you want to specify a default probationary target share now (e.g., 25% / 3 GiB probationary, 75% / 9 GiB protected) or keep it deferred for tuning? Also, should replacement strictly use the two resident queues above, or also keep a bounded ghost-key ring (`A1out`, keys only) so a clip evicted from probationary and requested again soon promotes on re-admission?
3. **Deterministic render failures vs. the `200`/`202`/`404` contract**: Removing a failed job from the deduplication map allows retry, while the endpoint specifies three outcomes (`200`, `202`, `404`). What happens when a corrupt clip fails rendering repeatedly as a client polls every two seconds — re-enqueue and return `202` each time, or return an error status (e.g., `500`/`502`)?
4. **Completion/admission atomicity and concurrent `200` reads during eviction**: Should the LLD state that cache admission and deduplication-map removal happen atomically (so a concurrent `GET` neither enqueues a duplicate job nor gets a stale `202`), and that evicting an entry never truncates an already in-flight `200` response stream?
5. **Worker restart and renderer-version rollover**: On worker startup, is the on-disk cache wiped/rebuilt as cold probationary entries or persisted with queue state, and how are leftover files from prior renderer versions accounted for or purged within the 12 GiB cap?
6. **Render queue backpressure and `202` wire format**: Is the FIFO render queue unbounded or capped (with an overload status when full), and should this LLD specify the exact `202` response schema (`Retry-After: 2` header and job-ticket body)?

How would you like to triage items 1–6, and do you approve `previews-design.md` (with those updates) to proceed to Phase 3 (EARS specs)?