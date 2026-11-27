**Phase 4 — Intent-narrowing edge audit**

I've identified the following genuine forks in the 2Q specs that need your resolution before tests are written:

---

**Fork 1: Admission when both queues at capacity targets**  
*PREVIEW-006 + PREVIEW-009 interaction*  
When a render completes and the new entry must be admitted to A1in, but A1in is already at 3 GiB and Am at 9 GiB: does the new entry evict from A1in tail *before* admission (making room in A1in), or does it evict from Am tail because A1in is "at or below" its target?

**Fork 2: Promotion from A1in when Am at capacity**  
*PREVIEW-007 + PREVIEW-009 interaction*  
An A1in entry is accessed and must be promoted to Am head, but Am is at 9 GiB. Does the promotion evict from Am tail *first*, then move the entry? Or does the entry get "stuck" in A1in until Am has room?

**Fork 3: Concurrent access to same A1in entry**  
*PREVIEW-007*  
Two requests hit the same A1in entry concurrently. Both see it in A1in and both attempt promotion. Does the second request find it already in Am and do an Am-head move (idempotent), or does it double-promote / race?

**Fork 4: Byte-size vs entry-count tracking**  
*PREVIEW-009, PREVIEW-010*  
The specs say "3 GiB" and "9 GiB" targets — is queue capacity tracked by **total JPEG byte size** (variable per entry) or by **entry count with a size estimate**? A 25-entry A1in could be 1 GiB or 5 GiB depending on sheet sizes.

**Fork 5: Boundary "at or below 3 GiB" inclusivity**  
*PREVIEW-009*  
When A1in is *exactly* 3 GiB, is that "at or below" → evict from Am? Or "above target" → evict from A1in? The phrasing "at or below" suggests inclusive, but a fresh reader could read it either way.

**Fork 6: Configurability of 25/75 split**  
*PREVIEW-010*  
The design says the split "may be adjusted based on observed workload without changing the external interface." Is the split a **runtime config** (hot-reloadable), a **build-time constant**, or a **restart-required config file** value?

---

Please resolve each fork (pick a reading, or add a narrowing spec line). Once resolved, I'll proceed to Phase 5 (tests first).