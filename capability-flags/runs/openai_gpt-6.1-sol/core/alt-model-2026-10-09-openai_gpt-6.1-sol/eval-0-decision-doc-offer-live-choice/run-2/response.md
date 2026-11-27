Updated `docs/high-level-design.md` with the self-hosted WebSockets approach.

### Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Self-hosted WebSockets deliver committed changes to connected browsers, providing fast updates without a realtime vendor dependency or recurring realtime service fees. The project accepts responsibility for connection capacity and reconnect operations. The required freshness target remains 15 seconds under normal connectivity; subsecond updates are desirable rather than a separate guarantee.

Change storage, delivery, and browser recovery share the event revision assigned to each committed edit. The change store provides replayable revisions and reliable publication of committed changes. Delivery operates WebSocket sessions and supports replay for reconnecting browsers. Browser sync tracks its applied revision and owns reconnect and catch-up behavior. Connection loss does not change the authoritative board or replace HTTPS command submission.

### Architecture responsibilities

The HLD now assigns the three pending nodes these responsibilities:

- **Change store:** authoritative board changes, replayable event revisions, seven-day revision retention, and reliable publication.
- **Delivery:** self-hosted WebSocket sessions, connection capacity, and delivery of live and replayed revisions.
- **Browser sync:** the displayed revisioned board, visible connectivity state, and reconnect and catch-up behavior for disconnections of up to 20 minutes.

### Added tenet

> Prefer realtime vendor independence and fast board updates over minimizing connection and reconnect operations work.

### Added key design decision

**Self-hosted WebSockets for committed changes.** Five-second HTTPS polling offers simpler stateless operation but incurs repeated reads and a few seconds of lag. A hosted realtime service reduces connection operations and speeds delivery development but adds recurring fees and provider coupling. Self-hosted WebSockets prioritize fast updates and realtime vendor independence, accepting responsibility for connection capacity and reconnect operations. This choice requires replayable revisions and reliable publication in the change store, session management in delivery, and reconnect and catch-up logic in browser sync.

`git diff --check` passed. One downstream inconsistency surfaced: `docs/intent/access/access-design.md` still describes delivery as undecided; that wording needs reconciliation at the access-node boundary.

**Does this HLD capture your intended tradeoff?** Because credible alternatives trade latency, operations, and vendor costs across three nodes, this choice merits offering a standalone decision document. Would you like one linked from the HLD, or keep the rationale in the HLD entry above?