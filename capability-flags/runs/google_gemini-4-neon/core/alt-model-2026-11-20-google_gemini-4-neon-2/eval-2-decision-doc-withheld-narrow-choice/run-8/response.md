I've updated `docs/intent/previews/previews-design.md` with the 2Q cache replacement design and recorded the choice (along with the LRU and aged-frequency alternatives) in a `## Decisions & Alternatives` table. I also removed the now-stale "Its eviction policy remains open." note from `docs/high-level-design.md` to keep the HLD coherent with the LLD.

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

Cached JPEG data may occupy at most 12 GiB. Before admitting a completed sheet, evict enough existing sheets to remain within that bound. Temporary render output is kept separately and removed on completion or failure. Eviction never deletes source footage or changes job-ticket semantics.

The cache uses a 2Q replacement policy to isolate one-off screening scans from repeatedly compared sheets:

- **Probationary queue (`A1in`, FIFO):** Newly rendered sheets are admitted here on first render. Entries evicted from `A1in` are removed from disk; their keys may be retained in a bounded ghost history (`A1out`) so a sheet re-requested shortly after eviction is recognized as reused.
- **Protected queue (`Am`, LRU):** Sheets that are accessed again (on a cache hit in `A1in`, or on re-render of a key present in `A1out`) are promoted to `Am`, where hits refresh recency and evictions drop the least recently used sheet.
- **Byte-bounded partitioning:** `A1in` and `Am` partition the 12 GiB JPEG budget according to a configurable size split. Because individual sheets vary in byte size, admission checks and eviction operate on byte totals rather than entry counts.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|----------|--------|------------------------|-----------|
| Cache eviction policy | 2Q | LRU; frequency-based eviction with aging | Protects repeatedly compared contact sheets from being flushed by long sequential screenings, accepting extra queue bookkeeping and a tunable queue-size split. LRU has lower bookkeeping and adapts quickly on project switches but is vulnerable to sequential scans. Aged frequency counts retain popular clips but add counter maintenance and can retain stale favorites after a project switch. All replacement state remains private to the preview worker without changing the HTTP interface, render queue, or 12 GiB disk budget. |
```

### Phase 2 LLD Edge-Case Probe

Before moving to Phase 3 (EARS specs), please review the LLD above and triage which of these gaps to specify in `previews-design.md` now vs. defer as open questions:

1. **Hard vs. soft byte partitioning between `A1in` and `Am`:** What happens when `A1in` fills its configured byte split while `Am` has unused capacity (or vice versa) — must `A1in` evict its own entries at its split limit, or can it borrow unused space up to 12 GiB? When an `A1in` hit promotes a sheet into a full `Am`, does `Am` evict synchronously on the `GET` read path before returning `200`?
2. **Oversized sheets vs. partition bounds:** What happens if a single rendered JPEG exceeds `A1in`'s byte partition, `Am`'s partition on promotion, or the 12 GiB total budget — is it bypassed (served once without caching) or rejected?
3. **`A1out` ghost-list bounds and check timing:** What bounds `A1out` (entry count, metadata bytes, or evicted JPEG bytes), what evicts from it, and are entries evicted from `Am` ever added to `A1out`? If a key is in `A1out` when a miss is enqueued but evicted from `A1out` before rendering finishes, is `A1out` checked at enqueue time (admitting to `Am`) or at completion time (admitting to `A1in`)?
4. **Eviction racing with active `GET` reads:** What happens when a cached JPEG is selected for eviction while `GET` requests are actively streaming its bytes — skip in-use entries, unlink while open (allowing temporary disk overshoot until descriptors close), or abort in-flight reads?
5. **Worker restart and stale disk artifacts:** On restart or crash recovery, is 2Q metadata (`A1in`, `Am`, `A1out`) persisted, dropped with a full cache purge, or reconstructed from disk (and into which queue)? How are orphaned temporary files and sheets from older renderer versions reclaimed?
6. **Render failures and retry loops:** Since failed jobs are removed from the deduplication map and only `200`/`202`/`404` are defined, does a client polling every two seconds silently re-enqueue a permanently failing render (e.g., corrupt footage) indefinitely, or should there be an error status or retry limit?
7. **Render queue saturation and admission failure:** Is the FIFO render queue unbounded when misses outpace the four active slots, or is there a max depth and rejection status? And if cache admission (eviction or moving the temp file) fails after rendering succeeds, how does that interact with removing the job from the deduplication map?

Reply with any edits to the LLD and your triage on items 1–7, and let me know when you're ready to proceed to Phase 3 (EARS specs).