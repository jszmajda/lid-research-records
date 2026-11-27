## Phase 2 — Preview LLD review

Updated `docs/intent/previews/previews-design.md` and removed the “eviction policy remains open” statement from the HLD.

### 2Q design drafted

- **A1in:** probationary FIFO queue for first admissions, with a soft, worker-private target of **3 GiB (25%)**.
- **Am:** protected LRU queue for sheets requested again while resident in A1in. It can use capacity unused by A1in.
- **A1in hit:** promote the sheet to Am’s most-recently-used end.
- **Am hit:** move it to Am’s most-recently-used end.
- **Miss:** render successfully, then admit once at A1in’s tail.
- **Under capacity pressure:** evict A1in’s oldest entry when A1in occupies at least 3 GiB; otherwise evict Am’s LRU entry, falling back to A1in when Am is empty.
- Evicted sheets retain no replacement history; a later render starts again in A1in.
- The API, FIFO render queue, four-job concurrency limit, pending-ticket behavior, and 12 GiB total budget remain unchanged.
- LRU and aged-frequency eviction are recorded as rejected alternatives in the Decisions & Alternatives table. No separate decision document is needed for this node-local choice.

### Edge-case probe findings

Please resolve or defer these before I update the EARS specifications:

1. **Oversized sheet:** If a completed JPEG exceeds 12 GiB, should rendering succeed but skip caching and return the JPEG once, or should the request fail?
2. **Eviction during an active read:** Should an already-open JPEG remain readable until streaming finishes, with physical deletion deferred?
3. **Admission failure:** Should cache installation be best-effort—return the rendered JPEG even if caching fails—while preserving the existing evictions?
4. **Worker restart:** Should cached files and queue metadata survive/rebuild after restart, or should restart begin with an empty cache?
5. **Budget meaning:** May I state explicitly that 12 GiB counts JPEG payload bytes only, excluding filesystem rounding and replacement metadata?
6. **Configuration:** May the A1in target be startup-only configuration, validated to the range 0–12 GiB?

Reply with numbered decisions, or approve the design with your preferred handling of these gaps. I’ll stop here before Phase 3.