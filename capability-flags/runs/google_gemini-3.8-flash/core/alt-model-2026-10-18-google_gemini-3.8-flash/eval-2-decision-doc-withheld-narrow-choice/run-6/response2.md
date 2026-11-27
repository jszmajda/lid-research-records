The decision doc guidelines specifically instruct to test from the **landed state looking forward, not from the deliberation looking back**:

> *The question is not "was this hard to decide?" Plenty of decisions are contested while the work is in flight and then read as obvious, even native, once they land. The question is: once this lands, would a cold reader of the result find the choice non-obvious — would they question it, or be tempted to reverse it, not knowing why it went this way?*

Here:
1. **Scope & boundary**: The eviction policy is entirely private to the preview worker. Per the HLD tenet (*"Keep cache paths and replacement bookkeeping private to the preview worker"*), no outside node pins entries, inspects eviction counters, or depends on cache state.
2. **Dominance / Resolution**: Once implemented, 2Q is a classic textbook caching algorithm specifically tailored to scan-resistance. The Decisions & Alternatives table row succinctly and completely answers why 2Q was chosen over LRU and LFU-with-aging (protecting comparison working sets from sequential screening scans without counter-aging overhead). No other design node or architectural interface is sized around this choice.
3. **Earns-its-place bar**: A cold reader wouldn't need to re-run complex cross-component trade-offs or weighted scoring matrices; the single table row settles it cleanly. Deliberation heat (the 180-message thread) is a symptom of debate, not the forward-looking reader need.

However, per the user-is-always-right principle, if you'd still prefer a standalone decision doc (`docs/intent/previews/decisions/cache-replacement-policy.md`), I can certainly draft one. 

Would you like to stick with the Decisions & Alternatives table row, or shall I create the standalone decision doc?