Recorded **2Q** in `docs/intent/previews/previews-design.md`. Its rationale belongs in the preview LLD’s Decisions & Alternatives table: this choice is local to the cache, and a row captures why scan protection outweighs extra bookkeeping.

The pre-flight found the existing architecture and specifications compatible with that choice. I also removed the HLD’s stale statement that eviction policy remains open. `git diff --check` passes.

## Preview design additions for review

### 2Q replacement

Use 2Q to separate first-use sheets from sheets with demonstrated reuse. Screening scans primarily compete for first-use space, reducing their ability to displace the comparison working set. The extra replacement bookkeeping is an accepted cost of this protection; retention of any particular sheet is not guaranteed.

The first-use resident queue is FIFO. The reused resident queue is LRU: requests for a sheet already in that queue refresh its recency. Queue membership uses the complete preview key, including renderer version, so different revisions or renderer versions do not inherit one another’s reuse history.

The 12 GiB limit applies to the combined JPEG bytes in both resident queues. Accounting uses actual JPEG sizes rather than assuming every sheet is the typical 2 MiB. Queue targets guide replacement within that single budget. Replacement updates remain private to the worker and accompany cache lookup, admission, and eviction.

The promotion rule and queue targets need explicit selection. A resident second-hit variant promotes a first-use sheet on a subsequent cache hit. Full 2Q instead keeps bounded metadata for recently evicted first-use keys and promotes a sheet when one of those keys is requested and rendered again. Those choices differ in how repeated polling and nearby screening requests influence protection.

### Decisions & Alternatives

| Decision | Chosen | Alternatives considered | Rationale |
|---|---|---|---|
| Cache replacement policy | 2Q | LRU; frequency-based eviction with aging | Protecting reused comparison sheets during long sequential screenings outweighs maintaining separate queues and tuning their split. LRU is cheaper and adapts quickly to project switches but permits scan pollution. Aged frequency counts retain popular clips but require counter maintenance and can retain yesterday’s favorites too long. The policy affects only the worker’s private cache bookkeeping. |

### Open questions from the design probe

1. **Promotion:** Does reuse mean a second resident hit, or a request for a recently evicted first-use key? For full 2Q, how large is the metadata-only history?
2. **Queue split:** What initial byte target goes to first-use sheets? Can queues borrow unused capacity, and how are unequal-size victims selected?
3. **Reuse accounting:** Do browser retries and concurrent requests immediately after render completion count as reuse?
4. **Restart:** Does queue history survive? If JPEGs survive, how are sizes and membership reconciled before serving requests?
5. **Oversized sheets:** How is a JPEG larger than 12 GiB served without cache admission or a permanently pending ticket?
6. **Concurrency:** Which lookup, accounting, eviction, admission, and deduplication transitions are atomic?
7. **History lifecycle:** For full 2Q, when is promotion eligibility established and history consumed? What happens if history expires during rendering or rendering fails?
8. **Delivery and tickets:** What happens if a sheet is evicted before a pending requester retries or while its JPEG is being sent?
9. **Failures:** What response and ticket state represent render or cache-file failures, and when are temporary output and deduplication state released?

**Please review this LLD draft and triage the numbered gaps: which should we resolve now, and which should remain deferred?** The policy selection is recorded; the next phase is the EARS update after your design approval.