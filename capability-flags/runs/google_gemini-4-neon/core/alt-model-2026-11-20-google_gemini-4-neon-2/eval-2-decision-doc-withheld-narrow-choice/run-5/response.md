Updated `docs/intent/previews/previews-design.md` with the 2Q replacement design and its `Decisions & Alternatives` entry (and removed the stale "eviction policy remains open" note from `docs/high-level-design.md`).

### Phase 2 Summary — `docs/intent/previews/previews-design.md`
- **Private Cache / 2Q Replacement Policy**: Added `A1in` (probationary FIFO, configured byte share), `A1out` (bounded metadata-only ghost FIFO), and `Am` (reused LRU, remainder of the 12 GiB budget), with admission, ghost re-admission, promotion, and eviction rules kept private to the preview worker.
- **Decisions & Alternatives**: Recorded 2Q as chosen over LRU and frequency-based eviction with aging, with rationale.
- **Open Questions & Future Decisions**: Deferred the initial `A1in`/`Am` byte split and `A1out` key capacity for pilot tuning.

### Phase 2 LLD Edge-Case Probe (for triage: fix in LLD vs. defer)
1. **First-fetch promotion from `A1in` under `202` polling**: On a cache miss, the worker returns `202` and the client retries after 2s to fetch the newly rendered sheet. Does that first `200` read count as an `A1in` hit (which would promote one-use screening sheets directly into `Am` and weaken scan resistance), or should `A1in` stay classic 2Q (no promotion on `A1in` hit; promote only on `A1out` re-admission)?
2. **Strict vs. elastic `Am` cap and oversized sheets**: Should `A1in` and `Am` enforce strict per-queue byte caps (evicting from `Am` on promotion even if `A1in` has free space) or only enforce `A1in`'s cap plus the 12 GiB total? And what happens if a single rendered JPEG exceeds `A1in`'s byte share (or 12 GiB)?
3. **Timing of `A1out` lookup and fallback `A1in` eviction**: Is `A1out` membership checked at miss time or at render-completion admission time (in case the ghost key ages out while the job is queued)? When `A1out` re-admission into `Am` falls back to evicting from `A1in`, are those evicted keys recorded in `A1out` or discarded?
4. **Render failures and queue saturation**: Since failed jobs are removed from the deduplication map and clients retry on a 2s interval, how should deterministic render failures, transient source-resolution errors, or a saturated FIFO render queue behave (HTTP status/error shape, or retry ceiling)?
5. **Concurrent eviction during `200` streaming**: If an entry is chosen for eviction while an HTTP handler is streaming its JPEG, does eviction unlink immediately (relying on OS open-file semantics), defer deletion, or wait—and how are in-flight bytes counted against 12 GiB?
6. **Worker restart/crash recovery**: On restart, are cached JPEGs and 2Q queue metadata persisted/reconciled or wiped, and how are orphaned temporary render files cleaned up?
7. **Renderer version upgrades**: When the worker upgrades to a new renderer version, do cached entries from older renderer versions stay until naturally evicted or get purged on startup?

Please review the updated `docs/intent/previews/previews-design.md` and let me know which probe items to resolve in the LLD vs. defer, and whether we're ready to move to **Phase 3** (updating `docs/intent/previews/previews-specs.md`).