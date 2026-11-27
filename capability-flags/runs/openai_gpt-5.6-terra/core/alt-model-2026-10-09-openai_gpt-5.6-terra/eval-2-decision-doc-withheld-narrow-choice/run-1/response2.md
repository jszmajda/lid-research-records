I agree. This remains a live, non-obvious trade-off: 2Q adds private state and a tunable queue split to protect repeated comparisons against scan pollution. A cold reader could reasonably revisit LRU or aged-frequency eviction, so a one-row rationale would not preserve enough judgment.

The decision belongs to the Previews segment, since it does not alter the review API contract or any other node. I will add `docs/intent/previews/decisions/2q-cache-eviction.md` during the preview LLD phase.

Approve the HLD update so I can proceed to that phase?