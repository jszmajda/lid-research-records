Yes—this one earns a decision doc. Here's why:

**The test from the skill**: Would a cold reader find the choice non-obvious and be tempted to reverse it?

Your case ticks every box:
- The choice is **genuinely contested** (three meetings + a 180-message thread)
- Multiple **credible criteria traded off**: LRU's bookkeeping simplicity vs. 2Q's protection against screening scans vs. frequency-based aging's hit-rate optimization
- A fresh reader *would* question "why not LRU?" — 2Q is more complex, and the tradeoff isn't immediately obvious
- The choice shapes downstream work (tests, implementation strategy, the tuning parameter you deferred)

A Decisions row in the LLD captures *that* 2Q was chosen. A **decision doc** captures *why* it was chosen in enough detail that a future session can re-run the judgment if requirements shift (e.g., if pilot data shows editors rarely switch between screening and comparison, LRU's simpler bookkeeping might win on that criterion).

I'd write it in `docs/intent/previews/decisions/cache-eviction-policy.md`, linking it from the Decisions & Alternatives table row I just added. It would lay out:
- The problem (sequential scans evict useful comparison sheets under LRU)
- The options and their tradeoffs
- Why 2Q wins despite its complexity
- The one-thing-to-watch (the 80/20 tuning parameter)

Want me to draft it?