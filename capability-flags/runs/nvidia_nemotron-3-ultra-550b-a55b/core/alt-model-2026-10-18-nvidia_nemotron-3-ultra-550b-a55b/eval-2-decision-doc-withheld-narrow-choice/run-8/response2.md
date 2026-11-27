Decision doc created and linked. Now back to **Phase 4 — Intent-narrowing edge audit**:

The six forks from my earlier analysis still need resolution before tests. The decision doc records *why* 2Q was chosen, but the specs need precision on these boundary behaviors:

---

**Fork 1: Admission when both queues at capacity targets**  
When a render completes and A1in=3 GiB, Am=9 GiB: does the new entry evict from A1in tail *before* admission, or from Am tail because A1in is "at or below" target?

**Fork 2: Promotion from A1in when Am at capacity**  
A1in entry accessed, must promote to Am head, but Am=9 GiB. Evict Am tail first, then promote? Or stall in A1in?

**Fork 3: Concurrent access to same A1in entry**  
Two requests hit same A1in entry concurrently. Both attempt promotion. Second finds it in Am — idempotent Am-head move, or race?

**Fork 4: Byte-size vs entry-count tracking**  
"3 GiB" and "9 GiB" targets — tracked by **total JPEG byte size** (variable per entry) or **entry count with size estimate**?

**Fork 5: Boundary "at or below 3 GiB" inclusivity**  
When A1in is *exactly* 3 GiB: "at or below" → evict from Am? Or "above target" → evict from A1in?

**Fork 6: Configurability of 25/75 split**  
Runtime config (hot-reloadable), build-time constant, or restart-required config file?

---

Please resolve each (pick a reading or add a narrowing spec line).