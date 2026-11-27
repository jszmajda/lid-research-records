Updated `docs/high-level-design.md` to select **self-hosted WebSockets** and record your accepted operational tradeoff.

### Revised approach

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Self-hosted WebSockets push committed changes to connected browsers for fast updates without coupling the board to a realtime vendor. The required freshness target remains 15 seconds under normal connectivity; subsecond updates are desirable rather than a separate guarantee.

Change storage, delivery, and browser recovery share the authoritative event revision so browsers can catch up after interrupted connections. The change store provides replayable revisions and reliable publication of committed changes; delivery owns socket sessions and connection capacity; browser sync owns reconnect and catch-up behavior. The project accepts the connection and reconnect operations work in exchange for low-latency delivery without a realtime vendor bill. Event updates contain stall IDs and operational statuses, not customer records.

### Downstream node responsibilities

The HLD now assigns:
- **Change store:** authoritative board state, replayable event revisions, and reliable publication of committed changes to delivery. Its publication mechanism belongs in the node’s design.
- **Delivery:** self-hosted WebSocket sessions, connection capacity, and delivery of committed revisions to subscribed browsers.
- **Browser sync:** WebSocket subscription, visible connectivity state, reconnect, and revision-based catch-up after interrupted connections.

### New tenet

> Prefer vendor-independent, low-latency updates over minimizing connection and reconnect operations work.

Does that capture the broader preference you want guiding future design choices?

### Recorded decision

**Self-hosted WebSocket delivery.** WebSockets provide fast updates without a realtime vendor bill or provider coupling. Five-second HTTPS polling offers simpler stateless operation but incurs repeated reads and several seconds of lag; a hosted realtime service reduces connection operations work but introduces recurring fees and provider coupling. All three approaches can meet the 15-second freshness goal. Vendor-independent, low-latency updates take priority over minimum operational burden, so the project accepts responsibility for socket capacity, reconnects, replay, and reliable publication. This shared decision governs the change store, delivery, and browser sync nodes.

**Review note:** The access design still calls delivery “still-open”; that wording needs a follow-up across the access-node boundary. Its HTTPS authorization behavior remains compatible with this approach. `git diff --check` passed.

**Do you approve this HLD update?** Because this choice shapes three nodes and has credible competing alternatives, would you like a standalone decision document in `docs/decisions/`, or is the HLD decision entry sufficient?