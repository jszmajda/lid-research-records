HLD updated to the self-hosted WebSockets approach:

- **Approach** (docs/high-level-design.md:9): now commits to push delivery over self-hosted WebSocket connections operated by our delivery component; the 15-second target remains the floor for degraded/reconnecting clients. The open-choice language and the "neither cost nor ops burden declared overriding" paragraph are gone, with the alternatives named briefly and pointed at the decision record.
- **Architecture** (docs/high-level-design.md:17-19): the three unwritten nodes now state what the choice implies — change store keeps replayable revisions for catch-up; delivery owns WebSocket sessions and reliable publication; browser sync owns subscription, reconnect, and catch-up. They remain not written yet.
- **Key Design Decisions** (docs/high-level-design.md:44): added a row for the delivery choice with polling and hosted-realtime as named alternatives and the rationale (we own connection/reconnect ops to get fast updates without vendor coupling).

STOP for your review of the updated HLD. Two things for you:

1. Any wording to adjust before we move to the three nodes (change store, delivery, browser sync)?
2. Offer: this delivery choice is contested against more than one criterion and three nodes are being sized around it, so it qualifies for a full decision doc (`docs/decisions/`, linked from the decisions row) — or keep it as the row I added. Which do you want?