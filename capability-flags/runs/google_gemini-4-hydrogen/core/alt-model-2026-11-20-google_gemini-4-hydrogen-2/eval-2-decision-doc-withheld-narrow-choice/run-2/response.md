Updated `docs/intent/previews/previews-design.md` for **2Q** cache replacement (Phase 2) and removed the stale "eviction policy remains open" note from `docs/high-level-design.md`.

### Phase 2 Summary (`docs/intent/previews/previews-design.md`)
- **Private Cache (2Q)**: Defined the three queues—`A1in` (FIFO probation queue bounded by `Kin`), `Am` (LRU protected queue bounded by `12 GiB - Kin`), and `A1out` (FIFO ghost-key queue bounded by `Kout`, holding metadata only)—along with hit/miss admission and eviction-before-admission rules.
- **Decisions & Alternatives**: Recorded 2Q over LRU and frequency-based eviction with aging. (Recorded as a table row rather than a standalone decision doc because replacement tracking is private to the preview worker and affects no other nodes.)
- **Open Questions & Future Decisions**: Deferred `Kin` and `Kout` tuning to pilot telemetry.

### LLD-Level Edge-Case Probe (for triage)
Please let me know which of these gaps to resolve in `previews-design.md` vs. defer as open questions:

1. **Cache hit in `A1in`**: Does a hit on an entry in `A1in` leave it in its FIFO position (classic 2Q) or promote it to `Am`?
2. **Queue budget invariants (`Kin` vs. `12 GiB - Kin`)**: Can `A1in` or `Am` exceed its individual share when total usage is below 12 GiB, and what happens at boundary configs (`Kin = 0`, `Kin = 12 GiB`, `Kout = 0`)?
3. **Oversized rendered sheet**: What happens if a single rendered JPEG exceeds `12 GiB` or `Kin`—bypass caching while serving bytes, or fail?
4. **`A1out` overflow**: When `A1out` is at `Kout` entries and another entry is evicted from `A1in`, does `A1out` drop its oldest key in FIFO order?
5. **Concurrent read vs. eviction**: What happens if an entry in `A1in` or `Am` is selected for eviction while its JPEG bytes are being streamed for an in-flight `200` response?
6. **Completion-to-admission race**: What happens if a `GET` request arrives between a render job finishing (removed from the deduplication map) and the JPEG being admitted to `A1in` or `Am`?
7. **Render failure and polling clients**: When a failed job is removed from the deduplication map and a client holding the `202` ticket polls again, does it silently enqueue a new render job? Is there a retry limit or error payload?
8. **Render queue bounds and timeouts**: Is the FIFO render queue bounded in depth (and what HTTP status is returned if full), and what happens if one of the 4 active render jobs hangs?
9. **Eviction before client poll**: What happens if a rendered sheet is admitted and then evicted under load before a `202`-polling client returns after 2 seconds?
10. **Worker restart and recovery**: On worker restart, is the cache wiped or reconstructed from disk, and how are orphaned temporary render files cleaned up?

Approve the updated LLD (and indicate any probe items to fold in or defer) to proceed to **Phase 3 (EARS specs)**.