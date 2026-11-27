**Phase 2: Preview Design**
Updated `docs/intent/previews/previews-design.md` with:

- Byte-bounded 2Q replacement.
- A 3 GiB FIFO `recent` queue for first-use sheets.
- An LRU `frequent` queue using remaining cache capacity.
- A key-only FIFO `ghost` queue capped at 6,144 entries.
- Promotion rules for repeated and ghost-history requests.
- Eviction order, oversized-sheet behavior, queue invariants, and restart behavior.
- A Decisions & Alternatives row recording why 2Q was chosen over LRU and aged frequency.
- Deferred tuning of the queue split based on pilot telemetry.

I also removed the stale “eviction policy remains open” statement from `docs/high-level-design.md`. No API or review-segment change is proposed.

The required edge-case probe found these unresolved design questions:

1. Should a sheet between 3 GiB and 12 GiB bypass `recent`, enter `frequent`, or remain uncached?
2. On restart, should rebuilding cached sheets immediately evict down to the 3 GiB `recent` limit, or temporarily allow all surviving sheets in `recent`?
3. Should repeated requests while a render is pending count as reuse? Counting them could promote every sheet merely because browsers poll.
4. If cache publication or eviction fails, should the rendered sheet still be served without caching, or should the request fail?
5. Should active streams hold an entry against eviction, or may eviction unlink a file while an existing stream finishes?
6. Should crash recovery and cache corruption handling be specified now, including partial files, obsolete renderer versions, and abandoned temporary output?
7. Should pending render work have a queue limit and overload response, or is that deferred beyond the pilot?
8. The current API defines `200`, `202`, and `404`, but not a terminal render-failure outcome. Should that contract be resolved now or deferred?

Please review the design and reply with numbered decisions for these gaps, including which should be fixed in the LLD versus deferred. I’ll then revise Phase 2 before drafting the EARS changes.