Updated `docs/high-level-design.md` to select **self-hosted WebSockets**. Here is the revised intent for review.

### Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Self-hosted WebSockets deliver committed changes to connected browsers with low latency, without a realtime-service dependency or recurring realtime-vendor fees. The freshness requirement remains 15 seconds under normal connectivity; subsecond delivery is desirable rather than a separate guarantee.

Change storage, delivery, and browser recovery share an event-revision contract. The change store provides replayable committed revisions and reliable publication; delivery manages WebSocket sessions and connection capacity; browser sync reconnects and catches up from authoritative revisions. MarketBoard owns the connection and reconnect operations needed for this approach, including recovery after interruptions. Detailed publication, replay, and recovery mechanisms belong in these three design nodes.

### Architecture responsibilities

The HLD assigns the three forthcoming nodes these scopes:

- **Change store:** Authoritative revision history, replay reads, and reliable publication of committed changes.
- **Delivery:** Self-hosted WebSocket sessions, connection capacity, and delivery of committed revisions to event subscribers.
- **Browser sync:** The browser’s revisioned view, connection visibility, reconnect, and catch-up behavior.

### Added tenet

> Prefer low-latency, vendor-independent board delivery over minimizing connection-operations work.

### Added key design decision

**Self-hosted WebSockets for committed board changes.** Fast updates and independence from a realtime vendor outweigh the added connection-capacity and reconnect operations work. Five-second HTTPS polling offers simpler stateless operation and meets the freshness requirement, but adds repeated reads and seconds of delivery lag. A hosted realtime service reduces connection operations and speeds delivery development, but introduces recurring fees and provider coupling. Self-hosted WebSockets obligate the change store to support replayable revisions and reliable publication, delivery to manage sessions, and browser sync to reconnect and catch up.

**Coherence note:** Access’s HTTPS authorization design and specs fit this approach, although its context still describes delivery as “still-open.” That wording needs a follow-up when we review that segment. `git diff --check` passed.

Before proceeding to the three nodes:

1. **Do you approve the HLD update, including the new tenet?**
2. This choice has credible alternatives and shapes three nodes. **Would you like a standalone decision doc in `docs/decisions/` preserving the competing criteria and tradeoffs, or keep the HLD decision entry alone?**