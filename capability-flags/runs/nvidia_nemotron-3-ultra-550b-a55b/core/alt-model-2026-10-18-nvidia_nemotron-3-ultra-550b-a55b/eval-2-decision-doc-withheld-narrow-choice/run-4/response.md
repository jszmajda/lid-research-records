**Phase 4 — Intent-Narrowing Edge Audit**

I've identified the following forks that need your resolution:

### Cross-Spec (within previews)

**Fork 1: Promotion when entry already in A1**
- PREVIEW-006 says "promote from Am to head of A1"
- Option A: If already in A1, move to head (LRU refresh on re-access)
- Option B: PREVIEW-006 only applies when in Am; if already in A1, no-op
- *Which behavior?*

**Fork 2: Eviction granularity at admission**
- LLD says: 1) evict Am tail until ≤3 GiB, 2) if Am OK but A1 >9 GiB, evict A1 tail until ≤9 GiB, 3) admit
- Option A: Follow this strict order (targets are hard limits enforced at admission)
- Option B: Evict just enough total bytes to fit the new entry (proportional from both queues)
- *Confirm LLD's strict order (Option A)?*

**Fork 3: Deduplicated completion → queue placement**
- Shared render job completes → entry goes to Am head (PREVIEW-009), first hit promotes to A1 (PREVIEW-006)
- *Confirm no special handling needed?*

### Per-Spec Divergence Probes

**PREVIEW-006 "promote"**: Move (remove from Am, add to A1 head) vs Copy (exists in both)?
- *LLD implies move. Confirm?*

**PREVIEW-007/008 targets**: Hard limits enforced at admission vs soft with hysteresis?
- *LLD implies hard enforcement at admission. Confirm?*

**PREVIEW-009 "Am head"**: Newest admission (FIFO: head=newest, tail=oldest=eviction candidate) vs LRU-style head?
- *2Q Am is FIFO. Confirm head = newest admission?*

### Cross-Segment (previews ↔ review-api)

**Fork 4**: Review API preserves 200/202/404, knows nothing of 2Q internals — aligned with tenet "Keep cache paths and replacement bookkeeping private." *Confirm no action needed?*

Please resolve forks 1–3 and confirm 4. I'll then update the LLD and specs with the resolutions.