I have updated `docs/high-level-design.md` (clearing the open-policy note in the Architecture overview) and `docs/intent/previews/previews-design.md` to specify 2Q replacement and record the choice and rejected alternatives in the LLD's `Decisions & Alternatives` table.

### Updated `docs/intent/previews/previews-design.md`

```markdown
---
parent: high-level-design
prefix: PREVIEW
---

# Previews Design

## Context

The worker renders one JPEG contact sheet per clip revision and renderer version. Long screenings introduce many one-use sheets; comparison sessions repeatedly revisit a smaller working set. The worker uses 2Q cache eviction to isolate reused comparison sheets from sequential screening scans.

## Architecture

Expose `GET /internal/previews/{clip-id}/{revision}` with three outcomes: 200 and JPEG bytes, 202 and a job ticket with a two-second retry interval, or 404 for an unknown revision.

Use a FIFO render queue with at most four active rendering jobs. Cache entries and all replacement-policy metadata belong exclusively to this worker. Other nodes do not access files, pin previews, inspect policy counters, or depend on entries remaining warm.

## Rendering and Deduplication

Resolve the immutable source revision before rendering. The cache key includes clip ID, revision, and renderer version. Concurrent misses for one key share a job ticket. Once rendering completes, subsequent requests can receive the JPEG directly. Failed jobs are removed from the deduplication map so a later request can retry.

## Private Cache

Cached JPEG data may occupy at most 12 GiB. Before admitting a completed sheet, evict enough existing sheets to remain within that bound. Temporary render output is kept separately and removed on completion or failure. Eviction never deletes source footage or changes job-ticket semantics.

The cache tracks replacement using two queues (2Q):

- **Probation queue ($A1$)**: Newly rendered sheets enter $A1$ in FIFO order on first admission. One-off screening scans pass through $A1$ and are evicted before touching hot entries.
- **Protected queue ($Am$)**: When a cached sheet in $A1$ (or ghost history $A1_{out}$, if tracked) is requested again, it promotes to $Am$, which manages entries by LRU order. Hits within $Am$ move the entry to the most-recently-used position.
- **Eviction**: When admitting a sheet requires space, evict from the tail of $A1$ while $A1$ exceeds its target byte budget; otherwise evict the least-recently-used sheet from $Am$.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|----------|--------|------------------------|-----------|
| Cache eviction policy | 2Q (two-queue replacement) | LRU; frequency-based eviction with aging | Long sequential screenings otherwise flush comparison working sets under pure LRU, while frequency counters with aging add ongoing maintenance and retain stale project favorites after editors switch projects. 2Q isolates one-off screening scans in a FIFO probation queue while protecting repeatedly compared sheets in an LRU main queue, confining all extra bookkeeping inside the preview worker. |
```

---

### Phase 2 LLD Edge-Case Probe

Before moving to Phase 3 (EARS specs), please review the updated LLD and let me know which of these structural gaps you want to fix in the LLD now versus defer to `Open Questions & Future Decisions`:

1. **2Q queue split and byte budgets**: What is the target split between $A1$ and $Am$ within the 12 GiB cap (e.g., 25% / 3 GiB for $A1$ and 75% / 9 GiB for $Am$), and does promotion occurs strictly on resident $A1_{in}$ hits or do we also maintain an evicted-key ghost FIFO ($A1_{out}$)?
2. **Ghost queue ($A1_{out}$) vs. resident-only 2Q**: If $A1_{out}$ is tracked, what bounds its entry count, and when a key in $A1_{out}$ is re-requested and re-rendered, is the completed sheet admitted directly into $Am$ or into $A1_{in}$? (Or should we use simplified two-queue without $A1_{out}$ where a hit in resident $A1$ promotes directly to $Am$?)
3. **First fetch after render vs. second access**: Because a cold request receives `202` and retries 2 seconds later to fetch the newly admitted sheet, does that initial post-render `200` delivery count as the first observation in $A1$ (keeping it in $A1$), or as a second touch that immediately promotes it to $Am$ (which would promote every rendered scan item)? Similarly, how should coalesced callers that shared the same `202` job ticket be treated?
4. **Oversized sheets**: What happens if a single rendered contact sheet exceeds $A1$'s target byte budget (or the 12 GiB total cap)?
5. **Render failure propagation**: When a render job fails and is cleared from the deduplication map, does a polling retry immediately enqueue a new `202` render job, or should failure return an error status (or require backoff)?
6. **Worker restart persistence**: On worker restart, is 2Q queue metadata persisted, rehydrated from disk files into $A1$, or cleared alongside temporary render output?

Please let me know your rulings on the draft and these questions so we can finalize the LLD and proceed to Phase 3 (EARS specs).