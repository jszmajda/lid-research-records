Here is the updated HLD for your review.

---

**`docs/high-level-design.md` — updated sections**

**Approach** (was open; now settled):
> Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Committed changes are delivered to connected browsers via self-hosted WebSockets.
>
> The WebSocket approach delivers committed revisions within seconds without a realtime vendor. Connection management, reconnect, and catch-up are owned by this project. The change store maintains replayable revision history to support catch-up after disconnection; the delivery layer manages WebSocket sessions and broadcasts committed revisions to connected browsers; browsers open a WebSocket connection, receive revision events, and catch up after reconnection.

**Architecture** (component descriptions updated to reflect WebSocket consequences):
> - **Change store** — owns replayable revision history, indexed reads, and a publication outbox for broadcasting committed revisions to the delivery layer.
> - **Delivery** — owns WebSocket session management and broadcast of committed revisions to connected browsers.
> - **Browser sync** — opens a WebSocket connection, receives revision events, and catches up after reconnection or an extended gap.

**Key Design Decisions** (new row):
> - **Self-hosted WebSockets for delivery.** Committed revisions are delivered to browsers over WebSocket connections managed by this project. HTTPS polling and hosted realtime services were the alternatives. Polling meets the 15-second freshness goal but adds query load and incurs seconds of structural lag. A hosted realtime service reduces connection ops but adds a recurring vendor fee and provider coupling for an infrastructure concern the project can own. Self-hosting is accepted in exchange for subsecond delivery latency and no vendor dependency; the cost is owning connection capacity and reconnect logic.

---

**One offer before you approve:** this delivery choice earns a full decision doc — three credible options traded against multiple criteria, and all three unwritten nodes are about to be sized around it. A cold reader of the result will still find the choice genuinely live without seeing the full tradeoffs. I can write `docs/decisions/delivery-approach.md` to carry the options and analysis, linked from the decisions row above. The alternative is the decisions row as-is. Would you like that doc, or is the row enough?

Does the HLD look right? Approve to move on to the three nodes.