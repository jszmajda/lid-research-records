Per the decision doc heuristic in linked-intent-dev, we judge whether a decision earns a doc from the **landed state looking forward**, not the deliberation looking backward:

*Would a cold reader of the finished design find the choice non-obvious and be tempted to reverse it without the full criteria and competing options laid out?*

Here, **a table row in the LLD is sufficient**:

1. **Self-evident once landed**: Once 2Q is in place, the choice naturally fits the stated problem in the HLD (editors alternating long sequential screening scans with repeated comparisons). A reader sees immediately why a scan-resistant policy was chosen over basic LRU.
2. **Private implementation detail**: The eviction policy is entirely private to the preview worker. Per HLD tenets and goals, no external contract, review API behavior, render queue, or disk budget changes regardless of the policy chosen. Sibling components do not depend on it.
3. **Table row settles it**: A cold reader asking "why 2Q?" gets the answer directly from the rationale column: LRU is vulnerable to sequential screening scans, frequency counting lags project switches, and 2Q protects comparison sheets with private queue bookkeeping.

A long or heated debate is a common symptom of a hard decision, but under the methodology, an argument in flight does not itself justify a standalone decision doc.

However, the user is always right. If you would still prefer a standalone decision doc at `docs/intent/previews/decisions/eviction-policy.md`, I can draft one. Should we create the full decision doc or proceed with the Decisions table row and address the LLD probe questions?