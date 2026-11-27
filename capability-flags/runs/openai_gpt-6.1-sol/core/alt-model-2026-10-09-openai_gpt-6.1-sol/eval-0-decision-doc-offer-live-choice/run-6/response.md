Updated `docs/high-level-design.md` with self-hosted WebSockets.

### Revised approach

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Self-hosted WebSockets deliver committed changes to connected browsers with low latency. The required freshness target remains 15 seconds under normal connectivity; subsecond delivery is desirable rather than a separate guarantee.

Change storage provides replayable event revisions and reliable publication of committed changes. Delivery manages WebSocket sessions and connection capacity. Browsers reconnect and catch up from their last applied revision so a broken connection does not silently lose committed changes. MarketBoard owns the connection and reconnect operations work in exchange for fast updates without a realtime vendor dependency or recurring realtime-service fees.

### Downstream architecture

The HLD now assigns these responsibilities to the three forthcoming nodes:

- **Change store:** authoritative revision history, replay reads, and reliable publication of committed changes.
- **Delivery:** self-hosted WebSocket sessions, connection capacity, and delivery of committed revisions to subscribed browsers.
- **Browser sync:** applying revisioned updates, visible connectivity state, and reconnect/catch-up behavior.

### Added tenet

> Prefer low-latency updates without realtime vendor coupling over minimizing connection and reconnect operations work.

### Recorded decision

**Self-hosted WebSockets for committed changes.** Five-second HTTPS polling offers simpler stateless operation but adds repeated reads and several seconds of lag. A hosted realtime service reduces connection operations work but introduces recurring fees and provider coupling. Self-hosted WebSockets prioritize fast updates and independence from a realtime vendor, accepting responsibility for connection capacity, reliable publication, and reconnect recovery. This choice shapes the change store, delivery, and browser sync nodes together; their detailed designs remain to be written.

The existing access design and specifications remain compatible with the HTTPS command boundary. Its context still calls delivery “still-open”; that wording needs a follow-up when we cross into that node. `git diff --check` passed.

**Do you approve this HLD revision and tenet?** This choice has credible alternatives and shapes three nodes, so it also merits an optional standalone decision document. Would you like that fuller record under `docs/decisions/`, or is the HLD entry sufficient?