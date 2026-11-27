Phase 1 — HLD update complete.

`docs/high-level-design.md` is now written as a fresh author with the self-hosted WebSockets delivery approach recorded.

**Approach**
Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Committed changes are delivered to browsers over self-hosted WebSockets for fast updates without tying the board to a realtime vendor.

Delivery, change store, and browser recovery are designed together around WebSocket sessions. The store maintains replayable revisions and a publication outbox for catch-up. Delivery manages sessions, reliable publication, and connection capacity. Browsers implement reconnect and catch-up logic to recover after disconnections.

Alternatives considered were five-second HTTPS polling — simplest stateless operation with repeated reads and a few seconds of lag, using cursor queries — and a hosted realtime service — quickest route to low-latency updates with recurring fees and provider coupling. Self-hosted WebSockets were chosen to achieve fast updates without vendor coupling, accepting extra connection and reconnect operational work.

**Architecture**
- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Maintains replayable revisions and a publication outbox for WebSocket catch-up.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns WebSocket sessions, reliable publication, and connection capacity.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Handles WebSocket subscription, reconnect, and catch-up.

**Key Design Decisions**
- **Commands over HTTPS, one authoritative board per event.** Editors submit commands to the server, which assigns each committed edit one event revision. Peer-to-peer or browser-side merging was rejected: the tenets require one authoritative revision regardless of delivery route, and offline editing is a non-goal.
- **Self-hosted WebSockets for change delivery.** Browsers receive committed changes via persistent WebSocket connections to the MarketBoard service. The store provides replayable revisions, delivery manages sessions and reliable publication, and browsers implement reconnect and catch-up. Five-second HTTPS polling was rejected for higher latency and repeated reads; hosted realtime service was rejected to avoid recurring fees and provider coupling.

Full HLD: `docs/high-level-design.md`.

STOP — please review the revised HLD and confirm approval to proceed to Phase 2 LLD check/draft for the three nodes: change-store, delivery, browser-sync.