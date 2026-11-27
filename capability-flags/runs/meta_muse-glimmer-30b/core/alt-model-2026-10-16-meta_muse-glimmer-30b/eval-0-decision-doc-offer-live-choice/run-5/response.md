Phase 1 HLD update complete.

Updated `docs/high-level-design.md`:

## Approach
Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Delivery of committed changes uses self-hosted WebSockets for fast updates without tying the board to a realtime vendor.

The store provides replayable revisions and reliable publication; delivery manages persistent sessions, connection capacity, and reconnect; browsers implement reconnect and catch-up logic. This trades extra connection and reconnect operations work for low-latency updates and no recurring realtime service fees.

## Architecture
- Change store: Not written yet. Revision history, read indexes, and a publication outbox for WebSocket delivery.
- Delivery: Not written yet. Owns WebSocket sessions, connection management, and reliable publication.
- Browser sync: Not written yet. Subscription, reconnect, and catch-up behavior for WebSocket delivery.

## Key Design Decisions
- **Delivery via self-hosted WebSockets.** Chosen over five-second HTTPS polling and hosted realtime service to obtain fast updates without vendor coupling. Self-hosted WebSockets require connection capacity management, reconnect handling, replayable revisions in the store, and browser reconnect/catch-up logic; polling was rejected for its lag and repeated reads, and hosted realtime was rejected for recurring fees and provider coupling.

Phase 1 stop. Please review the updated Approach, Architecture, and Key Design Decision. Confirm approval to proceed to Phase 2 LLD check/draft for the three nodes — change-store, delivery, browser-sync — or provide feedback.