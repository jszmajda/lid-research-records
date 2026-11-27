2Q is now written into the previews design, uncommitted and waiting on your review; no specs, tests or code are touched until you approve it.

I made two calls inside 2Q that no document settled, and both are yours to confirm or overrule. The edge-case probe also needs a caveat: it ran against the pre-2Q text because my first write was blocked, so the 2Q-specific rules have only my own check.

## What changed

- **`docs/high-level-design.md`**: one line. The Previews entry now reads "a private 12 GiB cache with 2Q eviction" instead of saying the policy is open.
- **`docs/intent/previews/previews-design.md`**:
  - The open-policy paragraph in Private Cache is replaced by the text below.
  - A Decisions & Alternatives table records 2Q over LRU and aged frequency, plus the two calls below.
  - One deferred question is added: what the worker records to guide tuning the share.
  - The last sentence of Context is reworded so it no longer says no policy is best.

The new Private Cache text:

> Sheets are evicted by 2Q, which keeps two queues over the cached sheets:
>
> - **First-use queue** — sheets in the order they were admitted. Every completed sheet enters here.
> - **Reused queue** — sheets ordered by when they were last served, holding only sheets that have been served again after their first use.
>
> The first 200 served for a sheet after its admission completes its first use and leaves it in the first-use queue. Any later 200 for a sheet in the first-use queue moves it to the most-recently-served end of the reused queue; a 200 for a sheet already in the reused queue moves it to that same end. Requests answered 202 or 404 change neither queue.
>
> The first-use queue has a share of the 12 GiB budget: 25% (3 GiB, about 1,500 typical sheets) by default, set in the worker's own configuration. Each eviction picks its victim by that share: if the first-use queue's bytes plus the incoming sheet exceed the share, evict the oldest first-use sheet; otherwise evict the least recently served reused sheet. Repeat until the incoming sheet fits.
>
> A screening of any length therefore displaces only other first-use sheets, and a comparison sheet that is served twice before 1,500 newer sheets arrive stays cached until the reused queue itself turns over. The share is a tuning value: a larger share gives a sheet longer to be reused before a screening pushes it out, and leaves less room for sheets already known to be reused.

I did not offer a standalone decision doc for 2Q: the choice only affects the preview worker, so a table row is enough.

## Two calls for you

1. **What counts as "reused".** I drafted: any 200 after the sheet's first served 200 promotes it in place.
   - This matches your "two queues and a size split" and protects a comparison sheet without losing it first.
   - The catch: when two editors wait on the same pending sheet, the second one's 200 counts as reuse, so a co-screened one-off sheet gets protected.
   - The alternative is textbook 2Q: remember recently evicted keys and promote only when a sheet comes back after eviction. It ignores that kind of double fetch, but every comparison sheet is lost once and re-rendered (about 450 ms behind a 202), and it adds a third structure.
   - I recommend the drafted rule.

2. **The size split.** I drafted 25% for the first-use queue (3 GiB, about 1,500 sheets), leaving about 4,500 sheets for reused ones, configurable in the worker. This is a starting value with no workload data behind it. Is 25% acceptable to start, or do you want a different number?

## Gaps to triage

For each, say whether to fix it in the design now or defer it as an open question. Only the first three come from the cache change; the last two were already in the design.

1. **Concurrent admissions.** Up to four renders can finish together; the design does not say the evict-then-admit step runs one at a time, so two could jointly exceed 12 GiB.
2. **Evicting a sheet mid-response.** Nothing says what happens when the victim is being streamed in a 200.
3. **Restart.** Nothing says whether queue membership survives a worker restart, or how surviving sheets are re-queued and the 12 GiB count re-established.
4. **Old renderer versions.** Sheets keyed to a superseded renderer version are never requested again; they would age out of the first-use queue but sit in the reused queue until it turns over.
5. **Failed renders.** A failed job frees its deduplication entry, but the design does not say what a ticket holder gets on its next retry.

Once you rule on these, the next step is the EARS specs for the 2Q behaviour.