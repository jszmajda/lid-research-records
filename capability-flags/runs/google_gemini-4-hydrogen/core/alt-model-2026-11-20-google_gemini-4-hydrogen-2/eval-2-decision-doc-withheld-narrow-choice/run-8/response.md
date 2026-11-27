I have updated `docs/intent/previews/previews-design.md` with the 2Q eviction design and removed the stale `"Its eviction policy remains open."` sentence from `docs/high-level-design.md` to keep the HLD and LLD coherent. Because eviction bookkeeping is private to the preview worker and affects no other design node, this choice is recorded in the LLD's **Decisions & Alternatives** table rather than as a standalone decision doc.

### Updated `docs/intent/previews/previews-design.md`

```markdown
---
parent: high-level-design
prefix: PREVIEW
---

# Previews Design

## Context

The worker renders one JPEG contact sheet per clip revision and renderer version. Editors alternate long sequential screenings—which introduce many one-use sheets—with comparison sessions that repeatedly revisit a smaller working set.

## Architecture

Expose `GET /internal/previews/{clip-id}/{revision}` with three outcomes: 200 and JPEG bytes, 202 and a job ticket with a two-second retry interval, or 404 for an unknown revision. This contract is fixed regardless of cache eviction policy.

Use a FIFO render queue with at most four active rendering jobs. Cache entries and all replacement-policy metadata belong exclusively to this worker. Other nodes do not access files, pin previews, inspect policy counters, or depend on entries remaining warm.

## Rendering and Deduplication

Resolve the immutable source revision before rendering. The cache key includes clip ID, revision, and renderer version. Concurrent misses for one key share a job ticket. Once rendering completes, subsequent requests can receive the JPEG directly. Failed jobs are removed from the deduplication map so a later request can retry.

## Private Cache

Cached JPEG data may occupy at most 12 GiB. Temporary render output is kept separately and removed on completion or failure. Eviction never deletes source footage or changes job-ticket semantics.

### 2Q Eviction Policy

The cache uses the 2Q replacement policy to isolate one-off sequential screening scans from the reused comparison working set. All queues and ghost metadata live strictly inside the preview worker.

**Queues and budgets:**
- **`A1in` (FIFO, resident)**: Admits newly rendered sheets on cold misses. Target budget: 25% of the 12 GiB cache (3 GiB).
- **`A1out` (FIFO, ghost/non-resident)**: Tracks keys evicted from `A1in` without retaining JPEG data on disk. Bounded by entry count (default: 3,000 keys, roughly 50% of the ~6,000-sheet cache capacity at ~2 MiB per sheet).
- **`Am` (LRU, resident)**: Holds reused sheets promoted via `A1out`. Target budget: 75% of the 12 GiB cache (9 GiB).

**Lookup and admission:**
- **Hit in `A1in`**: Serve the JPEG bytes; leave the entry in its FIFO position in `A1in` (hits in `A1in` do not promote directly to `Am`).
- **Hit in `Am`**: Serve the JPEG bytes and move the entry to the most-recently-used position of `Am`.
- **Miss with key in `A1out` (ghost hit)**: Render the sheet, remove the key from `A1out`, and admit the completed sheet into `Am`.
- **Miss with key absent from `A1out` (cold miss)**: Render the sheet and admit the completed sheet into `A1in`.

**Eviction:**
Before admitting a completed sheet into `A1in` or `Am`, evict enough resident entries so total cached JPEG bytes (including the new sheet) do not exceed 12 GiB:
1. While admitting to `A1in` would push `A1in` over its 3 GiB target (or total resident bytes over 12 GiB while `A1in` is non-empty and `Am` is within its 9 GiB target), evict the oldest entry from `A1in`, delete its JPEG file, and append its key to `A1out` (evicting the oldest key from `A1out` if `A1out` is at capacity).
2. Otherwise, evict the least-recently-used entry from `Am` and delete its JPEG file without recording it in `A1out`.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|----------|--------|------------------------|-----------|
| Cache eviction policy | 2Q (`A1in` FIFO + `A1out` ghost FIFO + `Am` LRU) | **LRU**: lowest bookkeeping cost and fast adaptation on project switches, but sequential screenings evict comparison sheets.<br>**Frequency with aging**: protects repeatedly popular clips, but counter maintenance and aging add overhead and lag project switches. | Isolates one-off sequential screening sheets in `A1in` so they do not evict the comparison working set in `Am`, while keeping all queues and tuning parameters private to the preview worker. |

## Open Questions & Future Decisions

### Deferred
1. Tuning the `A1in`/`Am` size split (default 25%/75%) and `A1out` key limit (default 3,000) against production pilot telemetry.
```

---

### LLD-Level Edge-Case Probe

A subagent probed `previews-design.md` for internal gaps. Please triage which of these should be specified in the LLD now versus deferred to **Open Questions**:

1. **Error shapes & `202` encoding**: `GET /internal/previews/{clip-id}/{revision}` only lists `200`, `202`, and `404`, leaving malformed-parameter (`400`), render-failure (`500`/`503`), and `202` retry encoding (`Retry-After` header vs. JSON body) unspecified.
2. **Deterministic render failures**: Failed jobs are removed from the deduplication map so later requests can retry, which lets a polling client re-enqueue an unrenderable source every 2 seconds indefinitely.
3. **Render queue backpressure**: No queue depth limit or rejection behavior (`429`/`503`) is defined if requests arrive faster than the 4 active workers drain them.
4. **Job ticket usage**: It is unspecified whether clients re-poll `GET /internal/previews/{clip-id}/{revision}` (making the ticket informational) or query the ticket ID directly.
5. **Ghost-hit latching across render duration**: If a key is in `A1out` on miss, it is unspecified whether `Am` admission is latched at enqueue time or checked at completion (in case `A1out` evicts the key while rendering, or the render fails).
6. **Concurrent render completions**: Up to 4 workers complete concurrently; admission + eviction + 12 GiB accounting need serialization so concurrent completions cannot overshoot 12 GiB.
7. **Concurrent read vs. eviction**: No synchronization or unlink-safe read invariant is stated if a `200` response is reading a JPEG file while an eviction deletes it.
8. **Queue budget elasticity**: Rule 1 triggers eviction on `A1in > 3 GiB` even if total cache is under 12 GiB, and it is ambiguous whether `Am` may grow past 9 GiB when `A1in` is underutilized.
9. **Worker restart / crash recovery**: It is unspecified whether `A1in`, `Am`, and `A1out` are persisted or in-memory only, and how orphaned cache files or leftover temp files are handled on startup.
10. **Renderer version upgrades**: Old-version JPEGs remain keyed by renderer version, but it is unspecified whether they are purged on startup or left to age out via 2Q eviction.
11. **Temp render space & atomic promotion**: Temp output has no stated size bound, and behavior on disk-full or move failure is unspecified.

---

**Phase 2 Stop:** Please review the updated LLD (and the 1-line HLD coherence update), let me know how you want to triage items 1–11 (fix in LLD vs. defer), and confirm when you are ready to proceed to **Phase 3** (updating `docs/intent/previews/previews-specs.md`).