Updated the decision write-up so the tradeoff is self-explanatory to a new reader.

**Key Design Decisions — Delivery via self-hosted WebSockets**

- **Delivery via self-hosted WebSockets.** Chosen over five-second HTTPS polling and a hosted realtime service.

  * Five-second HTTPS polling: simplest stateless operation, but more repeated reads and a few seconds of lag; the store needs cursor queries, delivery stays request/response, and browsers run a polling loop.
  * Hosted realtime service: quickest route to low-latency updates with less connection ops, but recurring fees and provider coupling; the store needs publication reconciliation, delivery wraps the provider, and browsers use its subscription model.
  * Self-hosted WebSockets: fast updates without a realtime vendor bill, but we own connection capacity and reconnect problems; the store needs replayable revisions and reliable publication, delivery manages sessions, and browsers need reconnect/catch-up logic.

  Accepted the extra connection and reconnect operations work to get fast updates without tying the board to a realtime vendor. The store therefore provides replayable revisions and cursor queries; delivery owns WebSocket sessions with reliable publication; browsers implement reconnect and catch-up.

The HLD Approach and Architecture sections remain as previously shown, now consistent with this decision.

Stop for review. Does this capture the why behind accepting the tradeoff clearly enough for someone joining the project? Confirm to proceed to Phase 2 LLD work for change-store, delivery, and browser-sync.