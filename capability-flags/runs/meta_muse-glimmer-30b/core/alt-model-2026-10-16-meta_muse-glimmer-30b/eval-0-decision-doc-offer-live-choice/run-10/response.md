Phase 1 HLD check complete. The HLD now records the delivery choice as self-hosted WebSockets and removes the open-option language.

Updated `docs/high-level-design.md`:

**Approach**
Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Committed changes are delivered via self-hosted WebSockets for fast updates without tying the board to a realtime vendor.

The change store provides replayable revisions and reliable publication. Delivery manages socket sessions, connection capacity, reconnects, and publication. Browser sync implements subscription, reconnect/catch-up logic, and visibility of connectivity failures.

**Architecture**
- Change store: Provides revision history and a publication outbox for WebSocket replay and catch-up.
- Delivery: Owns WebSocket sessions, connection capacity, reconnect handling, and reliable publication.
- Browser sync: Implements WebSocket subscription, reconnect/catch-up logic, and connectivity visibility.

**Key Design Decisions**
- **Delivery via self-hosted WebSockets.** Committed changes are pushed over WebSockets to avoid realtime vendor coupling. Five-second HTTPS polling was rejected for repeated reads and lag; hosted realtime service was rejected for recurring fees and provider coupling. The choice accepts connection capacity and reconnect operational work in exchange for fast updates and vendor independence.

Coherence pre-flight: HLD now aligns with the chosen approach. LLDs for change-store, delivery, and browser-sync do not exist yet, so Phase 2 will need to draft those three leaf nodes.

Approve this HLD update to proceed to Phase 2 LLD check/draft for change-store, delivery, and browser-sync?