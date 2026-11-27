Phase 1 HLD update is complete.

**docs/high-level-design.md** now records self-hosted WebSockets as the delivery approach:

* Approach
  * Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Committed changes are delivered via self-hosted WebSockets. This gives fast updates without a realtime vendor bill, accepting the extra connection and reconnect operations work.
  * The store needs cursor queries for catch-up and replayable revisions; delivery manages sessions and reliable publication; browsers implement reconnect and catch-up logic.

* Architecture
  * Change store – Revision history, read indexes, and a publication outbox for replayable revisions support WebSocket delivery.
  * Delivery – Owns WebSocket sessions, reliable publication, and reconnect handling.
  * Browser sync – Its WebSocket subscription, reconnect, and catch-up behavior support fast updates.

* Key Design Decisions added
  * **Delivery via self-hosted WebSockets.** Chosen over five-second HTTPS polling and hosted realtime service to get fast updates without vendor coupling. Trade-off accepts extra connection and reconnect operations work; the store needs replayable revisions and cursor queries, delivery manages sessions and reliable publication, and browsers implement reconnect/catch-up logic.

The HLD now reads context-free and records the choice with alternatives and downstream consequences.

STOP for user review. Please confirm the HLD approach is correct and I can proceed to Phase 2 — LLD check/draft for the three nodes you mentioned: change-store, delivery, browser-sync.