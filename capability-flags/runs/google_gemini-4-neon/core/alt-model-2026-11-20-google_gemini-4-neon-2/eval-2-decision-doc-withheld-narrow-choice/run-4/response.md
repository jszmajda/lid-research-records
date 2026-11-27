I updated `docs/intent/previews/previews-design.md` with the 2Q cache replacement design and removed the stale "eviction policy remains open" note from `docs/high-level-design.md`.

### Phase 2 Updates (`docs/intent/previews/previews-design.md`)

- **Private Cache:** Specified 2Q with a FIFO first-use queue (`A1in`), a bounded FIFO ghost-history queue (`A1out`, keys only), and an LRU reused queue (`Am`). Combined JPEG bytes in `A1in` and `Am` stay within 12 GiB via a configurable capacity split; eviction drains `A1in` while it exceeds its target share (recording keys in `A1out`) and otherwise evicts LRU from `Am`.
- **Decisions & Alternatives:** Recorded 2Q alongside LRU and frequency-based eviction with aging, capturing the scan-protection vs. bookkeeping/tuning trade-off.
- **Open Questions & Future Decisions:** Deferred the exact default `A1in`/`Am` split and `A1out` entry bound to pilot tuning.

### LLD-Level Edge-Case Probe

Please triage which of these gaps to resolve in `previews-design.md` now vs. defer as open questions:

1. **Cache hit on `A1in`:** When a request hits an entry still in `A1in`, does it stay in its FIFO position (standard 2Q), move to the back of `A1in`, or promote immediately to `Am`?
2. **Eviction fallback and oversized sheets:** When `A1in` is at or below its target share and `Am` is empty (or smaller than the space needed), does eviction fall back to `A1in` below its target share? What if a single rendered sheet exceeds `A1in`'s target share or the 12 GiB total cap?
3. **`A1out` membership timing across queued renders:** If a missed key is in `A1out` when enqueued, but pushed out of `A1out` before rendering finishes, is promotion to `Am` decided at enqueue time or at completion time?
4. **Concurrent read vs. eviction:** How are in-flight `200` responses protected if their cached sheet is evicted mid-stream, and do evicted-but-still-open files count toward the 12 GiB budget?
5. **Worker restart and crash recovery:** Are cached JPEGs and 2Q queues (`A1in`, `A1out`, `Am`) ephemeral or persisted across restarts? If files survive a restart, how are they classified and reconciled against the 12 GiB cap, and how are orphaned temporary render files cleaned up?
6. **Render/admission failures and transient errors:** If a clip fails to render repeatedly (or fails cache admission on disk I/O), removing it from the deduplication map lets clients loop on `202` every two seconds; should there be failure handling or backoff? Also, what should happen on transient source-revision lookup errors vs. unknown revisions (`404`)?
7. **Queue backpressure and completion handoff:** Is the FIFO render queue bounded (and if so, what response is returned when full)? What ordering invariant ensures a concurrent request cannot miss between deduplication-map removal and cache visibility?

Let me know if the updated LLD looks good and how you want to triage items 1–7 before we move to Phase 3 (EARS specs in `docs/intent/previews/previews-specs.md`).