2Q is landed — the preview design is finished. Three files changed:

**HLD** (`docs/high-level-design.md`): the "eviction policy remains open" placeholder is now "a private 12 GiB cache using two-queue (2Q) replacement"; the fixed-interface goal no longer references "every eviction policy."

**LLD** (`docs/intent/previews/previews-design.md`), new "Two-Queue Replacement" section:
- **First-use queue** (FIFO, configurable share of the 12 GiB budget, default one quarter ≈ 3 GiB) and **reuse queue** (least-recently-reused first, remainder ≈ 9 GiB). Shares are fixed and sum to 12 GiB, so PREVIEW-004's global bound holds structurally.
- Completed sheets admit to the first-use queue; a 200 served from a first-use sheet promotes it to the reuse queue; a 200 from the reuse queue refreshes recency. 202 responses while a job is pending never affect placement, and queue movement never changes the response received.
- No ghost lists: an evicted key's history is discarded; a re-request is a first use.
- Decisions & Alternatives records 2Q over LRU (loses comparison sheets in sequential screenings) and frequency-with-aging (counter maintenance, retains yesterday's favorites), plus the shape/bounds/split choices. Deferred: calibrate the split against pilot hit rates.

**Specs** (`docs/intent/previews/previews-specs.md`): added PREVIEW-006..012 — admission placement, per-queue eviction order, promotion, recency refresh, configurable split, and the no-retained-history rule. PREVIEW-001..005 unchanged.

**Consistency report**: every LLD behavior has a spec and vice versa; no contradictions; queue terms are parenthetically defined so each line survives grep-standalone reading; LLD matches the HLD's privacy and fixed-interface tenets.

Two judgment points for you at this stop:

1. **Split default: 25% first-use / 75% reuse.** You called the split the thing you'll have to tune — this default favors protection (the reuse queue holds the comparison working set; ~1,500 one-off sheets absorb a screening burst). Confirm or adjust.
2. **Shape and a side effect of the hit rule.** I implemented the simplified two-queue form (no ghost directories) matching your "two queues and a size split" sketch — ghosts would only save one ~450 ms render for a re-requested evicted sheet. Also note: co-waiters on a pending job that retry after completion get 200s, so a sheet several editors waited on together promotes immediately. I'd call that correct (it's demonstrably hot), but say so if you'd rather co-waited requests not count toward promotion.

Once you approve, the next step is tests-first for PREVIEW-006..012 and then the code — nothing is implemented yet, all specs are active gaps.