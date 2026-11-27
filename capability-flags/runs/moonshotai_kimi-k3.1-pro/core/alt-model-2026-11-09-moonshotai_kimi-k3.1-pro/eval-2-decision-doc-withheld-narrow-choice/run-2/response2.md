Yes—I think it earns a proper decision doc. Not merely because the discussion was long, but because a future maintainer could reasonably revisit 2Q in favor of simpler LRU or stronger frequency retention. Recording the workload criteria and trade-offs will keep that decision from being reopened without its original context.

I created `docs/intent/previews/decisions/eviction-policy.md`; the preview LLD will link to it from its Decisions & Alternatives table.

```markdown
---
node: previews
---

# Decision: Preview Cache Eviction Policy

## Context

The preview worker stores rendered contact sheets in a private cache bounded to 12 GiB of JPEG data. Editors alternate between long sequential screenings, which introduce many sheets that may never be requested again, and comparison sessions, which repeatedly revisit a smaller working set. Eviction determines how often expensive rendering is repeated, but the cache is not authoritative and no other component may depend on an entry remaining available.

The policy must preserve the existing preview API, render queue, preview-key format, and disk bound. The choice concerns only replacement bookkeeping inside the preview worker.

## Decision Elements

- **Scan resistance — major.** A long sequence of one-off screening requests should not displace the working set used for repeated comparisons.
- **Retention of reused sheets — major.** Sheets requested repeatedly should remain preferred candidates for retention over sheets seen only once.
- **Adaptation to changing working sets — moderate.** When editors switch projects or comparison sets, newly relevant sheets should be able to replace entries popular only in earlier sessions.
- **Bookkeeping cost — moderate.** Metadata updates and queue maintenance consume worker resources and add implementation complexity.
- **Operational tuning — moderate.** Policy parameters should be few, understandable, and adjustable without changing the preview interface.

## Options in the Domain

### Least Recently Used

**Description.** Maintain cached sheets in recency order. A cache hit makes its sheet most recently used; when space is needed, evict from the least-recently-used end. New sheets enter as the most recently used entries.

**Analysis.**

- **Scan resistance: weak.** Every screening sheet enters the same recency ordering as comparison sheets, so enough distinct requests can evict the entire comparison working set.
- **Retention of reused sheets: partial.** Recent reuse protects a sheet, but repeated use older than the latest screening sequence provides no additional protection.
- **Adaptation to changing working sets: strong.** New requests immediately influence replacement order, and stale entries age out without counters or decay.
- **Bookkeeping cost: strong.** One recency ordering and hit-time movement are sufficient.
- **Operational tuning: strong.** No queue split, counter half-life, or aging interval is required.

### Frequency-Based Eviction with Aging

**Description.** Maintain a request frequency for each cached sheet and periodically age counters so old popularity loses influence. When space is needed, prefer sheets with lower adjusted frequency, with recency available to break ties.

**Analysis.**

- **Scan resistance: strong.** One-off sheets accumulate little frequency and remain preferable victims while established comparison sheets retain higher counts.
- **Retention of reused sheets: strong.** Repeated requests directly increase retention priority until aging reduces the counts.
- **Adaptation to changing working sets: partial.** Aging eventually releases old favorites, but its interval and decay rate determine how long yesterday's working set continues to displace newly relevant sheets.
- **Bookkeeping cost: partial.** Hits update counters, and background or lazy aging adds work beyond recency maintenance.
- **Operational tuning: partial.** Counter representation, aging interval, decay behavior, and victim selection all require coherent tuning.

### 2Q

**Description.** Maintain separate queues for sheets admitted after a first request and sheets promoted after reuse. A first-use area absorbs sequential screening traffic; a reused area protects comparison sheets. A size split controls how much of the cache each area can influence, and entries move between areas when later requests demonstrate reuse.

**Analysis.**

- **Scan resistance: strong.** One-off screening entries remain confined to the first-use area rather than displacing the reused comparison working set.
- **Retention of reused sheets: strong.** A second request promotes a sheet into the area reserved for demonstrated reuse.
- **Adaptation to changing working sets: partial.** New sheets can enter without counters from old projects, but the queue split and replacement behavior determine how quickly the reused area turns over.
- **Bookkeeping cost: partial.** The worker maintains two queues and promotion state instead of one recency ordering.
- **Operational tuning: partial.** The size split must be tuned against observed screening and comparison workloads, although no counter-aging policy is needed.

## Selection

Use 2Q. Scan resistance and retention of reused sheets outweigh its additional queue bookkeeping because protecting comparison sheets during large screenings is the primary workload concern. It provides that protection without the stale-popularity risk and aging maintenance of frequency-based eviction. LRU remains the lower-cost policy, but its susceptibility to sequential scans gives up the behavior this cache most needs.

The preview worker will own both queues, their promotion metadata, and the size-split configuration privately. The fixed 12 GiB bound still applies to cached JPEG data as a whole. The preview API, render queue, deduplication behavior, and job-ticket semantics remain unchanged. The initial queue split and its tuning mechanism must be settled in the preview design and verified against representative screening and comparison workloads.
```

Please approve this decision doc and the preceding HLD update so I can proceed to the detailed 2Q preview LLD.