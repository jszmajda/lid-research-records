## Phase 1 Complete — HLD Updated

I've recorded your selection of self-hosted WebSockets in the HLD:

**Updated Approach:** Changed from three open options to a single committed approach — WebSockets for delivery, with the store supporting replayable revisions, delivery managing socket sessions, and browsers handling reconnect and catch-up.

**Added Key Design Decision:** Recorded the choice (WebSockets vs. polling vs. hosted service), the rationale (minimize latency, avoid vendor coupling and fees), and the tradeoff (we own connection and reconnect operations).

**Updated Architecture:** Made the component responsibilities specific to WebSockets:
- **Change store:** owns revision history and replayable reads for recovery
- **Delivery:** owns WebSocket session lifecycle and publication to subscribers  
- **Browser sync:** owns subscription, reconnect, catch-up, and connectivity failure visibility

The HLD is now ready to cascade into the three design nodes. Does this capture the approach correctly?