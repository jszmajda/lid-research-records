Recorded **2Q** in `docs/intent/previews/previews-design.md`, with the scan-resistance rationale and alternatives in its Decisions & Alternatives table. This choice is local to previews, so that table is sufficient.

The HLD now points replacement-policy ownership to previews. The existing specs are coherent with the cache budget and interface, but do not yet specify 2Q behavior.

## Preview design draft — for review

### Context

The worker renders one JPEG contact sheet per clip revision and renderer version. Long screenings introduce many one-use sheets; comparison sessions repeatedly revisit a smaller working set. The mix varies by production, so no eviction policy is best for every observed workload.

### Architecture

Expose `GET /internal/previews/{clip-id}/{revision}` with three outcomes:

- **200:** JPEG bytes.
- **202:** A job ticket with a two-second retry interval.
- **404:** Unknown revision.

Use a FIFO render queue with at most four active rendering jobs. Cache entries and replacement metadata belong exclusively to this worker. Other nodes do not access files, pin previews, inspect policy counters, or depend on entries remaining warm.

### Rendering and deduplication

Resolve the immutable source revision before rendering. The cache key includes clip ID, revision, and renderer version.

Concurrent misses for one key share a job ticket. Once rendering completes, subsequent requests can receive the JPEG directly. Failed jobs are removed from the deduplication map so a later request can retry.

### Private cache

Cached JPEG data may occupy at most **12 GiB**. Before admitting a completed sheet, evict enough existing sheets to remain within that bound. Temporary render output is kept separately and removed on completion or failure. Eviction never deletes source footage or changes job-ticket semantics.

#### 2Q replacement

Separate first-use sheets from reused sheets. One-off sequential screenings turn over the first-use population while the reused population retains comparison sheets. Reused sheets remain eligible for eviction; no clip has guaranteed residency.

- The **first-use resident queue** is ordered by admission: FIFO.
- The **reused resident queue** is ordered by access: LRU. A successful cached request refreshes a reused sheet’s position.
- Membership uses the complete preview key.
- Rendering completion admits JPEG data; polling a pending ticket does not establish reuse.
- Queue sizing accounts for actual JPEG bytes rather than entry count.
- Combined resident data stays within 12 GiB.
- Queue membership, replacement tracking, and any evicted-key history remain private to the worker.

### Decisions & Alternatives

| Decision | Chosen | Alternatives | Rationale |
|---|---|---|---|
| Private cache replacement | 2Q | LRU; frequency-based eviction with aging | Protect comparison sheets from sequential screening scans, accepting extra bookkeeping and size tuning. LRU is inexpensive and adapts quickly but is scan-vulnerable. Aged frequency counts protect popular sheets but add maintenance and can retain stale favorites after project switches. |

### Open questions

**Promotion variant**

1. **Two resident queues:** A second successful cached request promotes a first-use sheet. Eviction discards its history. This recognizes resident comparisons directly, with less metadata, but misses reuse after eviction.
2. **Full 2Q with ghost history:** Retain a bounded FIFO of evicted first-use keys, without JPEG data. A ghost-key request renders again and admits the result to the reused queue. Resident first-use hits do not promote. This recognizes reuse across eviction, but adds history sizing and may delay promotion of frequently compared resident sheets.

**Sizing and admission**

- Choose the first-use byte target and whether it can borrow unused reused capacity. Smaller targets shield comparisons more strongly; larger targets retain more screening sheets.
- For ghost history, choose a key-count bound and expiration behavior.
- Define admission and result delivery for sheets larger than the first-use target or the entire cache budget.

**Lifecycle and ordering**

- Decide whether replacement metadata survives restart and how existing JPEGs regain membership.
- Define concurrent lookup, queue updates, admission, and eviction so keys cannot acquire duplicate membership or lose their JPEG during a response.

**Additional gaps found by the LLD probe**

- Ticket and response behavior after render failure, eviction before the next poll, or restart during a job.
- Source-read, missing-cache-file, admission, and eviction failures.
- Queue saturation and stalled-render behavior.
- Renderer-version transitions with outstanding jobs and tickets.

References: the FrameDesk HLD and preview specifications.

---

**Before I finalize this LLD and draft its EARS updates:**

1. Which promotion variant do you want: **two resident queues** or **full 2Q with ghost history**?
2. For sizing, would you approve a proposed **3 GiB first-use soft target**, borrowing unused capacity while keeping the total at 12 GiB?
3. Which probe gaps should be resolved now, and which may remain explicitly deferred?

`git diff --check` passes.