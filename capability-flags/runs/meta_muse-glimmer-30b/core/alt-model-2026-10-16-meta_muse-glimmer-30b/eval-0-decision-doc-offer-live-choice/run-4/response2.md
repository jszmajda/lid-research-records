Updated HLD with explicit tradeoff rationale so a new reader can reconstruct why self-hosted WebSockets was chosen.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Committed changes are delivered to connected browsers over self-hosted WebSockets, providing fast updates without a realtime vendor dependency.

HTTPS polling was considered for its simplicity and stateless operation, but the few seconds of lag and repeated reads were rejected. A hosted realtime service was considered for low-latency with less connection operations, but recurring fees and provider coupling were rejected. The team accepted the extra connection capacity and reconnect logic work of self-hosted WebSockets to get fast updates while remaining vendor-independent.

The change store maintains replayable revisions and a reliable publication outbox for WebSocket delivery. Delivery manages persistent sessions, reconnection, and ordered publication. Browser sync implements reconnect and catch-up logic to recover the latest board after disconnection.

## Key Design Decisions

- **Delivery via self-hosted WebSockets.** Committed changes are pushed to browsers over self-hosted WebSockets to achieve fast updates without tying the board to a realtime vendor. Five-second HTTPS polling provides a simpler stateless operation but introduces a few seconds of lag and repeated reads; the team accepted the extra connection and reconnect operations work to avoid that lag and the read load. A hosted realtime service offers the quickest route to low-latency updates with less connection operations, but recurring fees and provider coupling were not acceptable for the pilot. The store therefore needs replayable revisions and a reliable publication outbox, delivery owns WebSocket sessions, reconnection and ordered publication, and browsers implement reconnect and catch-up logic.

The HLD now records the alternatives considered, the specific downsides that led to rejection, and the explicit acceptance of extra connection/reconnect work to retain fast, vendor-independent updates.

Approve this wording and I will proceed to Phase 2 — drafting LLDs for change-store, delivery, and browser-sync with the WebSockets approach as the fixed context.