**Phase 2 — LLD update** (stop for review)

---

**HLD change** (one line, Architecture section):
> Previews: ... private 12 GiB cache ~~Its eviction policy remains open.~~ → using 2Q eviction.

---

**Updated `docs/intent/previews/previews-design.md`:**

---
parent: high-level-design
prefix: PREVIEW
---

### Previews Design

#### Context

The worker renders one JPEG contact sheet per clip revision and renderer version. Long screenings introduce many one-use sheets; comparison sessions repeatedly revisit a smaller working set. The cache uses 2Q to protect the reused comparison-sheet working set from sequential screening scans.

#### Architecture

Expose `GET /internal/previews/{clip-id}/{revision}` with three outcomes: 200 and JPEG bytes, 202 and a job ticket with a two-second retry interval, or 404 for an unknown revision. This contract is fixed regardless of cache eviction policy.

Use a FIFO render queue with at most four active rendering jobs. Cache entries and all replacement-policy metadata belong exclusively to this worker. Other nodes do not access files, pin previews, inspect policy counters, or depend on entries remaining warm.

#### Rendering and Deduplication

*(unchanged)*

#### Private Cache

Cached JPEG data may occupy at most 12 GiB. Before admitting a completed sheet, evict enough existing sheets to remain within that limit. Temporary render output is kept separately and removed on completion or failure. Eviction never deletes source footage or changes job-ticket semantics.

**2Q Replacement**

The cache maintains two queues:

- **Probationary queue (A1)**: FIFO, bounded at 3 GiB (25 % of the 12 GiB budget). All newly completed sheets enter here.
- **Protected queue (Am)**: LRU, holds the remaining capacity up to 9 GiB. A sheet moves here when a second request hits it while it is still in A1.

**Admission**: a completed sheet enters at the tail of A1. If total cached JPEG data then exceeds 12 GiB, eviction runs immediately before the response is returned.

**Promotion**: the first cache hit for a sheet in A1 moves that entry to the head of Am. Subsequent hits find it in Am and update its Am position normally.

**Eviction order**: while total cached JPEG data exceeds 12 GiB, evict one entry at a time — if A1 exceeds its 3 GiB quota, evict the A1 tail; otherwise evict the Am tail. Repeat until the total is at or below 12 GiB.

**Re-admission after eviction**: a sheet evicted from A1 before it was ever promoted re-enters A1 on the next render completion, not Am.

**Open Questions**: The 3 GiB / 9 GiB split is an initial value. Pilot patterns may require adjustment; the split is internal and changes nothing external.

#### Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Cache eviction policy | 2Q: FIFO A1 + LRU Am | LRU; frequency-based with aging | LRU is vulnerable to sequential screenings evicting the comparison-sheet working set. Frequency with aging protects popular sheets but adds per-entry counter maintenance and is slow to clear stale favorites on project switch. 2Q separates first-use (screening) from reused (comparison) sheets, resisting scans at the cost of an extra queue and a size-split parameter. External interface, render queue, and disk budget are unaffected. |

---

**LLD-level edge-case probe** — three gaps I found in the 2Q mechanics as written; these are structural ambiguities inside this component, not cross-segment issues:

1. **Concurrent A1 promotion**: two simultaneous requests both observe the same entry in A1 (neither has promoted it yet). The LLD says "the first cache hit moves it to Am" but doesn't address the race. If both threads try to promote, does the entry appear in Am twice, or is promotion idempotent? The implementation needs a single atomic move — but the LLD should state it, because a blind implementer reading this could choose a check-then-act that races.

2. **Mid-read eviction**: a sheet is actively being streamed to a client when eviction selects its A1 entry. The LLD doesn't say whether an in-flight read holds the entry or whether the file can be unlinked underneath it. Filesystem unlink on an open descriptor is safe on Linux (the read completes), but this is a hidden assumption. If the worker ever runs on a platform where that doesn't hold, or if the client gets an abrupt truncation, the LLD's silence becomes a trap.

3. **Eviction atomicity across concurrent admissions**: two render jobs complete at nearly the same time. Both attempt admission to A1. If each independently checks the total and decides to evict, they may evict duplicates or both evict fewer entries than needed. The LLD implies a single admission lock but doesn't say so.

**My read on triage**: gap 1 needs a line in the LLD (the race is real and correctness-affecting). Gaps 2 and 3 are likely "specify the locking model once" — a note that admission and promotion hold a single mutex covers all three. I can add that, or you can defer gaps 2 and 3 as implementation details if you trust the implementer to pick a standard locking approach.

Which of these do you want fixed in the LLD before we move to Phase 3 (EARS specs), and which are you happy to leave as implementation details?