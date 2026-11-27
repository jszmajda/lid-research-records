Updated `docs/intent/previews/previews-design.md` with the 2Q replacement design and Decisions & Alternatives row, and removed the stale "Its eviction policy remains open." sentence from `docs/high-level-design.md` so the HLD stays coherent. (`review-api` is unchanged; no EARS specs have been modified yet.)

### Updated LLD (`docs/intent/previews/previews-design.md`)

```markdown
---
parent: high-level-design
prefix: PREVIEW
---

# Previews Design

## Context

The worker renders one JPEG contact sheet per clip revision and renderer version. Editors alternate long sequential screenings that introduce many one-use sheets with comparison sessions that repeatedly revisit a smaller working set.

## Architecture

Expose `GET /internal/previews/{clip-id}/{revision}` with three outcomes: 200 and JPEG bytes, 202 and a job ticket with a two-second retry interval, or 404 for an unknown revision. This contract is fixed regardless of cache eviction policy.

Use a FIFO render queue with at most four active rendering jobs. Cache entries and all replacement-policy metadata belong exclusively to this worker. Other nodes do not access files, pin previews, inspect policy counters, or depend on entries remaining warm.

## Rendering and Deduplication

Resolve the immutable source revision before rendering. The cache key includes clip ID, revision, and renderer version. Concurrent misses for one key share a job ticket. Once rendering completes, subsequent requests can receive the JPEG directly. Failed jobs are removed from the deduplication map so a later request can retry.

## Private Cache

Cached JPEG data may occupy at most 12 GiB. Before admitting a completed sheet, evict enough existing sheets to remain within that bound. Temporary render output is kept separately and removed on completion or failure. Eviction never deletes source footage or changes job-ticket semantics.

The cache uses **2Q** replacement so one-off sequential screenings do not flush repeatedly revisited comparison sheets:

- **Probation queue (`A1in`, FIFO)**: Holds newly admitted contact sheets, targeted to a configurable byte share `Kin` of the 12 GiB budget (default 25%, 3 GiB).
- **Main queue (`Am`, LRU)**: Holds promoted, reused contact sheets using the remainder of the 12 GiB budget.
- **Ghost queue (`A1out`, FIFO)**: Holds preview keys (metadata only, no JPEG bytes) recently evicted from `A1in`, bounded by a configurable key count `Kout` (default 3,000 keys, roughly half the nominal 6,000-sheet capacity at 2 MiB/sheet).

Replacement rules:

- **Cache hit**: A hit in `Am` moves the entry to the most-recently-used head of `Am`. A hit in `A1in` serves the sheet without promoting it to `Am`, preventing short bursts during a single screening from displacing comparison sheets.
- **Admission**: When a completed sheet is ready to admit, if its key is present in `A1out`, remove the key from `A1out` and admit the sheet at the head of `Am`; otherwise admit it at the head of `A1in`.
- **Eviction**: While admitting the new sheet would exceed 12 GiB, evict one entry at a time before admission. If `A1in` exceeds `Kin` (or `Am` is empty), evict from the tail of `A1in` and append its key to `A1out` (dropping the oldest `A1out` key when at `Kout`). Otherwise evict from the LRU tail of `Am` without recording it in `A1out`.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Cache eviction policy | 2Q | LRU; frequency-based eviction with aging | Protects repeatedly revisited comparison sheets from being flushed by long sequential screenings while keeping all replacement state private to the preview worker. LRU has lower bookkeeping overhead and adapts faster on project switches, but sequential scans evict comparison sheets. Aged frequency counts retain popular clips, but add counter and aging maintenance and can keep stale favorites warm after editors switch projects. |

## Open Questions & Future Decisions

### Deferred

1. Tuning the 2Q probation budget (`Kin`) and ghost queue length (`Kout`) against pilot production workloads.
```

### Phase 2 LLD Edge-Case Probe

Please triage which of these gaps to address in the LLD now vs. defer as open questions:

1. **Oversized sheets and byte accounting**: What happens if a single rendered JPEG exceeds the 12 GiB budget (eviction loop empties both queues without fitting)? Should the 12 GiB limit count logical JPEG byte length or allocated disk blocks, and does temporary render output have its own bound?
2. **Lookup / dedup / admission atomicity**: How are cache lookup, dedup-map check, and completion handoff synchronized so a concurrent `GET` cannot miss right as a job completes or admit duplicate keys into 2Q? What if cache admission fails (e.g., disk I/O error) after rendering succeeds?
3. **Eviction vs. in-flight HTTP 200 reads**: If 2Q evicts an entry while a `GET` is actively streaming its JPEG, does eviction unlink immediately (allowing open descriptors to finish, temporarily exceeding 12 GiB on disk) or skip/defer actively read entries?
4. **Repeated render or source-resolution failures**: Beyond `200`, `202`, and `404`, what happens on transient source-resolution errors or repeatedly failing renders (e.g., corrupt footage)—should there be a 5xx response or retry cap instead of indefinite `202` polling?
5. **Render queue saturation**: The worker caps active renders at 4 on a FIFO queue, but defines no max queue depth. Should the queue be bounded with a rejection status/retry response, or unbounded?
6. **Worker restart and recovery**: On crash or restart, are cached JPEGs wiped cold or scanned back into 2Q (and if scanned, into `A1in` or `Am`, and how are old renderer-version files and orphaned temp files cleaned up)?
7. **2Q boundary conditions (`A1out`, `Kin`, `Kout`)**: If admission fails after removing a key from `A1out`, should the key be restored or dropped? What are the valid bounds for `Kin` (e.g., `0 < Kin < 12 GiB`) and `Kout` (`>= 0`)?

Please review the LLD above and let me know:
- Any edits to the 2Q design or defaults (`Kin` = 25%, `Kout` = 3,000, no promotion on `A1in` hit), and
- Which of items 1–7 to fold into the LLD vs. defer—once you approve Phase 2, I'll move on to Phase 3 (`docs/intent/previews/previews-specs.md`).