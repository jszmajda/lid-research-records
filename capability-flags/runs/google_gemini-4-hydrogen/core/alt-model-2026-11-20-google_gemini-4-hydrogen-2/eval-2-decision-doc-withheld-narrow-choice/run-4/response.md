Updated the design docs for 2Q cache eviction (Phase 2 — LLD):

- **`docs/high-level-design.md`**: Removed `"Its eviction policy remains open."` under `## Architecture` so the HLD stays coherent with the settled LLD.
- **`docs/intent/previews/previews-design.md`**:
  - Updated `## Context` and `## Private Cache` to specify 2Q (`A1in` FIFO admission queue, `A1out` FIFO ghost queue, `Am` LRU main queue) with an initial 25% / 75% byte split (`3 GiB` / `9 GiB`) and `A1out` bounded to 50% of nominal sheet capacity.
  - Added `## Decisions & Alternatives` recording 2Q over LRU and frequency-based eviction with aging (recorded as a table row rather than a decision doc, since replacement bookkeeping is private to `previews` and no other node depends on it).
  - Added `## Open Questions & Future Decisions` with tuning of the `A1in`/`Am` split and `A1out` bound deferred.

### LLD Edge-Case Probe (for triage: fix in LLD vs. defer)

1. **A1out check and removal timing**: Is `A1out` membership checked/removed at miss/enqueue time or at render-completion/admission time (if another completion evicts the ghost key while the job is in flight)?
2. **A1out state on render failure**: If `A1out` membership is consumed at miss/enqueue time and the render fails, is the ghost key lost or restored?
3. **Per-queue budgets vs. 12 GiB global cap**: Are the `3 GiB` (`A1in`) and `9 GiB` (`Am`) limits strict per-queue caps, or can one queue borrow unused space up to `12 GiB`?
4. **Oversized single sheet**: What happens if a single rendered JPEG exceeds its target queue's byte budget or `12 GiB`?
5. **A1out capacity calculation**: How is "nominal sheet capacity" defined when actual JPEG sizes vary?
6. **Concurrent read vs. eviction**: What happens when a `200` response streams a cached JPEG concurrently with 2Q evicting and deleting that file?
7. **Shared job ticket on render failure**: After multiple concurrent misses share a `202` job ticket and the render fails, do subsequent polls silently enqueue a new render or return an error?
8. **Stuck or persistently failing renders**: Is there a render timeout, backoff, or retry limit?
9. **Render queue backpressure**: Is the waiting queue behind the 4-job FIFO limit unbounded, or does it reject new misses (e.g., `503`) at some depth?
10. **Source resolution timing vs. 404**: Is unknown-revision resolution synchronous on the request path (immediate `404`) or asynchronous in the render worker?
11. **202 job ticket shape and polling target**: What are the exact headers/body for the `202` ticket and 2-second retry interval, and does the client re-poll `GET /internal/previews/{clip-id}/{revision}` or a ticket URL?
12. **Worker startup and restart**: What happens to on-disk JPEGs, orphaned temp files, in-flight tickets, and in-memory `A1in`/`A1out`/`Am` state on worker restart?
13. **Renderer version changes**: Are cached sheets and queue entries from an older renderer version purged on startup or left to age out through 2Q?
14. **Temporary render storage exhaustion**: What happens if temporary render storage runs out of disk space?

**Phase 2 stop:** Please review `docs/intent/previews/previews-design.md` and let me know which probe items to resolve in the LLD vs. defer, and whether you approve moving to Phase 3 (`previews-specs.md`).