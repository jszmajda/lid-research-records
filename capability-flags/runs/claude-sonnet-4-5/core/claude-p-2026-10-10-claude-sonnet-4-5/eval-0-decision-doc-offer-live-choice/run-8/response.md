Updated HLD sections (Approach, Architecture, and Key Design Decisions) to reflect the self-hosted WebSocket choice:

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Committed changes are delivered to browsers over **self-hosted WebSockets** — accepting connection capacity and reconnect operations work in exchange for fast updates without tying the board to a realtime vendor.

The change store maintains replayable revisions and publishes to connected sessions. Delivery manages WebSocket sessions, handles reconnection, and serves catchup revisions. Browsers maintain a subscription loop with reconnect and catchup logic.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Maintains revision history, read indexes, and a publication outbox for WebSocket delivery.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Manages WebSocket sessions, broadcasts committed revisions, and serves catchup queries for reconnected browsers.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Maintains WebSocket subscription, detects disconnection, and executes reconnect with catchup logic.

## Key Design Decisions (new entry)

**Self-hosted WebSockets for change delivery.** Fast updates without recurring vendor fees or provider coupling. Five-second HTTPS polling was rejected as too slow for the target experience; hosted realtime services were rejected to avoid vendor lock-in and recurring usage costs. Accepting the operational cost of managing WebSocket connections, implementing reconnect logic, and maintaining replayable revision storage.

---

This choice shapes three segments (change-store, delivery, browser-sync) that haven't been designed yet. Would you like me to expand this into a full decision doc at `docs/decisions/realtime-delivery-approach.md`? It would detail the three options, criteria (latency, cost, coupling, operational burden), and how the choice trades against them. The current Key Design Decisions row is the alternative.