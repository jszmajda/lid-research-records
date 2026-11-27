2Q is now written into the preview design and ready for your review. It is recorded as a Decisions row in the previews design, not a separate decision doc, because the choice stays inside the preview worker. Nothing is committed; the specs, tests and code wait on your approval of this design.

## What changed

- **`docs/high-level-design.md`**: one line. The Previews entry now reads "a private 12 GiB cache with 2Q eviction" in place of "Its eviction policy remains open."
- **`docs/intent/previews/previews-design.md`**: the open-policy paragraph is replaced by a new **Eviction** section, a **Decisions & Alternatives** table and two deferred questions.
- **Review API**: untouched. The HTTP contract, FIFO render queue, four-job limit and 12 GiB bound are all as they were.

## The eviction design as drafted

- **First-use queue**: FIFO by admission, holding sheets not yet shown to be reused. Its share is 3 GiB (25% of the bound, about 1,500 typical sheets).
- **Reused queue**: LRU by most recent request, using the rest of the cache.
- **Evicted-key list**: keys only, no JPEG data, for the last 3,000 sheets evicted from the first-use queue. It does not count toward the 12 GiB.
- **Admission**: a completed sheet whose key is in the evicted-key list goes to the reused queue; any other goes to the tail of the first-use queue.
- **Requests for cached sheets**: a request for a reused-queue sheet moves it to the most-recent end. A request for a first-use sheet changes nothing.
- **Choosing a victim**: if the first-use queue is over its share, or the reused queue is empty, evict the oldest first-use sheet and remember its key. Otherwise evict the least recently requested reused sheet.
- **Tuning**: the 3 GiB share and the 3,000-key length are worker configuration read at startup, as starting values.

## Three things I need from you

1. **Promotion rule.** This is the one place the draft goes beyond last session's sketch: it adds the evicted-key list as a third structure.
   - **Why:** every rendered sheet is requested again about two seconds later by the browser's retry of its 202. The worker cannot tell that retry from a deliberate revisit. If any second request promoted a sheet, a long screening would promote everything it touched, and the comparison sheets would lose their protection.
   - **Cost:** a comparison sheet takes one extra render of about 450 ms the first time a screening pushes it out. After that it stays in the reused queue.
   - **Alternative:** promote on a second request while the sheet is still in the first-use queue. That needs no key list but is defeated by the retry, unless we add a time window, which is another parameter to tune.
   - I recommend the drafted rule. Confirm or pick the alternative.

2. **Starting values.** 25% for the first-use share and 3,000 keys are conventional 2Q starting points, not measured on your traffic. Say so if you want different numbers.

3. **Worker restart.** The design does not say whether queue membership and the evicted-key list survive a restart. The simple answer is to rebuild from the files on disk with every sheet starting in the first-use queue, which costs the comparison sheets their protection until they are re-promoted. I left this deferred. Tell me if you want it settled now.

## Gaps I checked that needed no change

- A failed render admits nothing and touches no queue.
- A single sheet (about 2 MiB) cannot exceed the first-use share.
- Sheets from an old renderer version are never requested again and age out of either queue.

Once you approve or correct the design, the next step is the EARS specs. `PREVIEW-004` will be narrowed and new lines added for admission, promotion and victim selection.