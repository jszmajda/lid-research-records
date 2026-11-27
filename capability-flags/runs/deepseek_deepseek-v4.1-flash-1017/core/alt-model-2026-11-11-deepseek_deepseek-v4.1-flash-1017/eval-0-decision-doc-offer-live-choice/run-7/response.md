Updated `docs/high-level-design.md` to adopt self-hosted WebSockets.

**Approach**
> Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Committed changes reach connected browsers over self-hosted WebSockets, giving fast updates without tying the board to a hosted realtime vendor. Subsecond updates are useful, but are not required.
>
> Delivery, change storage, and browser recovery are designed together around self-hosted sockets. The change store keeps replayable revisions and publishes committed changes reliably; delivery manages socket sessions and their connection capacity; browser sync subscribes over the socket, reconnects, and catches up after a disconnection.

**Architecture**
- Change store owns revision history, read indexes, and reliable publication of committed changes to delivery.
- Delivery owns self-hosted WebSocket sessions, including connection capacity, subscription establishment, and delivery of committed changes.
- Browser sync owns the browser's socket subscription, reconnect behavior, and catch-up after a disconnection.

**Key Design Decisions**
> **Self-hosted WebSockets for change delivery.** Committed changes are pushed to connected browsers over WebSockets we operate. Five-second HTTPS polling was rejected for its repeated reads and multi-second lag; a hosted realtime service was rejected for its recurring fees and provider coupling. Self-hosted sockets deliver fast updates without a realtime vendor, accepting responsibility for connection capacity and reconnect behavior. This obligates replayable revisions and reliable publication in the change store, session management in delivery, and reconnect/catch-up logic in browser sync.

This is the Phase 1 stop. The three nodes are untouched, as you asked. Approve this HLD update so we can move on to them?

The delivery choice also clears the bar for a project-level decision doc — credible alternatives were traded and three downstream nodes will be sized around it. Record it at `docs/decisions/change-delivery-approach.md`, or keep just the HLD decision entry?