Running LLD-level edge-case probe for the 2Q eviction design:

**What happens when...**

1. **A sheet in A1 receives multiple access requests before promotion completes?** (Could concurrent hits to the same A1 entry cause duplicate promotions or queue corruption?)

2. **A single rendered sheet exceeds the entire A1 budget (3 GiB)?** (The admission rule says "evict A1's oldest entry" but doesn't handle the case where one sheet is bigger than the entire partition.)

3. **A promotion from A1 to Am requires evicting from Am, and the LRU entry in Am is the only other cached sheet?** (Edge case for the reused-set size — does 2Q still provide value when Am has only one entry?)

4. **The queue size split is adjusted while the cache is running?** (If patterns shift and we tune from 25/75 to 10/90, how do existing entries rebalance across the new boundaries? Or is this a restart-required config change?)

5. **An access hits a sheet that's currently being promoted from A1 to Am?** (State during transition — is the sheet considered in A1, in Am, or neither? Could a concurrent access see it as missing?)

6. **Eviction fails (disk full, permission error) when trying to make room for admission or promotion?** (The render already completed; backing out the job ticket might confuse waiting clients.)

7. **Size accounting: is "A1 full" measured by sum of file sizes >= 3 GiB, or by some other metric?** (The spec says "cached JPEG data may occupy at most 12 GiB" but doesn't specify whether each partition checks bytes-on-disk, in-memory sizes, or entry count.)

8. **A sheet is requested after being evicted from A1 (never promoted) — does it start over in A1, or is there any record of the prior eviction?** (Pure 2Q has no memory of evicted A1 entries, but confirming this is the intent.)

9. **The render queue has four active jobs, all rendering sheets that will be admitted to A1 — could a burst of completions cause cascading A1 evictions?** (Probably fine, but worth confirming the eviction loop handles a batch of admissions correctly.)

10. **Cache key collision: two different clip revisions hash to the same key?** (Unlikely if the key is `{clip-id}/{revision}/{renderer-version}`, but the collision-handling isn't specified.)

Which of these gaps should I address in the LLD, and which are acceptable as implementation details?