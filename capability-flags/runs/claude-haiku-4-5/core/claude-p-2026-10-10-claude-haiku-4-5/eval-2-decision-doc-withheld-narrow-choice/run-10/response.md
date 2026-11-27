Now let me surface the Phase 4 intent-narrowing edge audit. I've identified several potential divergences in the 2Q spec that need clarification before implementing tests:

**Phase 4: Intent-Narrowing Edge Audit**

I've documented the 2Q policy and expanded the EARS specs, but found these divergences that affect how the implementation will behave:

1. **A1→Am Promotion Timing**: PREVIEW-007 says "when a request hits an entry in A1, promote it to Am," but doesn't specify whether this happens synchronously (before returning the response) or asynchronously. Also, the spec currently says "reused within their A1 residence time" in the design but the spec doesn't formalize what "residence time" means — is it time-based or eviction-based?

2. **Direct-to-Am Insertion**: PREVIEW-008 says new entries go to A1 unless they don't fit, then to Am. But what if A1 has space but Am is nearly full? Does the "fit within A1's size limit" check account for Am's capacity, or only A1's 3 GiB?

3. **A1 Eviction + Size Enforcement**: PREVIEW-004 and PREVIEW-009 both govern eviction, but the interaction is ambiguous: if A1 is full and we get a cache miss that needs to go to A1, do we evict from A1 first (per PREVIEW-009) then check if the new entry fits (per PREVIEW-008), or do we refuse the A1 insert and try Am directly?

4. **Promotion as LRU Touch**: When an entry is promoted from A1 to Am, does it enter Am as the most-recently-used item (resetting its LRU position), or does it inherit its access time from A1? This affects how long it stays in Am.

5. **Deduplication Across Queues**: The design mentions deduplication by cache key, but doesn't specify: if a request is pending and the completed preview lands, which queue (A1 or Am) does it enter? If it's re-accessed before A1 eviction, promotion to Am happens — but what if the dedup map references it before it's been placed in a queue?

Should I resolve these with you now, or would you prefer I make reasonable default choices and you can override them at the tests/code stage?