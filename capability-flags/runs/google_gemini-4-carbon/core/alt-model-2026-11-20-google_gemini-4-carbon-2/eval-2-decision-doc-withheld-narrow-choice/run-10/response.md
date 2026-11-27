I updated `docs/intent/previews/previews-design.md` with the 2Q cache design and recorded the policy choice in `Decisions & Alternatives` (and removed the stale *"Its eviction policy remains open."* sentence from `docs/high-level-design.md` to keep the HLD and LLD coherent).

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

Cached JPEG data may occupy at most 12 GiB. Replacement uses a private 2Q policy to isolate one-off screening scans from repeatedly viewed comparison sheets:

- **Probationary queue (`A1`)**: A FIFO queue that admits newly rendered sheets on first completion. Sequential screenings turn over this queue without evicting established comparison sheets.
- **Protected queue (`Am`)**: An LRU queue that holds reused sheets. Accessing an entry in `Am` moves it to the most-recently-used position.

Before admitting a completed sheet, the worker evicts enough existing sheets to keep total cached JPEG bytes within 12 GiB: when `A1` exceeds its target share (or `Am` is empty), eviction removes the oldest entries from `A1`; otherwise it removes the least-recently-used entries from `Am`. Temporary render output is stored separately outside the 12 GiB budget and removed on completion or failure. Eviction removes only cached JPEG files and private queue metadata; it never deletes source footage or alters job-ticket semantics.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|----------|--------|-------------------------|-----------|
| Cache eviction policy | 2Q (probationary FIFO queue + protected LRU queue) | Single-queue LRU; frequency-based eviction with aging | Protects repeatedly compared contact sheets during long sequential screenings while adapting faster when editors switch projects than aged frequency counters. Replacement queues and split tuning stay private to the preview worker without changing the HTTP contract, render queue, or 12 GiB cap. |

## Open Questions & Future Decisions

### Deferred

1. **Queue-size split**: Target byte allocation between the probationary queue (`A1`) and protected queue (`Am`) within the 12 GiB cap, and whether `A1` may borrow unused space when `Am` is under-full.
2. **Promotion and ghost history**: Whether reuse is detected via a cache hit while still resident in `A1` (two-queue resident 2Q) or via a bounded ghost FIFO (`A1out`) of recently evicted keys (full 2Q), or both.

## References

- High-level design: `docs/high-level-design.md`
- Specifications: `docs/intent/previews/previews-specs.md`
```

---

### Phase 2 LLD Edge-Case Probe

Please review the LLD above and let me know which of these gaps you want settled in `previews-design.md` now versus kept under `Deferred`:

1. **Promotion mechanics & pending-poll counting** *(Deferred #2)*: Does an entry promote to `Am` on a resident cache hit in `A1` (two resident queues), via a bounded ghost key FIFO `A1out` when re-requested after eviction from `A1` (full 2Q), or both? Also, when callers poll a pending `202` ticket before first admission completes, should the completed sheet still enter `A1` as first-use (counting reuse only on hits after admission)?
2. **Queue-size split & unused capacity** *(Deferred #1)*: Do you want to fix an initial split now (e.g., 25% `A1` / 75% `Am`, plus a ghost-key cap if using `A1out`) or leave tuning deferred? While `Am` is under-full, may `A1` use unused space up to the 12 GiB total cap before evicting?
3. **Eviction spillover & oversized sheets**: What happens if the chosen eviction queue (`Am` or `A1`) has fewer bytes than needed to admit a completed sheet — does eviction spill into the other resident queue, and is there a maximum single-sheet JPEG size bound?
4. **Revision-lookup timing & worker error responses**: Is clip/revision existence verified synchronously before returning `202`/`404` (and skipped on a warm cache hit), and what responses apply to internal failures outside `200`/`202`/`404` (such as catalog/storage errors, render timeouts, or bounded waiting-queue overflow)?
5. **`202` wire format & post-failure retries**: Should the LLD specify the `202` wire shape (`Retry-After: 2` header and JSON ticket body), and when a caller retries after a render job fails and leaves the deduplication map, should that poll immediately enqueue a new job (`202`) or surface an error?
6. **Admission/eviction concurrency & startup recovery**: How are in-flight `200` file reads protected against concurrent eviction, does a key remain in the deduplication map until cache admission finishes, and on worker startup (or a renderer-version bump) are existing on-disk files adopted or purged?

Let me know your edits or triage on items 1–6, and confirm when ready to proceed to Phase 3 (`docs/intent/previews/previews-specs.md`).