Phase 1 HLD update complete. `docs/high-level-design.md` now reflects the self-hosted WebSockets choice.

**Approach**
Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Committed changes are delivered to browsers over self-hosted WebSockets with server-side session management, replayable revisions for catch-up, and reliable publication from the change store to connected clients. The store provides cursor queries and revision history; delivery manages sessions and reconnect; browsers implement reconnect and catch-up logic.

**Architecture**
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Revision history, read indexes, and a publication outbox for WebSocket delivery.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns WebSocket sessions, connection capacity, and reliable publication from store to clients.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Implements subscription, reconnect, and catch-up logic for WebSocket delivery.

**Key Design Decisions**
- **Self-hosted WebSockets for real-time delivery.** Committed changes are pushed to browsers via self-hosted WebSockets rather than HTTPS polling or a hosted realtime service. This avoids vendor coupling and recurring fees, accepts the operational burden of connection capacity and reconnect handling, and requires replayable revisions and reliable publication from the change store.

Phase 1 stop. Please review the HLD changes and confirm approval to proceed to Phase 2 — LLD check/draft for the three nodes: change-store, delivery, and browser-sync.