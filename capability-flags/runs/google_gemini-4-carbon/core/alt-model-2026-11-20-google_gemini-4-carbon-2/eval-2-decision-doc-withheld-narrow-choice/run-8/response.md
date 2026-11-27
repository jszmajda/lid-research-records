I have updated `docs/intent/previews/previews-design.md` with the 2Q cache design and a `Decisions & Alternatives` entry (and removed the stale `"Its eviction policy remains open."` sentence from `docs/high-level-design.md` so the HLD and LLD stay coherent while keeping replacement details private to `previews`). `docs/intent/review-api/` and `docs/intent/previews/previews-specs.md` are untouched pending your review of Phase 2.

### Updated `docs/intent/previews/previews-design.md`

```markdown
---
parent: high-level-design
prefix: PREVIEW
---

# Previews Design

## Context

The worker renders one JPEG contact sheet per clip revision and renderer version. Long sequential screenings introduce many one-use sheets, while comparison sessions repeatedly revisit a smaller working set. Cache replacement must protect active comparison sheets from one-pass screening scans without pinning clips permanently as editors move between projects.

## Architecture

Expose `GET /internal/previews/{clip-id}/{revision}` with three outcomes: 200 and JPEG bytes, 202 and a job ticket with a two-second retry interval, or 404 for an unknown revision. This contract is fixed regardless of cache eviction policy.

Use a FIFO render queue with at most four active rendering jobs. Cache entries and all replacement-policy metadata belong exclusively to this worker. Other nodes do not access files, pin previews, inspect replacement state, or depend on entries remaining warm.

## Rendering and Deduplication

Resolve the immutable source revision before enqueuing a render job, returning 404 immediately for unknown revisions. The cache key includes clip ID, revision, and renderer version. Concurrent misses for one key share a job ticket. Once rendering completes, subsequent requests receive the JPEG directly. Failed jobs are removed from the deduplication map so a later request can retry.

## Private Cache

Cached JPEG data may occupy at most 12 GiB, managed with a private 2Q eviction policy that separates first-use sheets from reused sheets across a configurable size split:

- **Probationary queue (FIFO)**: Newly rendered sheets enter the probationary queue on admission. Sequential screening scans cycle one-use sheets through this queue without displacing reused sheets.
- **Protected queue (LRU)**: Sheets requested again after initial admission promote to the protected queue, where cache hits refresh recency so active comparison sets stay warm and stale sets age out when editors switch projects.

Before admitting a completed sheet, the worker evicts enough cached sheets to keep total cached JPEG bytes within 12 GiB and within the configured queue targets. Temporary render output is stored outside the 12 GiB cache budget and removed on completion or failure. Eviction deletes only cached JPEG files and private queue metadata; it never deletes source footage or alters pending job-ticket behavior.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|----------|--------|------------------------|-----------|
| Private cache eviction policy | 2Q (probationary first-use FIFO + protected reused LRU) | Single-queue LRU; frequency-based eviction with aging | Sequential screenings can flush an entire single-queue LRU cache, while aged frequency counters add ongoing maintenance and can retain stale favorites after a project switch. 2Q isolates one-pass screening traffic in the probationary queue and ages out inactive comparison sheets via LRU, while keeping all replacement bookkeeping private to the preview worker. |

## Open Questions & Future Decisions

### Deferred

1. Queue size split: initial byte-budget partition of the 12 GiB cap between the probationary and protected queues, and whether an under-filled queue shares unused capacity before eviction begins.
2. Ghost eviction history: whether promotion relies solely on hits while resident in the probationary queue (simplified two-queue 2Q) or includes a bounded key-only ghost FIFO (`A1out`) so sheets revisited after probationary eviction promote to the protected queue on re-render.
```

---

### Phase 2 LLD Edge-Case Probe & Open Choices

Before moving to Phase 3 (`previews-specs.md`), please review the LLD and let me know which of these internal gaps and 2Q choices you want specified in `previews-design.md` now versus deferred under `Open Questions & Future Decisions`:

1. **Follow-up poll after `202` vs. 2Q promotion**: On a cache miss, the caller gets `202` and polls `GET /internal/previews/{clip-id}/{revision}` two seconds later once the render lands in the probationary queue. If that first `200` poll counts as "requested again after initial admission," every one-off screening miss will immediately promote to the protected queue and defeat scan isolation. Should the first `200` delivery after admission leave the entry in the probationary queue (or should promotion require classic 2Q's `A1out` ghost-queue hit rather than promoting on probationary hits)?
2. **Queue size split and ghost history (`Open Questions #1–2`)**: Do you want to fix an initial byte-budget split (for example, 25% probationary / 75% protected, and soft vs. hard caps when one queue has spare space) and choose between two resident queues vs. adding a bounded `A1out` ghost key queue now, or keep either deferred?
3. **Protected-queue overflow on promotion**: When promoting a sheet into the protected LRU queue pushes the protected queue past its byte target, should the protected queue evict its LRU sheet directly from disk or demote it back to the probationary queue?
4. **Render failure & non-404 error outcome**: Because failed jobs leave the deduplication map for retry and only `200`, `202`, and `404` are currently named on `GET /internal/previews/{clip-id}/{revision}`, a deterministic render failure (e.g., unreadable source clip) will cause polling callers to loop indefinitely on `202` -> fail -> re-enqueue. Should deterministic or repeated render failures surface a `5xx` outcome, or stay transparent retries for the pilot?
5. **In-flight cache reads vs. concurrent eviction**: When a `GET` handler is streaming a cached JPEG while one of the four render slots completes and evicts that entry, how should active reads be protected (e.g., unlink-while-open file descriptor semantics or reference counting before deletion)?
6. **Worker restart & renderer-version upgrades**: Across a worker restart or `renderer version` bump, should existing on-disk cache files (and any orphaned temp files) be purged, or scanned to rebuild queue state and reclaim stale-version JPEGs within the 12 GiB cap?
7. **Waiting FIFO render queue bound**: Active renders are capped at four, while waiting misses sit in a FIFO queue. Should the waiting queue remain unbounded for the 24-editor pilot, or reject excess queued misses when saturated?

How would you like to triage items 1–7, and once adjusted, do you approve `previews-design.md` to proceed to Phase 3 (updating `previews-specs.md`)?