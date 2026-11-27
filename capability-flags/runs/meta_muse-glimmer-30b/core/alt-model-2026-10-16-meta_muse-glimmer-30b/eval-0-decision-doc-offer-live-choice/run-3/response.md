Phase 1 — HLD check is complete. The approach is now recorded as self-hosted WebSockets.

Updated `docs/high-level-design.md`:

**Approach**
Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Delivery uses self-hosted WebSockets for fast updates without tying the board to a realtime vendor.

The store provides cursor queries and replayable revisions; delivery manages sessions with reliable publication and connection capacity; browsers implement reconnect and catch-up logic.

**Architecture**
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Revision history, read indexes, and publication outbox support WebSocket replay and cursor catch-up.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns WebSocket sessions with replayable revisions and reliable publication.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Subscription, reconnect, and catch-up behavior for WebSocket delivery.

**Key Design Decisions**
- **Delivery via self-hosted WebSockets.** WebSockets provide fast updates without recurring realtime-vendor fees or provider coupling. The trade is owning connection capacity and reconnect logic. The store needs replayable revisions and cursor queries; delivery must manage sessions with reliable publication; browsers need reconnect and catch-up logic.

Stop for user review. Does this HLD reflect the self-hosted WebSockets intent as you want it recorded? Confirm to proceed to Phase 2 — LLD check/draft for the three nodes: change-store, delivery, and browser-sync.