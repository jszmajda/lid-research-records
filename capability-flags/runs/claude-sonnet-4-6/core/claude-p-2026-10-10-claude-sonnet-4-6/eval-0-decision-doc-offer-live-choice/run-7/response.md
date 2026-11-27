Here is the updated HLD for your review:

---

**MarketBoard High-Level Design — updated**

**Approach** (changed)

> Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Committed changes are delivered to browsers over self-hosted WebSocket connections, providing subsecond update latency without a realtime vendor dependency. The tradeoff is owning connection capacity and reconnect reliability rather than delegating them to a provider.
>
> The change store maintains replayable event revisions so that a reconnecting browser can catch up from its last known revision. The delivery layer manages WebSocket sessions and pushes committed revisions to connected browsers. Browsers maintain a persistent connection with reconnect and catch-up logic to recover from transient disconnects.

**Architecture** (node descriptions updated to reflect WebSocket context; all three nodes still marked not written yet)

- Change store — replayable event revisions and a publication outbox for the delivery layer
- Delivery — WebSocket session management, pushes committed revisions to connected browsers
- Browser sync — persistent WebSocket connection, reconnect, and catch-up from last known revision

**Key Design Decisions** (new entry added)

> **Self-hosted WebSockets for delivery.** Committed revisions are pushed to browsers over server-managed WebSocket connections. HTTPS polling and a hosted realtime service were both considered: polling is simpler and stateless but introduces several seconds of lag and repeated read load; a hosted service reduces connection ops work but couples the board to a vendor and adds recurring per-connection cost. WebSockets provide subsecond delivery at the cost of owning connection capacity, session management, and reconnect reliability.

---

Does this read correctly? If so, we can move on to the three nodes (change store, delivery, browser sync).