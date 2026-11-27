## Phase 2 — Preview LLD ready for review

Selected **2Q replacement** and updated:

- `docs/high-level-design.md` to identify 2Q as the preview cache policy.
- `docs/intent/previews/previews-design.md` with the design below.

### Revised private-cache design

The worker uses two queues within the shared 12 GiB JPEG budget:

- **A1in:** FIFO queue for first-time admissions, with a configurable byte threshold `Kin`, initially **3 GiB (25%)**.
- **Am:** LRU queue for sheets promoted by a cache hit while in A1in.

A hit in A1in promotes the sheet to Am; a hit in Am refreshes its recency. Sharing a pending render does not cause promotion. Evicted A1in keys leave no ghost history.

When space is needed, the worker evicts the oldest A1in entry while A1in exceeds `Kin`; otherwise it evicts Am’s LRU entry. `Kin` is a replacement threshold rather than a reserved partition. If a completed sheet cannot be cached, it is returned without caching.

The Decisions & Alternatives table records why 2Q was chosen over LRU and aged frequency, why there is no A1out ghost queue, and why the threshold uses bytes rather than entry counts.

### LLD edge-case probe

The independent probe found four gaps that should be resolved or explicitly deferred before EARS drafting:

1. **Eviction-queue exhaustion:** If Am is empty but A1in is at or below `Kin`, should eviction fall back to A1in so admission can continue?
2. **Uncached completed renders:** After earlier requests received a job ticket, what should a later poll return if the completed JPEG was returned to the original request but not cached?
3. **Concurrent cache transitions:** Should hits, promotions, admissions, and evictions be serialized so concurrent operations cannot exceed 12 GiB or place one key in both queues?
4. **Worker restart:** Should cached files and queue metadata be deleted, reconstructed as first-use entries, or persisted and restored?

Two further items are safe to defer:

5. Runtime changes and validation of `Kin`.
6. Detailed recovery from eviction or cache-admission I/O failures.

**Please approve the design and indicate how to handle gaps 1–4. My recommendation is to resolve all four in the LLD now and defer 5–6. Once approved, I’ll update the EARS specifications and stop for their review.**