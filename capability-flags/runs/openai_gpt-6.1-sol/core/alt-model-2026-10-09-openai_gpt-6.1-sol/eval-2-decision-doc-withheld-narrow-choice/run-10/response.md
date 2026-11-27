**2Q is recorded in `docs/intent/previews/previews-design.md`.** Its rationale lives in the Decisions & Alternatives table: protecting comparison sheets during screenings warrants the extra bookkeeping. I also updated the HLD’s navigation entry to point to the preview-owned policy.

Here is the revised design for review.

## Previews Design

### Context

The worker renders one JPEG contact sheet per clip revision and renderer version. Long screenings introduce many one-use sheets; comparison sessions repeatedly revisit a smaller working set. The mix varies by production, so no eviction policy is best for every observed workload.

### Architecture

Expose `GET /internal/previews/{clip-id}/{revision}` with three outcomes: 200 and JPEG bytes, 202 and a job ticket with a two-second retry interval, or 404 for an unknown revision. This contract is fixed regardless of cache eviction policy.

Use a FIFO render queue with at most four active rendering jobs. Cache entries and all replacement-policy metadata belong exclusively to this worker. Other nodes do not access files, pin previews, inspect policy counters, or depend on entries remaining warm.

### Rendering and Deduplication

Resolve the immutable source revision before rendering. The cache key includes clip ID, revision, and renderer version. Concurrent misses for one key share a job ticket. Once rendering completes, subsequent requests can receive the JPEG directly. Failed jobs are removed from the deduplication map so a later request can retry.

### Private Cache

Cached JPEG data may occupy at most 12 GiB. Before admitting a completed sheet, evict enough existing sheets to remain within that bound. Temporary render output is kept separately and removed on completion or failure. Eviction never deletes source footage or changes job-ticket semantics.

#### 2Q Replacement

Use 2Q to separate first-use sheets from reused sheets. Two resident queues distinguish sheets admitted for screening from sheets retained for repeated comparisons. The first-use queue is ordered by admission; the reused queue is ordered by recent access. This separation gives one-off screening traffic a bounded working area rather than letting every new sheet displace comparison sheets.

Queue membership, ordering, and any history of evicted keys are private replacement metadata. Both resident queues share the 12 GiB JPEG-data budget. Retention is preferential, not a guarantee that a comparison sheet remains cached.

The promotion rule and queue-size allocation determine the precise replacement transitions. These choices are specified in the open questions below before eviction requirements are drafted.

### Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Cache replacement | 2Q with separate first-use and reused resident queues | LRU; frequency-based eviction with aging | Protecting repeatedly compared sheets during long sequential screenings takes priority over minimizing replacement bookkeeping. LRU adapts quickly with little bookkeeping but allows scans to displace useful sheets. Aged frequency counts retain popular clips but require counter maintenance and can retain stale favorites after a project switch. 2Q accepts extra queue bookkeeping and partition tuning to isolate one-off screening traffic. The decision belongs to the preview worker because no other component consumes replacement state. |

### Open Questions & Future Decisions

1. **Promotion and history:** Promote a sheet on a subsequent resident hit, or use full 2Q with a bounded FIFO history of evicted first-use keys and promote only when such a key is requested again? The resident-hit variant recognizes immediate comparisons; the history-based variant avoids treating repeated requests within one screening as evidence of lasting reuse. If history is used, its bound also needs a choice.
2. **Queue allocation:** What share of the JPEG-data budget should be reserved or targeted for first-use sheets, and can either queue borrow unused space? A smaller first-use share protects more comparisons but can cause screening revisits to render again; a larger share retains more recent screening sheets but leaves less comparison capacity. Allocation must account for JPEG bytes rather than assuming every sheet is exactly 2 MiB.
3. **Oversized output:** How should the worker deliver a completed JPEG larger than the entire cache budget while preserving the ready/pending interface and the cache bound?

### References

- [FrameDesk high-level design](docs/high-level-design.md)
- [Preview specifications](docs/intent/previews/previews-specs.md)

---

### Design probe findings

The probe confirmed those three gaps and found additional lifecycle questions:
- What response and ticket state follow a render or admission failure?
- What happens if a completed sheet is evicted before the caller retries, or the worker restarts?
- How are simultaneous admissions and eviction during an active response coordinated?

**Before I finalize this design and draft its EARS requirements:** which promotion rule and queue allocation do you want, and which remaining probe gaps should we resolve now versus leave explicitly open?

`git diff --check` passed.