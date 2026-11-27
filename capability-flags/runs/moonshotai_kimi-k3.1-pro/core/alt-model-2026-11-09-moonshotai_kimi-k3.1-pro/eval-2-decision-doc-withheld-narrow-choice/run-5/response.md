## Phase 2: Previews LLD review

I updated `docs/intent/previews/previews-design.md` and removed the stale “eviction policy remains open” note from the HLD. The review API and render queue remain unchanged.

The drafted design is:

> The worker renders one JPEG contact sheet per clip revision and renderer version. Long screenings introduce many one-use sheets; comparison sessions repeatedly revisit a smaller working set.
>
> The private cache holds at most 12 GiB of cached JPEG data, using two resident queues:
>
> - **A1in:** a FIFO probationary queue with a 3 GiB limit. Newly rendered sheets enter at its tail. A resident cache hit promotes the sheet to Am.
> - **Am:** an LRU queue with a 9 GiB limit for repeatedly requested sheets. Hits move sheets to its most-recently-used end.
>
> Before A1in admission, evict from its FIFO head until the sheet fits. Before promotion to Am, evict from Am’s LRU end until the promoted sheet fits. Unused capacity in one queue does not enlarge the other.
>
> Pending jobs and temporary output have no queue entries. Evicted entries leave no non-resident history. Sheets larger than A1in’s 3 GiB limit are returned without being cached. Duplicate render completion neither replaces cached bytes nor creates duplicate entries.
>
> Cache lookup, admission, promotion, and eviction transitions are serialized within the single preview worker.
>
> The Decisions & Alternatives table records 2Q over LRU and aged frequency eviction, and the initial 25%/75% split. Retuning that split remains deferred until workload measurements are available.

The independent edge-case probe found four gaps that block calling the LLD complete:

1. **Read versus eviction:** May eviction delete a JPEG while an earlier cache-hit response is still reading or streaming it?
2. **Publication ordering:** What is the exact order of file publication, queue insertion, byte accounting, and deduplication-entry removal when rendering finishes?
3. **Filesystem failures:** What resident state must remain after a partial admission, promotion, eviction, or deletion failure?
4. **Worker restart:** Are cache files and queue state discarded, persisted, or reconstructed after restart—and, if reconstructed, how are queue membership and ordering recovered?

Please confirm the **3 GiB A1in / 9 GiB Am split** and tell me whether to resolve all four gaps in the LLD or defer any of them. After your approval, I’ll proceed to the EARS updates.