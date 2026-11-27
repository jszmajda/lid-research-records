## Phase 2: Preview Design

Updated `docs/intent/previews/previews-design.md` with:

- FIFO `A1in`, LRU `Am`, and bounded ghost `A1out` queues.
- Promotion on a second request, including ghost hits after probationary eviction.
- An initial 3 GiB probationary target and 6,144-key ghost limit, both privately tunable.
- Byte-based victim selection preserving the 12 GiB JPEG limit.
- Conservative startup recovery that does not persist protected status.
- A Decisions & Alternatives row recording why 2Q was selected.

I also removed the HLD’s stale statement that eviction remained open. The worker boundary and external architecture are unchanged.

The required LLD edge probe found these unresolved cases:

1. What should happen if one rendered JPEG exceeds 12 GiB?
2. If `Am` is empty but more space is needed, may eviction fall back to the oldest `A1in` entry?
3. Should ghost-hit promotion be fixed when the request arrives, even if the ghost record is trimmed before rendering completes?
4. How should startup handle corrupt or missing JPEGs, orphan files, stale temporary output, or an over-budget index?
5. What atomicity and recovery rules should apply if cache admission or index persistence fails?
6. Should the render queue have a pending-job limit, timeout, or overload response?
7. What is the lifecycle of failed, completed, or pre-restart job tickets?

Please review the design and indicate which gaps should be resolved now versus deferred. Once you approve Phase 2, I’ll update the EARS specifications.