Updated the HLD to commit to self-hosted WebSockets. Here are the changes:

**Approach** (revised to commit to the choice):
> Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Committed changes reach connected browsers via self-hosted WebSockets, achieving subsecond update latency without tying the system to a realtime vendor.
>
> The change store maintains replayable revisions with sequential event version numbers. The delivery component manages WebSocket sessions, publishes committed changes, and handles reconnection handshakes. Browsers subscribe via WebSocket, maintain a local view, and recover missed revisions during reconnection using cursor-based catch-up.

**Architecture** (updated component descriptions to reflect WebSocket implications):
- **Change store**: Persists event revisions as a sequential version history. Supports cursor-based queries for replay during reconnection. Publishes committed changes to the delivery component.
- **Delivery**: Manages WebSocket connections, broadcasts committed changes to subscribed browsers, and coordinates reconnection handshakes with version cursors.
- **Browser sync**: Subscribes to event updates via WebSocket, applies received changes to local board state, detects disconnection, and requests catch-up revisions during reconnection.

**Key Design Decisions** (added):
> **Self-hosted WebSockets for change delivery.** Fast updates without realtime vendor coupling or recurring service fees. HTTPS polling was rejected due to repeated read load and update lag; a hosted realtime service was rejected to avoid provider dependency and ongoing costs. Accepts the operational burden of connection capacity planning and reconnection logic.

Does this capture the decision correctly?