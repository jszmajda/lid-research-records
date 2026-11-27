## Phase 1: HLD Review

Updated `docs/high-level-design.md` to select self-hosted WebSockets for committed-change delivery.

**Approach**

> Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. The server delivers committed changes to connected browsers over self-hosted WebSockets. This keeps fast board updates under MarketBoard's operational control without coupling the board to a realtime service provider.
>
> Delivery, change storage, and browser recovery are designed as one path: the change store retains replayable event revisions, the delivery component reliably publishes those revisions to socket sessions, and browsers reconnect and catch up from their last received revision. HTTPS remains the command boundary and the recovery path for a browser that cannot maintain a socket connection.

**Architecture**

- Change store now owns revision history, replay queries, and reliable publication of committed revisions.
- Delivery now owns WebSocket session capacity, authentication, publication, and reconnect handling.
- Browser sync now owns browser subscription, reconnection, and revision catch-up.

**Key Design Decision**

> **Self-hosted WebSockets for committed-change delivery.** The server maintains WebSocket sessions and delivers committed event revisions promptly to connected browsers. Five-second HTTPS polling was rejected because its intentional delay conflicts with fast board updates; a hosted realtime service was rejected because it couples the board to a provider. This choice requires replayable revisions, reliable publication, reconnect handling, and capacity planning for 800 simultaneous browsers.

The existing `ACCESS` LLD still calls the delivery approach open. That is stale wording in a separate arrow segment, so I have not changed it without your approval.

This architecture choice remains non-obvious to a cold reader and sizes all three upcoming nodes. Would you like a project-level decision document under `docs/decisions/` to preserve its full trade-offs, or is the HLD decision entry sufficient?

Please reply with:
1. Approval or requested changes to this HLD update.
2. `decision doc` or `HLD entry sufficient`.
3. Whether to update the stale `ACCESS` wording before we draft the change-store, delivery, and browser-sync nodes.