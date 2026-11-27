I finished the Phase 2 LLD update for the preview cache's eviction policy. Here's what changed and what needs your review before I move on to specs.

**Updated `docs/intent/previews/previews-design.md`** — Private Cache section now describes 2Q concretely (probationary `A1`, protected `Am`, promotion on reuse, eviction drawing from `A1` first), and I added a Decisions & Alternatives table recording the choice against LRU and frequency-aging, plus an Open Questions entry deferring the exact `A1`/`Am` size split to implementation-time tuning. I also updated the HLD's one-line reference to the previews node so it no longer says the eviction policy is open.

**Decision doc offer:** this went through three meetings and a 180-message thread with real competing options — that's exactly the kind of choice a cold reader might later question or want to re-litigate without the tradeoffs in front of them. I recorded it as a Decisions & Alternatives row for now. Want a full decision doc instead (`docs/intent/previews/decisions/eviction-policy.md`), or is the table row enough?

**LLD-level edge-case probe** (blind read, your latent intent not yet checked against these): a few gaps are specific to 2Q and worth settling before I draft EARS:
1. Hit on a sheet already in `Am` — does it move to MRU position within `Am`, or stay put? Only `A1`→`Am` promotion is defined.
2. Within `A1`, which entry is evicted first — strict insertion order, or something else? "Draws from `A1` first" doesn't say how `A1` itself is ordered.
3. If promotions push `Am` past its (tunable) share, is there an eviction fallback inside `Am`, or does the doc assume `Am` never needs to shrink?
4. When an evicted sheet is later re-rendered, does it re-enter fresh at `A1`, or retain any memory of having been promoted before?

A few more showed up that predate this change and apply under any eviction policy (queue depth beyond 4 active jobs, ticket/notification behavior on job failure, admission when eviction still can't free enough space, worker-restart recovery of in-flight tickets) — I'd suggest deferring those rather than reopening scope today, but flagging them since no doc currently answers them.

How do you want to handle the four 2Q-specific gaps — settle them now, or note them as deferred and let EARS carry them as open behavior to pin down later?