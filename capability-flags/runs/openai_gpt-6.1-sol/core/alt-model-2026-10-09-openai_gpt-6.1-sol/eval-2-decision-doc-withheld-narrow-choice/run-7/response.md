**2Q is recorded in `docs/intent/previews/previews-design.md`**, with the rationale in its Decisions & Alternatives table. I also updated the HLD’s stale “eviction policy remains open” sentence to point to the preview design. `git diff --check` passes.

The architecture and existing preview specs remain compatible with this choice. The design additions are below for the required LLD review.

### 2Q replacement

Use 2Q to separate first-use sheets from sheets with demonstrated reuse. A FIFO first-use queue absorbs sequential screening traffic; an LRU reused queue retains comparison sheets. The queues share the 12 GiB JPEG budget. Track occupancy in bytes because JPEG sizes vary. Replacement tracking uses the same immutable preview key as rendering and deduplication.

Protecting comparison sheets from one-off scans takes priority over minimizing replacement bookkeeping. Protection is relative rather than a promise of residency: capacity pressure can still evict a reused sheet. Queue membership, ordering, and any history of evicted keys are private worker state.

The promotion rule and queue allocation require selection before the replacement algorithm can be specified completely. Requests sharing a pending render job do not by themselves demonstrate reuse of a completed sheet.

### Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Cache replacement | 2Q | LRU; frequency-based eviction with aging | Editors interleave sequential screenings with repeated comparisons. Separating first-use sheets from reused sheets protects comparison working sets from scan traffic, justifying the extra queue bookkeeping and allocation tuning. LRU is simpler and adapts quickly to project switches but allows a scan to displace comparison sheets. Aged frequency tracking retains popular clips but adds counter maintenance and can retain a previous project's favorites too long. |

### Open questions

**Promotion rule**
- **Resident-hit variant:** promote a first-use sheet on a subsequent cache hit. This uses two resident queues and recognizes reuse immediately, but polling for a just-rendered sheet can look like comparison reuse.
- **History-based variant:** keep a bounded FIFO history of keys evicted from the first-use queue, without JPEG data; a request for a remembered key admits the rendered sheet to the reused queue. This distinguishes a return after eviction from immediate polling, but adds history bookkeeping and a history-size parameter. Hits in the resident first-use queue do not promote the sheet.

**Queue allocation**
- **3 GiB first-use / 9 GiB reused:** favors comparison retention, but shortens the window for detecting reuse during screenings.
- **6 GiB / 6 GiB:** gives screening sheets a longer reuse window, but leaves less capacity protected for comparisons.

These are candidate targets, not independent hard limits. Borrowing when one queue is underfilled and victim selection when admission needs space still need definition.

**The LLD edge-case probe also identified:**
1. What happens when one JPEG exceeds the entire cache budget?
2. How are concurrent admissions, hits, and promotions ordered to preserve the byte bound and queue membership?
3. What happens to a completed ticket when its sheet is evicted before retrieval?
4. With history-based promotion, when is eligibility determined and history consumed if rendering fails or history expires mid-render?
5. How are partial admission or cleanup failures ordered with deduplication removal and release of the rendering slot?

**For this review: which promotion variant and queue allocation do you want, and which numbered edge cases should we resolve now versus defer?** The 2Q selection itself is settled.