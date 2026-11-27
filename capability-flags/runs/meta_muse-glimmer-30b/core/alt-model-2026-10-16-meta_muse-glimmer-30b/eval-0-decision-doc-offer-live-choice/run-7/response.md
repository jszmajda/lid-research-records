Phase 1 HLD check is complete.

Updated `docs/high-level-design.md` to record the self-hosted WebSockets approach:

**Approach**
Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Committed changes are delivered via self-hosted WebSockets for fast updates without a realtime vendor. The store provides replayable revisions and reliable publication, delivery manages sessions, and browsers implement reconnect and catch-up logic.

Delivery, change storage, and browser recovery are designed around connection management, replayable revisions, and reliable publication.

**Architecture**
- Change store: Revision history, read indexes, and a publication outbox for WebSocket delivery.
- Delivery: Owns WebSocket sessions, reliable publication, and replay.
- Browser sync: Subscribes via WebSockets with reconnect and catch-up logic.

**Key Design Decisions**
- **Self-hosted WebSockets for change delivery.** Committed changes are pushed to browsers via self-hosted WebSockets. Five-second HTTPS polling was rejected for repeated reads and seconds of lag; hosted realtime service was rejected to avoid recurring fees and provider coupling. WebSockets require connection management, reconnect handling, replayable revisions, and reliable publication.

Please review the HLD update. Confirm approval to proceed to Phase 2 LLD drafting for the three nodes — change-store, delivery, and browser-sync — or provide numbered feedback for changes.