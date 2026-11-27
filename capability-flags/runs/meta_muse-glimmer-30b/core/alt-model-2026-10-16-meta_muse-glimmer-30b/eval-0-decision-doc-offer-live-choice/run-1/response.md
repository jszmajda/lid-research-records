Phase 1 — HLD check is complete.

I updated `docs/high-level-design.md` to record the delivery approach selection as self-hosted WebSockets and removed open-option language.

**Approach** now reads:
> Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Delivery of committed changes uses self-hosted WebSockets for fast updates without tying the board to a realtime vendor.
>
> The store needs replayable revisions and reliable publication, delivery manages sessions with reconnect and catch-up logic, and browsers run reconnect/catch-up logic. The team accepts extra connection and reconnect operations work to avoid recurring vendor fees and provider coupling.

**Architecture** updated to reflect the choice:
- Change store — Provides revision history, read indexes, and a publication outbox for WebSocket delivery.
- Delivery — Owns WebSocket sessions with reconnect handling and reliable publication from the change store.
- Browser sync — Handles WebSocket subscription, reconnect, and catch-up after disconnection.

**Key Design Decisions** added:
- **Delivery via self-hosted WebSockets.** Selected over five-second HTTPS polling and hosted realtime service to get fast updates without tying the board to a realtime vendor. Alternatives considered: polling offers simplest stateless operation but adds repeated reads and a few seconds lag; hosted realtime offers quickest low-latency updates with less connection ops but adds recurring fees and provider coupling. Self-hosted WebSockets require connection capacity and reconnect handling, replayable revisions in the store, reliable publication from store to delivery, session management in delivery, and reconnect/catch-up logic in browsers.

Please review the revised Approach, Architecture, and Key Design Decisions. Confirm approval to proceed to Phase 2 — LLD check/draft for the three nodes: change-store, delivery, and browser-sync.