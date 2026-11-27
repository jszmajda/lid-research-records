I've recorded the 2Q decision in the design docs and run the LLD-level edge-case probe. Here's where things stand — this is the Phase 2 (LLD) stop, so I'm pausing here rather than moving on to EARS.

**Updated `docs/high-level-design.md`:** the previews bullet now says the private cache uses 2Q eviction, replacing "its eviction policy remains open."

**Updated `docs/intent/previews/previews-design.md`:**
- *Private Cache* section now describes the mechanism concretely: sheets enter queue A1 on first admission, promote to Am on a second access before eviction, and eviction drains A1 before Am. A1 is sized as a fixed fraction of the 12 GiB budget so one long screening can't starve Am.
- Added a *Decisions & Alternatives* table row recording 2Q over LRU and aged-frequency, with the rationale from your sketch (scan isolation vs. the cost of a second queue and a tunable split).
- Added an *Open Questions* entry: the A1/Am size split itself is undetermined — it's deferred to empirical tuning during the pilot.

**Decision doc offer:** this clears the bar for a full decision doc rather than just the table row — it was genuinely contested across three meetings, trades three options against real criteria (bookkeeping cost, scan resistance, retention lag), and the Am/A1 split other work will size around stays live for a cold reader. Want me to write `docs/intent/previews/decisions/cache-eviction-policy.md` instead of (or in addition to) the table row, or is the row enough?

**Edge-case probe (blind reader, LLD text only)** turned up gaps to triage — the eviction-specific ones are most load-bearing for this change:
- What happens when a single sheet's size exceeds the whole 12 GiB budget, or the A1 fraction alone?
- What happens when evicting everything in A1 and Am still can't free enough room to admit a new sheet?
- Can Am be evicted from when A1 is empty?
- What's the behavior (default fraction?) before the A1/Am split is tuned?
- Does a second access to a sheet still sitting in A1 promote it immediately, or only once it's about to be evicted?

(It also surfaced some pre-existing gaps unrelated to eviction — queue-depth limits, job timeouts, dedup-map race windows — which I'm not folding into this change unless you want them addressed now.)

Which of these do you want fixed in the LLD now versus deferred as open questions, and how should the decision be recorded?