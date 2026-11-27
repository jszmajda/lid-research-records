Updated `docs/high-level-design.md`. Here are the revised portions for review.

### Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Self-hosted WebSockets deliver committed changes promptly to connected browsers without coupling the board to a hosted realtime provider. Subsecond updates are desirable; the required freshness target remains 15 seconds under normal connectivity.

Change storage, delivery, and browser recovery share the event revision as their synchronization boundary. The change store provides replayable committed revisions and reliable publication to delivery. Delivery owns WebSocket sessions, connection capacity, and recovery from interrupted publication. Browsers reconnect and catch up from their last applied revision. The system accepts the additional connection and reconnect operations work in exchange for fast updates without realtime-vendor dependence.

### Architecture

- **Access:** `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- **Change store:** `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Design pending. Owns authoritative board state, replayable event revisions, and reliable publication of committed changes.
- **Delivery:** `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Design pending. Owns self-hosted WebSocket sessions, connection capacity, and delivery of live and replayed revisions.
- **Browser sync:** `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Design pending. Owns applying revisions, visible connection status, reconnect, and catch-up to the latest board.

### Tenets

- A committed edit has one authoritative event revision regardless of its delivery route.
- Connectivity failures must be visible, not mistaken for an unchanged board.
- Commands use server-side authorization; browser state is not evidence of permission.
- Prefer fast updates without realtime-vendor dependence over minimizing connection and reconnect operations work.

Event updates contain stall IDs and operational statuses, not customer records. Self-hosted and managed infrastructure are both permitted; the realtime delivery layer is self-hosted.

### Added key design decision

**Self-hosted WebSockets for committed changes.** Five-second HTTPS polling offers simpler stateless operation and meets the freshness target, but adds repeated reads and seconds of update lag. A hosted realtime service reduces connection operations work and speeds delivery implementation, but introduces recurring provider fees and coupling. Self-hosted WebSockets favor fast updates and realtime-vendor independence, accepting responsibility for connection capacity, reliable publication, and reconnect/catch-up behavior across the change store, delivery, and browser sync nodes.

---

`git diff --check` passed. The access design still describes delivery as “still-open”; that wording needs a small cross-node update when you authorize the cascade.

1. **Do you approve this HLD revision**, including the preference captured in the new tenet?
2. This choice has credible alternatives and shapes all three pending nodes. **Would you like a standalone decision document in `docs/decisions/`** preserving the fuller tradeoffs, or keep the HLD entry as its record?