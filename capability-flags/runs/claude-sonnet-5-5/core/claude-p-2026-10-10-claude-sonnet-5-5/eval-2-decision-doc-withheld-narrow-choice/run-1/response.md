2Q is recorded in the preview LLD, and the design is at the LLD stop (Phase 2). No specs, tests, or code are written yet.

## What changed

- **`docs/intent/previews/previews-design.md`**
  - The open "eviction policy" paragraph is replaced by a **Replacement Policy (2Q)** section.
  - **First-use queue:** FIFO of sheets that have not shown reuse.
  - **Reused queue:** LRU of sheets that have shown reuse.
  - **Ghost list:** keys only, no JPEG data, of sheets recently evicted from the first-use queue. A sheet whose key is in the ghost list when it is re-admitted goes straight to the reused queue.
  - **Size split:** the first-use queue is capped at a configured fraction of the 12 GiB budget, measured in bytes.
  - **Eviction:** it runs before admission. It evicts from the first-use head while that queue is over its fraction, otherwise from the LRU end of the reused queue.
  - **Polling:** 202 pending-response polling does not count as a cache hit.
  - **Decisions & Alternatives table:** it records 2Q against LRU and aged frequency, and bytes against entry count for the split.
  - **Deferred questions:** the initial split fraction and ghost-list length, and restart persistence.
  - I also dropped the Context line saying no policy is best for every workload, since it was stale.
- **`docs/high-level-design.md`**: one wording fix, "eviction policy remains open" becomes "with 2Q replacement". The architecture is unchanged and the tenets are respected, because all bookkeeping stays inside the worker.

The Review API node and the HTTP contract are untouched, so nothing crosses a segment boundary.

I did not write a decision doc. The choice affects only the previews node, so a table row is enough.

## Please rule on these

1. **First-use queue fraction.** I left the number out of the LLD rather than pick it for you. Classic 2Q uses about 25% for the first-use queue, and about 50% of the entry count for the ghost list. Do you want 25% as the starting value, or something else?
2. **What counts as reuse.** I drafted it so that only a ghost-list hit promotes a sheet to the reused queue. A hit while the sheet is still in the first-use queue leaves it where it is, as in classic 2Q. The alternative is to promote on any second cache hit, which protects a comparison sheet that is re-opened soon after its first view. Which do you want?
3. **Restart behavior.** Should queue and ghost state survive a worker restart, or start empty? The cache files and the queues must not disagree after a restart, so the answer shapes the specs.
4. **Bytes versus entry count for the split.** I chose bytes because the 12 GiB bound is in bytes. Sheets vary in size, so tell me if you would rather count entries.

## Edge-case probe

- **Ghost list length:** if it is too short, a sheet evicted during a big screening is forgotten before the editor returns to it. That is the main tuning risk.
- **Both queues empty:** a single sheet larger than the whole budget cannot be admitted. I have not decided whether that is an error or a skip.
- **Re-render after eviction:** two concurrent requests for a ghost-listed key share one job, and the admission should happen once. I expect the existing deduplication specs to cover this, but I'll confirm in Phase 4.

Reply with numbered answers (or "approved" plus your picks for 1–4). Phase 3 then drafts the EARS specs under the `PREVIEW-` prefix.