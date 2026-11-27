2Q is recorded as the eviction policy and the preview design is drafted around it. Nothing is committed, and I haven't touched the specs yet — that's the next step once you're happy with this.

## What changed

**`docs/intent/previews/previews-design.md`**
- **Two queues:** a new Eviction section splits the 12 GiB budget between a first-use queue (oldest out first) and a reused queue (least recently requested out first).
- **Promotion:** a newly rendered sheet enters first-use. The first cache-served request is treated as delivery of the viewing that caused the render; the next one moves the sheet to the reused queue. 202 responses never count.
- **Size split:** the first-use queue's share is a private worker setting, defaulting to 25% (3 GiB, about 1,500 sheets).
- **Victim choice:** evict from first-use when it is at or over its share, or when the reused queue is empty; otherwise evict from the reused queue.
- **Effect:** a long screening only displaces other one-use sheets, and the reused queue keeps 9 GiB (about 4,500 sheets) however long the screening runs.
- **Decisions table:** three rows — 2Q over LRU and aged frequency, what counts as reuse, and the configurable share. Tuning the 25% is listed as a deferred question for the pilot.

**`docs/high-level-design.md`**
- Removed the sentence "Its eviction policy remains open." Nothing else changes there, and the review API design is untouched.

I recorded the 2Q choice as a table row rather than a standalone decision doc, since it only affects the preview worker.

## Questions for you

1. **Is "reuse" the second cache-served request?** I assumed yes. The catch is that two editors waiting on the same pending render each retry, which promotes that sheet immediately. The alternative is to remember the keys of sheets evicted from first-use and promote only when one is rendered again; that resists screenings better but costs each comparison sheet one extra re-render.
2. **Is 25% an acceptable starting split?** It is my number, not one from the thread.

## Gaps an independent read found

None of these reopen the policy choice. I've given my suggested default for each; tell me which to write into the design and which to leave open.

3. **Worker restart:** the design doesn't say whether queue membership survives. I'd rebuild every sheet on disk into the first-use queue.
4. **Concurrent completions:** up to four renders can finish at once. I'd serialise evict-then-admit so the 12 GiB bound holds.
5. **Eviction racing a read:** a sheet could be evicted while it is being served. I'd let the in-flight response complete.
6. **Share bounds:** no valid range is given for the setting, and "at least its share" doesn't say whether the incoming sheet counts. I'd restrict it to 1–99% and measure before the incoming sheet.
7. **Oversized sheet:** a sheet larger than the whole budget has no defined outcome. I'd serve it without caching it.

Once you approve or correct these, I'll move on to the specs: extending PREVIEW-004 and adding lines for promotion and victim choice.