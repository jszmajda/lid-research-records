## Phase 2 — Preview LLD draft

The HLD now identifies 2Q as the preview cache’s eviction policy. The preview API and render queue remain unchanged.

### Previews Design

#### Context

The worker renders one JPEG contact sheet per clip revision and renderer version. Long screenings introduce many one-use sheets; comparison sessions repeatedly revisit a smaller working set. The mix varies by production, so no eviction policy is best for every observed workload.

#### Architecture

Expose `GET /internal/previews/{clip-id}/{revision}` with three outcomes: 200 and JPEG bytes, 202 and a job ticket with a two-second retry interval, or 404 for an unknown revision. This contract is fixed regardless of cache eviction policy.

Use a FIFO render queue with at most four active rendering jobs. Cache entries and all replacement-policy metadata belong exclusively to this worker. Other nodes do not access files, pin previews, inspect policy counters, or depend on entries remaining warm.

#### Rendering and Deduplication

Resolve the immutable source revision before rendering. The cache key includes clip ID, revision, and renderer version. Concurrent misses for one key share a job ticket. Once rendering completes, subsequent requests can receive the JPEG directly. Failed jobs are removed from the deduplication map so a later request can retry.

#### Private Cache

Cached JPEG data may occupy at most 12 GiB. Before admitting a completed sheet, evict enough existing sheets to remain within that bound. Temporary render output is kept separately and removed on completion or failure. Eviction never deletes source footage or changes job-ticket semantics.

##### 2Q Replacement

The cache uses 2Q replacement with two queues of resident sheets:

- **A1in** holds newly admitted sheets in FIFO order. Its byte budget is the configurable first-use share of the 12 GiB cache.
- **Am** holds sheets requested again after admission in least-recently-used order. Its byte budget is the remainder of the cache.

A completed sheet enters the tail of A1in after its first render. A cache hit in A1in promotes that sheet to the most-recent end of Am. A cache hit in Am moves that sheet to the most-recent end of Am. A sheet therefore needs a second request before it gains scan protection; repeated requests while its first render is pending do not by themselves promote it.

When admission requires space, remove sheets from the head of A1in first, then from the least-recent end of Am when A1in is empty. Enforce both the A1in byte budget and the overall 12 GiB byte budget: admitting to A1in evicts from A1in until the new sheet fits its budget, while promoting to Am evicts from A1in and then Am until the combined cache fits. Eviction removes only resident cache entries; pending jobs and their deduplication tickets are unaffected.

The initial A1in byte budget and any later tuning are operational configuration of the preview worker. Neither the split nor queue metadata is visible through the preview API or render queue.

#### Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Cache replacement policy | 2Q with FIFO A1in and LRU Am | LRU; frequency-based eviction with aging | 2Q keeps one-off screening sheets from displacing comparison sheets that have been requested again. It accepts more queue bookkeeping than LRU while avoiding frequency-counter maintenance and stale popularity after editors switch projects. |
| Queue budgets | Configurable A1in byte share within the fixed 12 GiB total | Fixed entry counts; independently sized queues | Sheets vary in size, so byte budgets enforce the disk bound directly. A single total budget preserves the existing cache limit while leaving the first-use share tunable. |
| Replacement metadata scope | Private to the preview worker | Exposing policy state through the preview API or render queue | Replacement is a worker-internal optimization; external behavior remains limited to ready, pending, and unknown-revision outcomes. |

#### Open Questions & Future Decisions

**Resolved**

1. Use 2Q to protect reused comparison sheets during long sequential screenings.
2. Keep the preview API, pending-job protocol, render queue, and 12 GiB total cache budget unchanged.

**Deferred**

1. Select and validate the initial A1in byte share using representative screening and comparison workloads.
2. Define admission behavior for a single completed sheet larger than the cache can hold.

### Edge-case probe

The independent probe found these gaps for your triage:

1. If a sheet fits within 12 GiB but exceeds the A1in budget, should it bypass caching, enter Am, or temporarily exceed A1in?
2. Promotion does not increase total cached bytes, so the current eviction-on-promotion wording appears inconsistent. Should promotion instead enforce an Am budget—and, if so, in what eviction order?
3. Can the A1in share be retuned live? If so, should excess entries be evicted immediately or lazily, and are 0% and 100% valid shares?
4. If a request arrives after rendering but before cache admission completes, should it wait, reuse the ticket, or receive the JPEG directly—and can that request promote the sheet?
5. Should concurrent queue transitions be atomic, with A1in order determined by cache-admission commit order?
6. May eviction remove a sheet whose JPEG response is still streaming, provided the active response remains valid?

Please resolve or defer these gaps and approve or amend the LLD. Then I’ll proceed to the EARS specifications.