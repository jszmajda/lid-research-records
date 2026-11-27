`docs/intent/previews/previews-design.md` is updated with the 2Q replacement design and a `Decisions & Alternatives` entry (and the stale `"Its eviction policy remains open."` note is removed from `docs/high-level-design.md`; `review-api` is unchanged since replacement tracking stays private to the preview worker).

### Updated `docs/intent/previews/previews-design.md`

```markdown
---
parent: high-level-design
prefix: PREVIEW
---

# Previews Design

## Context

The worker renders one JPEG contact sheet per clip revision and renderer version. Long screenings introduce many one-use sheets; comparison sessions repeatedly revisit a smaller working set.

## Architecture

Expose `GET /internal/previews/{clip-id}/{revision}` with three outcomes: 200 and JPEG bytes, 202 and a job ticket with a two-second retry interval, or 404 for an unknown revision. This contract is fixed regardless of cache eviction policy.

Use a FIFO render queue with at most four active rendering jobs. Cache entries and all replacement-policy metadata belong exclusively to this worker. Other nodes do not access files, pin previews, inspect policy counters, or depend on entries remaining warm.

## Rendering and Deduplication

Resolve the immutable source revision before rendering. The cache key includes clip ID, revision, and renderer version. Concurrent misses for one key share a job ticket. Once rendering completes, subsequent requests can receive the JPEG directly. Failed jobs are removed from the deduplication map so a later request can retry.

## Private Cache

Cached JPEG data may occupy at most 12 GiB. Temporary render output is kept separately and removed on completion or failure. Eviction never deletes source footage or changes job-ticket semantics.

Replacement uses 2Q within the 12 GiB budget to isolate sequential screening traffic from active comparison sets:

- **Probationary queue (FIFO)**: Newly rendered contact sheets enter the probationary queue on admission. Sheets viewed only once during a long screening age out in arrival order without displacing reused comparison sheets.
- **Protected queue (LRU)**: Sheets revisited across comparison views reside in the protected queue ordered by recency of access. Cache hits on protected entries move them to the most-recently-used position.

Before admitting a completed sheet that would push total cached JPEG data past 12 GiB, the worker evicts existing sheets until the incoming sheet fits within 12 GiB—evicting from the head of the probationary queue when admitting the sheet would push the probationary queue past its target byte share (or when the protected queue is empty), and otherwise evicting the least-recently-used sheet from the protected queue.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Cache eviction policy | 2Q replacement | Single-queue LRU; frequency-based eviction with aging | Protects repeatedly compared contact sheets during long sequential screenings while keeping replacement bookkeeping private to the preview worker. Single-queue LRU has lower bookkeeping cost and adapts quickly when editors switch projects, but a long sequential screening can evict active comparison sheets. Frequency-based eviction with aging retains popular clips across scans, but adds counter and aging maintenance and can retain stale favorites after project switches. 2Q isolates one-off scan entries at the cost of maintaining two queues and tuning their size split, without changing the HTTP interface, render queue, or 12 GiB cache bound. |

## Open Questions & Future Decisions

### Deferred

1. Target byte split of the 12 GiB budget between the probationary and protected queues.
2. Exact reuse promotion trigger under the `202` retry flow—whether initial post-render `200` delivery is distinguished from a subsequent viewing in the probationary queue, and whether keys evicted from the probationary queue are tracked in a bounded ghost FIFO (`A1out`) so re-requested clips enter the protected queue on re-render.
```

---

### Phase 2 LLD Edge-Case Probe

Before moving to Phase 3 (`docs/intent/previews/previews-specs.md`), please review the updated LLD and tell me which of these internal gaps you want settled in `previews-design.md` now versus left deferred:

1. **First post-render `200` poll vs. reuse promotion**: Because a cache miss returns `202` and the caller polls two seconds later to fetch the JPEG for the first time, promoting on the very first `GET` hit in the probationary queue would promote every one-off screening clip. Should promotion use:
   - classic 2Q with a bounded ghost key FIFO (`A1out`) for entries evicted from probationary (with hits in probationary serving `200` in place, or promoting only after the initial delivery), or
   - two resident queues with an initial-delivery flag (first `200` marks a probationary sheet delivered; a subsequent `GET` promotes it to protected; no `A1out` ghost history)?
2. **Queue size split and empty/under-filled sharing**: Do you want to fix a concrete initial target split of the 12 GiB budget now (e.g., 3 GiB probationary / 9 GiB protected) or keep it configurable/deferred, and can the protected queue grow past its share when the probationary queue is under-filled as long as total cached data stays within 12 GiB?
3. **Render-to-cache handoff ordering**: Should the LLD state explicitly that completed sheets become visible in the cache before their key leaves the deduplication map (so a concurrent two-second retry cannot miss both and enqueue a duplicate render)?
4. **Render failures and the `{200, 202, 404}` outcome set**: When rendering fails for a valid clip revision (e.g., corrupt source media or local disk error), should `GET` have a `5xx` failure outcome or continue treating subsequent polls as fresh `202` retries? Also, does source-revision resolution (`404`) always run synchronously before returning `202`?
5. **Eviction during in-flight `200` streaming or before initial retry**: If an entry is selected for eviction while a response is streaming its bytes, how is the active read protected without exceeding 12 GiB on disk? And if burst traffic evicts a probationary sheet before the waiting caller's two-second poll, is returning a new `202` job ticket the intended behavior?
6. **Worker restart and renderer-version upgrades**: Is the 12 GiB cache volatile or persisted across restarts—and if persisted, how are orphaned temp files cleaned up and older `renderer version` entries aged out?

How would you like to triage items 1–6, and once adjusted (if needed), do you approve proceeding to Phase 3 (EARS specs)?