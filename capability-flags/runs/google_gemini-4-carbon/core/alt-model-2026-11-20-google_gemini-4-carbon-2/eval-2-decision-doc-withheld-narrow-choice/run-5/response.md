I updated `docs/intent/previews/previews-design.md` around the 2Q cache design, recorded the eviction-policy choice in its `Decisions & Alternatives` table, and removed the stale `"Its eviction policy remains open."` sentence from `docs/high-level-design.md` so the HLD and LLD stay coherent while keeping replacement bookkeeping private to `previews`.

### Updated `docs/intent/previews/previews-design.md`

```markdown
---
parent: high-level-design
prefix: PREVIEW
---

# Previews Design

## Context

The preview worker renders one JPEG contact sheet per immutable clip revision and renderer version. Documentary editors alternate long sequential screenings that view many clips once with comparison sessions that repeatedly revisit a smaller working set, and shift working sets when switching projects. A typical sheet is about 2 MiB and takes roughly 450 ms to render, so the worker keeps a bounded private cache to serve repeated views quickly while preventing sequential scans from evicting active comparison sheets.

## Architecture

Expose `GET /internal/previews/{clip-id}/{revision}` with three outcomes:

| Outcome | Status | Response |
|---------|--------|----------|
| Cached preview ready | `200` | Contact-sheet JPEG bytes |
| Render queued or in progress | `202` | Job ticket with a two-second retry interval |
| Unknown clip revision | `404` | Not-found error without enqueuing a render job |

Use a FIFO render queue with at most four active rendering jobs. Cache files, disk paths, and all replacement-policy metadata belong exclusively to this worker. Other nodes do not access cache files, pin previews, inspect queue or eviction state, or depend on entries remaining warm.

## Rendering and Deduplication

Resolve the immutable source revision before enqueuing work; unknown revisions return `404` immediately. The preview key combines `clip-id`, `revision`, and `renderer-version` so renderer changes never serve stale sheets.

Concurrent cache misses for the same preview key share one pending render job and receive `202` with the same job ticket and two-second retry interval. Temporary render output is stored outside the admitted cache budget and removed on completion or failure. Once rendering succeeds and the completed sheet is admitted to the cache, the preview key leaves the deduplication map and subsequent requests receive `200` with the JPEG directly. Failed jobs are removed from the deduplication map without admitting partial output so a later request can enqueue a new render job.

## Private Cache

Cached JPEG data occupies at most 12 GiB in aggregate. Before admitting a completed sheet that would exceed 12 GiB, the worker evicts enough existing sheets to remain within that bound. Eviction never deletes source footage or changes job-ticket semantics.

The worker tracks cached sheets with a private 2Q replacement policy divided by a configurable byte-budget split within the 12 GiB limit:

- **Probationary queue (first-use, FIFO)**: Newly rendered contact sheets enter the probationary queue on cache admission. Single-use sheets from sequential screenings stay in this queue and age out in FIFO order.
- **Protected queue (reused, LRU)**: Cached contact sheets requested again promote to the protected queue, which tracks recency of access. Active comparison sheets stay warm in the protected queue while screening traffic cycles through the probationary queue, and older comparison sets age out naturally when editors switch projects.

When admitting a completed sheet would push total cached JPEG bytes above 12 GiB, the worker evicts existing sheets until the incoming sheet fits: evicting from the front of the probationary FIFO queue whenever the incoming sheet would leave the probationary queue above its target byte share (or when the protected queue is empty), and otherwise evicting least-recently-used sheets from the protected queue.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|----------|--------|-------------------------|-----------|
| Cache eviction policy | 2Q (probationary FIFO queue for first-use sheets and protected LRU queue for reused sheets) | Single-queue LRU; frequency-based eviction with aging | Single-queue LRU has low bookkeeping cost and adapts quickly when editors switch projects, but long sequential screenings evict active comparison sheets. Frequency-based eviction with aging retains popular clips, but adds ongoing counter maintenance and decay work and can hold stale favorites after project switches. 2Q isolates one-off screening scans in the probationary FIFO queue while protecting reused comparison sheets in an LRU queue that adapts when working sets shift, keeping all replacement bookkeeping private to the preview worker. |

## Open Questions & Future Decisions

### Deferred

1. **2Q queue byte-budget split**: Tune the target share between the probationary FIFO queue and the protected LRU queue within the 12 GiB cap against pilot screening and comparison workloads.

## References

- `docs/high-level-design.md`
- `docs/intent/previews/previews-specs.md`
```

---

### Phase 2 LLD Edge-Case Probe

Before moving to Phase 3 (`previews-specs.md`), please review the LLD above and triage which of these component-internal gaps to specify in `previews-design.md` now versus defer under `Open Questions & Future Decisions`:

1. **Initial `202` -> `200` poll vs. probationary promotion**: When a miss triggers a render job (`202`), the completed sheet enters the probationary queue before any caller has received `200`. When the waiting caller (or *N* coalesced callers sharing that job ticket) polls 2 seconds later to collect the JPEG, does that initial delivery stay in the probationary queue rather than counting as a reuse hit that immediately promotes every newly rendered sheet into the protected queue?
2. **Two resident queues vs. evicted-key ghost history (`A1out`)**: Should the cache use strictly the two resident queues as drafted (a sheet must be hit again while still resident in the probationary queue to promote), or also keep a bounded key-only ghost FIFO of recently evicted probationary keys so clips revisited after aging out of the probationary queue promote on re-render?
3. **Permanent render failures (corrupt/unreadable source revision)**: Because failed jobs leave the deduplication map so later requests can retry, what happens when a valid clip revision repeatedly fails to render — should retries continue receiving `202` and re-enqueuing indefinitely, or return an error status / short failure cooldown?
4. **Worker startup and restart state**: When the worker restarts with existing cached JPEGs (including older `renderer-version` files) or leftover temporary render files on disk, should it purge temporary files and start with a cold/re-indexed probationary cache, or persist 2Q queue metadata across restarts?
5. **In-flight `200` reads during eviction and oversized sheets**: What happens if an entry selected for eviction is actively being streamed to a `200` caller, or if a single anomalously large contact sheet exceeds the probationary byte share?
6. **FIFO render queue backpressure**: Beyond the cap of four active render jobs, is the waiting FIFO render queue unbounded during heavy screening bursts, or bounded with load-shedding?
7. **Internal HTTP wire details and storage errors**: Should the LLD specify exact headers/body fields for `200` (`Content-Type`), `202` (`Retry-After` header vs. JSON job-ticket payload), `404`, and `5xx` responses when source-revision lookup or cache disk I/O fails?

Let me know any edits to the LLD and how you want items 1–7 triaged, or approve to proceed to Phase 3 (updating `docs/intent/previews/previews-specs.md`).