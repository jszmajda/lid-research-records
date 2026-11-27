Updated `docs/high-level-design.md` with self-hosted WebSockets and the tradeoff you accepted.

### Revised approach

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Self-hosted WebSockets deliver committed changes to connected browsers, favoring fast updates without a realtime vendor dependency. The 15-second freshness target remains the required bound under normal connectivity; subsecond delivery is desirable rather than a separate guarantee.

Change storage, delivery, and browser recovery share the event revision as their synchronization boundary. The change store provides replayable committed revisions and reliable publication; delivery manages socket sessions and connection capacity; browsers reconnect and catch up from their last applied revision. MarketBoard owns the connection and reconnect operations needed for this approach. Event updates contain stall IDs and operational statuses, not customer records.

### Revised architecture entries

- **Change store:** `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns authoritative board changes, replayable event revisions, and reliable publication of committed changes for delivery. Replay and publication mechanisms remain to be designed in this node.
- **Delivery:** `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns self-hosted WebSocket sessions, connection capacity, and delivery of committed changes, including coordination of catch-up with live updates.
- **Browser sync:** `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns the browser’s WebSocket connection, reconnect and revision catch-up behavior, and visible connectivity state.

### Tenet reflecting your preference

> Prefer fast, vendor-independent delivery over minimizing connection and reconnect operations.

### Added key design decision

**Self-hosted WebSockets for committed changes.** Five-second HTTPS polling offers simpler stateless operation but adds repeated reads and several seconds of delivery lag. A hosted realtime service offers low latency with less connection operations work but adds recurring provider fees and coupling. Self-hosted WebSockets favor fast updates without a realtime vendor dependency, accepting responsibility for connection capacity and reconnect operations. This choice obligates the change store to support replayable revisions and reliable publication, delivery to manage socket sessions, and browser sync to handle reconnect and catch-up.

**Coherence check:** The access design and its command-authorization specs remain compatible, although its context still calls delivery “still-open”; that wording needs cleanup when reviewing that node. The three affected nodes await their designs. `git diff --check` passed.

**Do you approve this HLD update?** This choice spans three nodes and has credible alternatives, so a future maintainer could reasonably revisit it. Would you like a standalone decision document under `docs/decisions/`, or keep the rationale in the HLD entry above?