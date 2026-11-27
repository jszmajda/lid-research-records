Updated `docs/intent/previews/previews-design.md` with the 2Q eviction policy and its Decisions & Alternatives row, and removed the stale "Its eviction policy remains open." note from `docs/high-level-design.md` to keep the HLD coherent.

### Updated `docs/intent/previews/previews-design.md`

- **2Q Eviction Policy** under `## Private Cache`:
  - `A1in` (FIFO, resident probation queue): newly rendered sheets on first admission; default 25% of the 12 GiB budget (3 GiB, configurable).
  - `A1out` (FIFO, metadata-only ghost queue): cache keys `(clip-id, revision, renderer-version)` evicted from `A1in`; default 3,000-key limit.
  - `Am` (LRU, resident main queue): reused sheets promoted on re-admission when their key is in `A1out`; remaining 75% (9 GiB).
  - Hits in `Am` move the entry to MRU; hits in `A1in` serve without promotion so short sequential bursts do not promote one-use sheets.
  - Before admitting a sheet of size `S` bytes, evict until `resident_bytes + S <= 12 GiB` (from `A1in` when at/above its target share or `Am` is empty, recording the key in `A1out`; otherwise from `Am`'s LRU end without adding to `A1out`).
- **Decisions & Alternatives**: recorded the `Cache eviction policy` row (2Q vs. LRU and frequency-based eviction with aging, with rationale).
- **Open Questions & Future Decisions (Deferred)**: tuning the `A1in`/`Am` byte split and `A1out` key limit against pilot workload telemetry.

### Phase 2 LLD Edge-Case Probe

A cold-read probe of `docs/intent/previews/previews-design.md` surfaced these internal gaps for triage (**fix in LLD** vs. **defer as open question**):

1. **Render failures & retry storms vs. the three-outcome contract**: What happens on transient storage I/O errors during source resolution or persistent render failures (e.g., corrupt media)—does the endpoint return a `5xx` outside `200`/`202`/`404`, and how is a 2-second polling loop prevented from infinitely re-enqueuing failing jobs?
2. **Unbounded FIFO render queue & stuck jobs**: Active renders are capped at four, with no queue-depth bound, backpressure status code, or per-job timeout specified. What happens under a miss burst or a hung render?
3. **Concurrency between eviction, admission, and in-flight `200` reads**: Are eviction and admission serialized/atomic across the up to four concurrent completions so the 12 GiB cap cannot be exceeded, and what happens if eviction deletes a JPEG currently being streamed to an in-flight `200` response?
4. **Oversized sheets and admission I/O failures**: What happens if a rendered sheet exceeds 12 GiB (unsatisfiable eviction loop), exceeds `A1in`'s 25% share, or fails to move from temporary storage into the cache (e.g., `ENOSPC`) after entries were already evicted?
5. **Worker restart, crash recovery, and renderer-version upgrades**: Are cached JPEGs and 2Q queues (`A1in`, `A1out`, `Am`) ephemeral or persisted across restarts? On restart or `renderer-version` change, are existing cache files and orphaned temporary outputs wiped or reloaded?
6. **Completion-to-admission race in deduplication**: What happens if a request arrives between render completion, 2Q admission, and deduplication-map removal—or if another completing job evicts the new sheet before polling clients retry?
7. **Missing/corrupt cache files on hit & `202` ticket shape**: What happens if an `A1in`/`Am` metadata hit finds its JPEG missing or unreadable on disk (purge and return `202`, or `5xx`), and what exact response payload/headers carry the job ticket and retry interval?

Please review the updated LLD and let me know:
1. Any changes to `previews-design.md` (including the 2Q defaults or `A1in` hit behavior).
2. For probe items 1–7, which to resolve in the LLD now vs. defer as open questions.

Once you approve Phase 2, I'll proceed to Phase 3 (updating `docs/intent/previews/previews-specs.md`).