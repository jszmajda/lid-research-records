Updated `docs/intent/previews/previews-design.md` for **2Q** cache eviction (Phase 2) and removed the stale "eviction policy remains open" note from `docs/high-level-design.md`.

### Summary of LLD Changes (`docs/intent/previews/previews-design.md`)
- **2Q Eviction Policy** under `## Private Cache`:
  - **`A1in` (FIFO, target 25% / 3 GiB)**: Admits newly rendered sheets; hits serve without promotion so sequential screenings do not displace `Am`.
  - **`A1out` (ghost FIFO, bounded key capacity)**: Tracks keys evicted from `A1in`; a subsequent miss for a key in `A1out` promotes the re-rendered sheet directly into `Am`.
  - **`Am` (LRU, remaining 9 GiB)**: Holds reused sheets; hits move entries to the MRU position.
  - **Eviction rule**: Before admission, if total cached JPEG bytes across `A1in` and `Am` would exceed 12 GiB, evict from `A1in` while it exceeds its target share (recording keys in `A1out`), and otherwise from the LRU tail of `Am`.
- **Decisions & Alternatives**: Recorded 2Q vs. LRU and frequency-based eviction with aging, noting the accepted bookkeeping and `A1in`/`Am` split contained privately in the preview worker.
- **Open Questions & Future Decisions**: Deferred pilot tuning of the `A1in` share and `A1out` capacity.

### LLD-Level Edge-Case Probe (for Triage)
A blind probe of `docs/intent/previews/previews-design.md` surfaced these internal gaps:
1. **Eviction fallback when `Am` is empty**: What happens when admitting a sheet would exceed 12 GiB, `A1in` is at or below its 3 GiB target, and `Am` is empty (or empties before enough space is freed)?
2. **Oversized single sheet**: What happens if a single rendered JPEG exceeds `A1in`'s 3 GiB target (or the 12 GiB total budget)?
3. **`A1out` bound & re-admission cleanup**: What is `A1out`'s key capacity bound, and when a key in `A1out` is re-rendered into `Am`, is it removed from `A1out`?
4. **`A1out` membership drift during in-flight renders**: Is `A1out` checked at enqueue time or at post-render admission time if concurrent evictions push the key out of `A1out` while rendering?
5. **Simultaneous admissions**: Are space-check, eviction, and queue-insertion serialized across the up to 4 concurrent render jobs?
6. **Concurrent eviction during active `200` read**: What happens if an entry in `A1in` or `Am` is selected for eviction while a `GET` handler is streaming its JPEG bytes?
7. **Unbounded FIFO render queue**: Does the render queue grow without bound under sustained cache misses, or is there a queue-depth limit / shedding behavior?
8. **Worker restart / crash recovery**: On restart, are on-disk cache files and 2Q metadata wiped, or persisted and reconciled against partial temporary files?

**Next step (Phase 2 stop):** Please review `docs/intent/previews/previews-design.md` (and `docs/high-level-design.md`), let me know which of items 1–8 to specify in the LLD now vs. defer, and confirm when you're ready to proceed to **Phase 3 (EARS specs)**.