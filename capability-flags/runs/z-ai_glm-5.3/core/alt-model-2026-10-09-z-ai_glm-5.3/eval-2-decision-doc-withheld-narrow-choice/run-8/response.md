Phase 2 is drafted and probed. Here is the phase output for your review.

## What changed

- **HLD** (`docs/high-level-design.md`): the stale "eviction policy remains open" note is gone — Previews now reads "a private 12 GiB cache using 2Q replacement."
- **Previews LLD** (`docs/intent/previews/previews-design.md`): the design is finished around 2Q:
  - **A1 (screening buffer)** — FIFO, 25% of the budget (3 GiB, ~1,500 typical sheets). All fresh admissions land here; scans churn A1 without touching reused sheets.
  - **A2 (comparison set)** — LRU, up to 9 GiB. A sheet reaches A2 only on a second request while still cached; A2 hits refresh LRU position.
  - Byte-based budgets (not entry counts, since sheet sizes vary around 2 MiB), evict A1 head first, then A2 LRU tail only when A1 is empty; promotion moves bytes between budgets. Evicted sheets have no memory — no ghost list. The 25/75 split is configuration, tuned from pilot promotion rates.
  - The policy choice is recorded in a new **Decisions & Alternatives** table (2Q vs. LRU vs. aged-frequency, two-queue vs. ghost-list 2Q, bytes vs. counts, split value). Since the change is confined to the preview worker, a row in this table is the whole record — no separate decision doc.

Per the LID workflow I ran a blind edge-case probe on the draft. Genuine gaps found, with my suggested triage:

**Sharpened by the 2Q change — suggest fixing in the LLD now:**
1. A completed sheet larger than the A1 budget (or 12 GiB total) makes the admission rule unsatisfiable — no reject/skip-admission behavior is specified.
2. Does a deduplicated concurrent request count as the "second request" that promotes a sheet to A2, or does promotion require a post-admission hit? The A1/A2 population split depends on which reading holds.
3. Can an entry be evicted between the hit decision and the 200 being sent, or is hit-check→position-update→response atomic on the control thread?

**Pre-existing LLD gaps (not introduced by 2Q) — suggest recording as open questions, fixing in a later pass:**

4. What outcome do ticket-sharers receive when their shared render job fails? The 200/202/404 contract has no failure outcome.
5. Permanent render failure (corrupt source, not unknown revision) — retry loop with no client signal?
6. Is the FIFO render queue bounded? Overflow/backpressure unspecified.
7. Crash/restart: temp-file cleanup and whether cache index/budgets survive are unspecified.
8. Disk-full / I/O-error shapes during admission or render are undefined.
9. How is the renderer version chosen per request, and what happens to in-flight old-version jobs during an upgrade?
10. Is a 202 poll idempotent, and is there a ticket lifetime for abandoned clients?
11. Do temp render outputs count against any bound?

**No gaps found** in the eviction ordering itself or the split-configurability boundary.

Please review the LLD, and tell me: (a) which probe gaps to fix now vs. defer as open questions, and (b) whether to proceed to Phase 3 — drafting the EARS specs for the 2Q behavior (promotion, eviction order, budget bounds).