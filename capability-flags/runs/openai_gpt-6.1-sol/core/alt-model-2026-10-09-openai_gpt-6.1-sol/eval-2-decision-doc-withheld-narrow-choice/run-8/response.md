**2Q is recorded in `docs/intent/previews/previews-design.md`, with the scan-protection rationale and alternatives in its Decisions & Alternatives table.** This choice is local to the preview cache, so a table row captures it without a separate decision document.

The HLD, preview specifications, and review API design are coherent with the choice. I also replaced the HLD’s stale “eviction policy remains open” sentence with a pointer to the preview design. `git diff --check` passes.

## Phase 2 — Preview design additions for review

### 2Q Replacement

Use 2Q to separate first-use sheets from sheets with demonstrated reuse. A first-use resident queue absorbs one-off screening traffic; a reused resident queue retains the comparison working set. Admission and replacement operate on the full preview key: clip ID, immutable revision, and renderer version.

The policy prioritizes retention of reused comparison sheets during sequential screenings over minimal replacement bookkeeping. Protection is relative, not pinning: both queues remain subject to the total 12 GiB JPEG budget, and comparison sheets can still be evicted under pressure.

Queue membership, ordering, and any reuse-history metadata are private worker state. Replacement does not alter the HTTP outcomes, FIFO render scheduling, four-job concurrency limit, or pending-job deduplication. Pending jobs are not resident cache entries; completed JPEGs enter replacement tracking at cache admission.

The reuse qualification rule and queue allocation are open design choices. They determine the precise promotion and victim-selection transitions and must be resolved before specifying those behaviors.

### Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Private cache replacement | 2Q | LRU; frequency-based eviction with aging | Separating first-use traffic from reused sheets protects the comparison working set during long sequential screenings. The extra queue bookkeeping and allocation tuning are acceptable costs. LRU offers lower bookkeeping and quick adaptation to project switches but allows scans to displace useful comparison sheets. Aged frequency counts retain popular clips but require counter maintenance and aging, and can retain yesterday’s favorites too long. The choice is local to the preview cache. |

### Open Questions & Future Decisions

1. **Reuse qualification:** Should a second request while a sheet is resident promote it to the reused queue, or should full 2Q retain a bounded history of evicted first-use keys and qualify reuse through that history? Resident-hit promotion recognizes immediate comparisons with less metadata; eviction-history qualification also recognizes returns after eviction, at the cost of a third, metadata-only queue and its own bound.
2. **Queue allocation:** What share of the JPEG budget should be targeted at first-use entries, and may either queue borrow unused space? A smaller first-use share gives reused sheets more scan protection but less room for new comparison candidates; a larger share favors recent screenings and adaptation to new projects. Accounting must use actual JPEG bytes rather than the typical sheet size.
3. **Demand versus polling:** Which requests count as evidence of reuse? Concurrent misses and repeated pending-ticket requests can represent one viewing attempt, whereas requests for a resident sheet can represent either a new comparison or a retried delivery. The policy needs an explicit qualification rule consistent with the fixed request interface.
4. **Oversized output:** How should a completed JPEG larger than the entire cache budget be delivered without admission? The existing admission rule cannot accommodate such an entry, and its delivery lifecycle must preserve the ready/pending contract.
5. **Worker restart:** Should replacement metadata reset on restart, with cached JPEGs reconstructed as first-use entries, or persist with the files? Resetting reduces recovery bookkeeping; persistence retains reuse protection across restarts but requires a recovery rule for missing files and stale metadata.

## Edge-case probe

The LLD-level probe also found these gaps for your triage:

6. What response and ticket lifecycle follow a failed render for a known revision?
7. What happens when a request arrives between render completion, cache admission, deduplication cleanup, and temporary-file removal?
8. How are simultaneous admissions coordinated to preserve the 12 GiB limit?
9. What happens when eviction overlaps delivery of a JPEG?
10. What happens when an old completed ticket is retried after its sheet has been evicted?
11. What happens when cache writes, eviction, or temporary-file cleanup fail?

**For the design review, please choose the reuse rule in question 1 and the allocation approach in question 2, then identify which remaining gaps to resolve now versus defer.** These are details within the selected 2Q design; your choice of eviction policy is recorded.