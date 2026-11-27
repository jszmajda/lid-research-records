Updated `docs/high-level-design.md` to select **self-hosted WebSockets**. The revised passages are below.

### Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Self-hosted WebSockets push committed changes to connected browsers, providing fast updates without a realtime vendor dependency or recurring realtime service fees. The freshness requirement remains 15 seconds under normal connectivity; subsecond updates are desirable rather than a separate guarantee.

Change storage, delivery, and browser recovery share the authoritative event revision. The change store provides replayable revisions and reliable publication of committed changes; delivery owns WebSocket sessions and connection capacity; browser sync owns reconnect and revision-based catch-up. MarketBoard accepts the connection and reconnect operations work to obtain low-latency delivery without coupling the board to a realtime provider. Publication guarantees, replay contracts, and recovery details belong in the three component designs.

### Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns authoritative board state, replayable event revisions, and reliable publication of committed changes for delivery.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns self-hosted WebSocket sessions, connection capacity, and delivery of committed revisions, including coordination with replay for recovery.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns WebSocket subscription, reconnect, revision-based catch-up, and visible connectivity state.

### Added tenet

> Prefer fast board updates and realtime-provider independence over minimizing connection-management operations.

### Added key design decision

**Self-hosted WebSockets for committed changes.** Five-second HTTPS polling offers simple stateless operation but adds repeated reads and several seconds of delivery lag. A hosted realtime service offers low-latency updates with less connection operations work but introduces recurring service fees and provider coupling. Self-hosted WebSockets favor fast updates and realtime-provider independence while accepting responsibility for connection capacity and reconnect operations. This choice requires replayable revisions and reliable publication in the change store, session management in delivery, and reconnect and catch-up behavior in browser sync.

---

**Coherence check:** Access’s HTTPS authorization design and specs remain compatible. Its context paragraph still calls delivery “open”; that wording needs a follow-up across the access-node boundary. `git diff --check` passed.

Please review:
1. **Does this HLD update, including the new tenet, capture your intent?**
2. **Would you like a standalone decision doc, or keep the rationale in the HLD entry?** This choice merits the offer because polling and hosted realtime remain credible alternatives, and all three forthcoming nodes depend on the tradeoff. A decision doc would preserve the competing options and selection criteria for a future maintainer.