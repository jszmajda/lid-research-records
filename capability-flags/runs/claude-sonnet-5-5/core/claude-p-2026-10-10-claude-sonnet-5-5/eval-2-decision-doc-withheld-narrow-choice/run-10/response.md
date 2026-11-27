I've drafted the 2Q choice into the previews design (Phase 2) and stopped there. I haven't touched the EARS specs, tests, or code.

**What changed**
- **`docs/intent/previews/previews-design.md`, Private Cache**: the open-policy paragraph is replaced with the 2Q mechanism:
  - a FIFO first-use queue for sheets rendered but not yet reused;
  - an LRU reused queue for sheets requested again;
  - a ghost list of recently evicted first-use keys, where a completed render whose key is on the list goes straight to the reused queue.
  - All three structures are private to the worker, and the 12 GiB bound applies to sheet data only.
- **Decisions & Alternatives**: one new row recording 2Q against LRU and aged frequency, with the rationale. I did not write a standalone decision doc, because the choice only affects the previews node and a row settles it for a cold reader.
- **`docs/high-level-design.md`**: I changed one line, "Its eviction policy remains open", to "Its eviction policy is 2Q", so the HLD isn't stale. The architecture and tenets are untouched, and the review API node needs no change.

**Gaps that are yours to settle** (also listed under Deferred in the LLD)
1. **Reuse while still in the first-use queue.** In classic 2Q, only a ghost-list hit promotes a sheet. If an editor opens a comparison sheet twice before it leaves the first-use queue, it stays first-use and a big screening can still evict it. The alternative is to promote on any repeat request after the render completes. Which do you want? This decides whether comparison sheets are protected in the case you care about. Concurrent requests that share one pending job should not count as reuse either way.
2. **Queue split and ghost list length.** At about 2 MiB per sheet, 12 GiB holds roughly 6,000 sheets, about one week's distinct clips. Do you want to fix a starting split (for example, first-use queue at 25% of the budget, ghost list at about half the cache's entry count) now, or leave it as a documented tunable and decide at implementation?
3. **Worker restart.** Does the cache and its queue state survive a restart? If the sheets persist but the queue order doesn't, what happens to them on startup?

Smaller gaps I'm not asking about unless you want them:
- Whether queue accounting is by bytes or by entry count.
- What happens if a sheet in the reused queue is evicted and then immediately re-requested.

Once you rule on these, I'll move to Phase 3 and draft the EARS specs (new PREVIEW IDs for the queue behaviors; PREVIEW-004 stays as the bound).