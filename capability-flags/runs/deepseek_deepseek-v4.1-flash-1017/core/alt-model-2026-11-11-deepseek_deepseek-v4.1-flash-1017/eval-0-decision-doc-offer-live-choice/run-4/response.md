Updated the HLD's approach for self-hosted WebSockets (no node work started).

**Approach**
> Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Committed changes reach connected browsers over self-hosted WebSockets: delivery publishes each committed event revision to that event's open sessions, and a browser that loses its connection reconnects and catches up from the last revision it saw. Self-hosting avoids a realtime vendor bill and provider coupling, at the cost of owning connection capacity and reconnect behavior.
>
> This route sets obligations for three design nodes. The change store retains replayable revisions and provides a reliable publication path, so a committed edit is not lost between commit and delivery. Delivery manages socket sessions and replay for reconnecting browsers. Browser sync maintains the connection, reconnects, and catches up. The 15-second freshness goal is met with margin; subsecond updates are useful but not required.

**Architecture (delivery-related bullets)**
- Change store — owns revision history, read indexes, and the reliable publication path for committed revisions.
- Delivery — owns WebSocket sessions, publication of committed revisions to open sessions, and replay for reconnecting browsers.
- Browser sync — maintains the socket connection, reconnects after a disruption, and catches up from the last seen revision.

**Key Design Decisions** — added *Self-hosted WebSockets for change delivery*, recording both rejected options: polling (simplest/stateless, but seconds of lag, read-heavy, and a browser polling loop) and hosted realtime (quickest to low latency, but recurring fees and provider coupling).

Phase 1 stop — approve this HLD update? I'll hold before drafting the change-store, delivery, and browser-sync nodes.

Two choices for you:
1. This decision affects three downstream nodes and has live tradeoffs, so it could warrant a full decision doc at `docs/decisions/self-hosted-websocket-delivery.md`; otherwise the Key Design Decisions entry stands alone. Record the doc, or keep the row only?
2. Your reason (avoid tying the board to a realtime vendor) might generalize beyond delivery. Add a tenet like "prefer self-hosted infrastructure over vendor coupling where operational cost is acceptable," or leave the tenets unchanged?