Phase 1 (HLD) is updated for the self-hosted WebSockets choice. Here is the changed content in full:

**## Approach**

> Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Committed changes reach connected browsers over self-hosted WebSockets. Subsecond updates would be useful, but are not required.
>
> Delivery, change storage, and browser recovery are designed together around this choice: the change store keeps replayable revisions and reliable publication of committed changes, delivery owns socket session management, and browsers reconnect and catch up from a revision cursor after a disconnect. The project owns connection capacity and reconnect handling; no realtime service vendor is involved.

**## Architecture** (updated node lines)

> - Change store: ... Not written yet. Revision history, read indexes, and a publication outbox feeding socket delivery.
> - Delivery: ... Not written yet. Owns WebSocket sessions and reliable publication of committed revisions to connected browsers.
> - Browser sync: ... Not written yet. Owns browser subscription, reconnect, and catch-up over the socket connection.

**## Key Design Decisions** (new entry)

> - **Self-hosted WebSockets for change delivery.** Committed revisions are pushed to browsers over WebSockets run by the project. Five-second HTTPS polling was rejected: it is the simplest stateless operation, but it means repeated reads, seconds of lag, cursor queries in the store, and a polling loop in every browser. A hosted realtime service was rejected: it is the quickest route to low-latency updates with less connection operations, but it adds recurring fees and provider coupling, publication reconciliation in the store, and a provider-shaped subscription model in the browser. Self-hosted sockets were chosen because fast updates without a realtime vendor bill outweigh owning connection capacity and reconnect handling.

Problems, Tenets, Goals, and Non-Goals are unchanged.

Two questions before I proceed:

1. Review the HLD changes above — any corrections? (numbered feedback welcome)
2. This choice was among three options weighed against multiple criteria, and the three upcoming nodes will be sized around it — it clears the bar for a full decision doc at `docs/decisions/self-hosted-websocket-delivery.md`, linked from the HLD entry. Want the decision doc, or is the Key Design Decisions entry enough?

Once you approve, I'll move to Phase 2 and draft the three nodes: change-store, delivery, and browser-sync.