I updated the preview LLD to 2Q. The HLD line that called eviction “open” now records 2Q as well.

**What the design now specifies (`docs/intent/previews/previews-design.md`)**
- Probation (A1): FIFO, 3 GiB target (25% of the cache).
- Protected (Am): LRU, may use the remaining capacity.
- Probation history (A1out): key-only, defaults to 8,192 keys; no JPEG data.
- First-use sheets enter probation; a request finding a sheet in probation promotes it; a history hit admits directly to protected; protected hits refresh recency.
- Under pressure, oldest probation entries are evicted down to the 3 GiB target, then LRU protected entries. Probation evictions enter history; protected evictions do not.
- Pending-render retries do not count as reuse.
- The choice, with LRU and aged-frequency alternatives, is recorded in Decisions & Alternatives. Tuning the split and restart metadata rebuild are deferred.

**LLD edge-case probe — gaps I have not resolved for you**

2Q mechanics:
1. Promotion when protected has no room — evict protected, or allow temporary overcommit?
2. History-hit admission — is the sheet re-rendered first, and does its admission still run the probation-first eviction pass?
3. Key resident in probation and also in history — which wins, and is the history entry pruned?
4. History refresh and bulk scans — can one large scan flush the keys needed for later promotions?
5. Does the request that completes a render count as reuse? A post-completion retry could otherwise promote a first-use sheet.
6. Is the 3 GiB probation target only an eviction-pressure threshold, or a hard cap while total occupancy is below 12 GiB?
7. Degenerate configuration — probation target ≥ 12 GiB, history bound 0, or a one-sheet cache.

Accounting:
8. Is charged size JPEG bytes or decoded size, when is it counted (before or after temp-to-cache move), is the bound strict, and what happens to a sheet larger than the probation target or 12 GiB?
9. Does 12 GiB include temporary render output and metadata? Four active renders add peak usage beyond the resident sheets.
10. Duplicate render of an already-resident key — replace, double-count, or reject?

Concurrency and pending protocol:
11. Concurrent promotion versus admission eviction, and concurrent completions that each compute eviction independently.
12. The window between a job leaving the deduplication map and its sheet being admitted.
13. Ticket identity and lifetime across job removal, eviction, and restart; permanent render failure currently leaves ticket holders retrying 202 indefinitely.
14. Failure versus unknown revision, and serving a cached sheet for a since-removed revision.

Restart:
15. If JPEGs persist but 2Q metadata is lost, which queue do rebuilt entries enter?
16. At startup, are orphan JPEGs counted and evicted if already over the limit, and are interrupted temp files and in-flight tickets cleaned up?

**Suggested triage:** fold items 1–10 into the LLD now; defer concurrency atomicity and restart recovery as implementation-phase questions; treat items 13–14 as a separate pending-job concern rather than expanding this eviction change.

Do you approve the 2Q LLD, and do you agree with that triage? Once you confirm, I’ll apply the LLD refinements and draft the EARS specs.