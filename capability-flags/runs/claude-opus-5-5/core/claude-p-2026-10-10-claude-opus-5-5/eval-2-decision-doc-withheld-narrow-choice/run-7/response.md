2Q is now written into the previews design, with LRU and aged-frequency recorded as the rejected alternatives. Nothing beyond the two design docs has been touched: no specs, tests or code yet, and nothing is committed.

## What changed

- **`docs/high-level-design.md`**: one line. The Previews entry now says the cache uses 2Q eviction instead of "eviction policy remains open".
- **`docs/intent/previews/previews-design.md`**: the open-policy paragraph is replaced by a new **Eviction Policy** section and a **Decisions & Alternatives** table. The interface, render queue and 12 GiB budget are unchanged, and so is the review API.

## The eviction design

- **Probationary queue**: first-time sheets, FIFO by admission. Target share is 25% of the budget (3 GiB, about 1,500 typical sheets).
- **Protected queue**: sheets that have shown reuse, with the least recently requested evicted first. It gets the rest of the 12 GiB.
- **Recently-evicted list**: keys only, for sheets evicted from probationary. It holds up to 3,000 keys and does not count against the 12 GiB.
- **Admission**: a completed sheet whose key is on the recently-evicted list goes to protected; any other goes to the tail of probationary.
- **Requests**: a 200 from protected refreshes that sheet's recency. A 200 from probationary changes nothing, and a 202 changes nothing.
- **Eviction**: if probationary is over its share, evict its oldest sheet and remember the key; otherwise evict the least recently requested protected sheet. If the chosen queue is empty, evict from the other.
- **Bookkeeping**: all in memory in the worker. Evict-and-admit for one sheet is a single locked step, so the four concurrent render jobs can't overshoot the bound. The share and list capacity are worker configuration, invisible through the HTTP interface.

## One choice inside 2Q to confirm

I made a sheet become protected only when it is re-requested after falling out of probationary, not on a second request while it is still there. Under the 202-then-retry protocol, every new sheet's first delivery is already a request that finds it cached. Promoting on that would protect every one-off screening sheet and defeat the point of 2Q.

The cost is that a comparison sheet pushed out by a screening of more than about 1,500 new sheets pays one extra 450 ms render before it is protected for the rest of that screening. If you'd rather avoid that render, the alternative is to promote on a later hit that isn't the first delivery, which needs more bookkeeping to tell the two apart.

The 25% share and 3,000-key list are the original 2Q paper's proportions as starting defaults, not measured values.

## Gaps for you to triage

I ran the edge-case probe on the design. For each, tell me whether to fix it in the design now or defer it as an open question.

1. **Worker restart**: queue state is in memory, and the design doesn't say whether cached JPEGs survive a restart or how the queues are rebuilt. I'd suggest surviving sheets re-enter as probationary in file-age order and the recently-evicted list starts empty.
2. **Renderer version change**: old-version sheets become unreachable but still occupy space, possibly in the protected queue, until they age out. The choice is to purge them eagerly or let them age out; I'd suggest letting them age out.
3. **Tuning evidence**: the design says the split is tuned "from the worker's own observations" but names none. Worker-local log counters for recently-evicted-list hits and protected evictions would be enough.
4. **Gaps outside eviction**: the probe also found three in the existing rendering text: no response shape for a failed render (a clip that always fails would re-render every two seconds forever), no render-queue depth limit or job timeout, and no outcome when resolving the source revision fails for a reason other than "unknown". I left these alone as outside the eviction work.

## Next

Once you approve the design (and answer 1–4 and the promotion rule), I'll draft the EARS specs for the eviction behaviour as the next phase and stop again for your review.