Perfect. I've created a decision doc that lays out all three options, the criteria that matter, and why self-hosted WebSockets wins. The HLD now links to it.

Here's what's recorded:

**Updated Approach section:** Clearly states self-hosted WebSockets as the selected strategy and names the implications for change storage, delivery, and browser layers.

**Decision doc** (`docs/decisions/change-delivery-approach.md`): Full analysis covering:
- Why this decision matters (real-time coordination at scale, 800 browsers)
- Criteria that drove it (operating cost, vendor independence, operational burden, latency)
- Each option analyzed against those criteria
- Why WebSockets wins (vendor independence + no recurring cost override operational complexity)
- Downstream obligations for each layer (replayable revisions, session management, reconnection logic)

A future reader can now understand that the operational burden wasn't downplayed—it was consciously accepted as the cost of independence.

**HLD updated.** Approach and Key Design Decisions sections now reflect the choice and link to the full reasoning.

Does this capture the decision properly? Ready to move to the three node designs?