Phase 1 — HLD updated. The Approach and Architecture now read:

**Approach**

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Committed changes are pushed to connected browsers over self-hosted WebSocket connections. Subsecond updates are useful, but are not required; the freshness target remains 15 seconds.

Delivery, change storage, and browser recovery are designed together. The change store keeps committed revisions replayable so a socket session can resume from a known revision. Delivery owns connection capacity, socket session lifecycle, and reliable publication of committed revisions. Browser sync maintains the subscription, reconnects after a drop, and catches up from the last revision it displayed. Neither operating cost nor minimum operational burden is the overriding criterion; keeping delivery in infrastructure the project owns is preferred over the recurring fees and provider coupling of a hosted realtime service.

**Architecture nodes**

- Change store: owns revision history and the read indexes that make committed revisions replayable and their publication reliable.
- Delivery: owns socket connection capacity, session lifecycle, and publication of committed revisions to connected browsers.
- Browser sync: owns the socket subscription, reconnect behavior, and catch-up from the last displayed revision.

**Key Design Decisions**

- **Deliver committed changes over self-hosted WebSockets.** The server pushes each committed revision to connected browsers over socket connections it owns. Five-second polling meets the freshness target but adds repeated reads and a few seconds of lag; a hosted realtime service offers low-latency delivery with less connection operation but carries recurring fees and provider coupling. Self-hosted sockets provide subsecond updates without tying the board to a realtime vendor, accepting connection-capacity and reconnect operation as the cost.

Two things before we move to the three nodes:

1. This choice will size all three nodes and stays genuinely live for a cold reader. Should I record it as a project-level decision doc at `docs/decisions/delivery-approach.md` (linked from the HLD row), or leave it as the HLD row only?
2. `docs/intent/access/access-design.md` still says authorization is independent of the "still-open change-delivery approach." That wording is now stale, but Access is a separate segment. Update that line now, or handle it when we do the nodes?

Approve the HLD as above and answer these two, and I'll start the node designs.