Phase 2 done — 2Q is recorded in the previews LLD. Stopping here for your review before specs.

## What changed

**`docs/intent/previews/previews-design.md` — Private Cache**, now written as the design rather than an open question:

- **First-use queue** (FIFO, 3 GiB): every newly rendered sheet lands here. A hit here serves the sheet but does *not* extend its residency.
- **Reuse cache** (LRU, remaining 9 GiB): sheets with proven reuse; a hit refreshes recency.
- **Recent-eviction key list** (6,000 keys, no bytes): keys dropped from the first-use queue.
- **Admission**: key in the eviction list → straight into the reuse cache; otherwise → first-use queue.
- **Eviction**: first-use over its share → drop its oldest and record the key; otherwise → LRU tail of the reuse cache, recording nothing.
- Metadata is in-memory and rebuilt empty on restart; on-disk sheets stay valid and re-enter as first-use.

Three **Decisions & Alternatives** rows: the policy choice (LRU and aged-frequency named with why they were trimmed), the reuse signal, and metadata lifetime. Two deferred items: the three sizing values as pilot starting points, and whether operators get private policy counters.

**`docs/high-level-design.md`**: "Its eviction policy remains open" no longer true — now says the previews node owns its replacement policy; the interface goal is reworded to not reference "every eviction policy." No architectural change; the review API's contract is untouched, and nothing outside the worker reads the new structures.

I did not open a decision doc. The deliberation was long, but as it lands the choice sizes nothing outside this one node — every option kept the HTTP contract, queue concurrency, and disk budget identical — so a table row carries it and a standalone doc would just be a record of the argument.

## Two calls that are yours, not mine

1. **The reuse signal.** I wrote it as canonical 2Q: a hit *inside* the first-use queue does not promote; only a request arriving after first-use eviction (key-list hit) promotes to the reuse cache. This is what gives you the screening protection you asked for — but it means an editor who views a sheet twice within one screening pass still loses it. The looser reading (promote on any second request) is friendlier to short comparison bursts and weaker against scans. Confirm the strict version or I'll switch it.

2. **The 3 GiB / 9 GiB / 6,000-key split.** The key-list length is one full cache turnover of 2 MiB sheets, so "revisited within about a cacheful" counts as reuse. Reasonable as a start, genuinely a guess until you see real hit rates.

## LLD edge-case probe — gaps to triage

Pointed inside this component only; cross-spec composition waits for Phase 4.

1. **First-use queue empty but over-budget** — if the budget is breached while first-use is under its share and the reuse cache holds everything, eviction falls entirely on reuse. Fine, but unstated: should a single admission ever evict from both?
2. **Oversized single sheet** — a sheet larger than the 3 GiB first-use share. Admit it directly to reuse, reject it, or let it transiently exceed the share?
3. **Renderer-version bump** — all keys change at once, so the entire cache becomes unreachable-but-resident and drains only through normal eviction. Do stale-version entries get dropped eagerly?
4. **Key-list hit for a now-unknown revision** — 404 path, no render, no admission. Is the stale key dropped from the list or left to age out?
5. **Concurrent admissions** — up to four render jobs complete independently; queue bookkeeping and the 12 GiB check need to be serialized. Unstated in the doc.
6. **Pending requests and recency** — a 202 response touches no cache entry, so a long-pending sheet gains no recency. Intended, currently implicit.
7. **Eviction of a sheet with a pending job for the same key** — can a key be in the dedup map and the key list at once, and does that interact?

Tell me which of these to fix in the LLD and which to park as open questions, plus your ruling on the two calls above — then I'll move to Phase 3 and update the PREVIEW specs (PREVIEW-004 splits, and admission/promotion/non-promotion need new IDs).