## Phase 2: Preview Design

Updated:

- `docs/intent/previews/previews-design.md`
- `docs/high-level-design.md` to remove the stale “eviction policy remains open” statement

The draft now specifies:

- Resident 2Q with a probationary FIFO and protected LRU
- Promotion on a probationary cache hit
- LRU refresh on a protected cache hit
- Byte-based accounting
- Initial 3 GiB probationary / 9 GiB protected split
- FIFO probationary eviction and LRU protected eviction
- Worker-private tuning and replacement metadata
- Empty policy state and orphan-file cleanup after restart
- No preview API or render-queue changes

The LLD edge-case probe found four cache-design gaps worth resolving before EARS:

1. A cache hit can race with eviction while the JPEG is being opened or streamed.
2. Restart behavior for issued tickets, active renders, and requests arriving during cleanup is unspecified.
3. Admission or deletion failures do not define whether the completed sheet is served uncached or how disk usage remains accounted.
4. An oversized uncached result has no defined lifetime for waiting or subsequent requests.

The probe also found broader pre-existing rendering concerns around failed-job responses, render timeouts, temporary-storage limits, and corrupt source/output handling. These can be handled now or explicitly deferred.

This 2Q choice remains sufficiently contestable that a future maintainer could reasonably reopen it. Would you prefer a full decision document recording the alternatives and criteria, or is the Decisions & Alternatives row sufficient?

Please review the design and reply with:

1. Approval or changes to the resident 2Q mechanics and 3/9 GiB split.
2. Which probe gaps should be resolved now versus deferred.
3. Full decision document or table row only.