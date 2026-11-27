**Phase 1 — HLD updated to commit to self-hosted WebSockets. STOP for your review.**

Changed sections of `docs/high-level-design.md`:

**Approach**
> Keep one authoritative board per event. Editors submit commands over HTTPS; browsers receive committed changes over self-hosted WebSocket connections. Each connected browser holds a socket session that streams revisioned updates, and a disconnected browser reconnects and catches up to the latest board. The server owns connection capacity and publication of committed revisions; no realtime vendor sits in the delivery path. Subsecond updates would be useful, but are not required.
>
> Change storage, delivery, and browser recovery are designed together around this choice: the store keeps replayable revisions, delivery manages socket sessions and reliable publication, and browsers run reconnect and catch-up logic.

**Architecture** — the three unwritten nodes now name their direction instead of "depending on the approach":
- Change store: replayable revision history + read indexes for catch-up, publication of committed revisions to delivery.
- Delivery: WebSocket sessions, connection capacity, reliable publication to connected browsers.
- Browser sync: socket subscription, reconnect, catch-up of missed revisions.

**Key Design Decisions** — new entry:
> **Self-hosted WebSockets for change delivery.** Committed revisions reach browsers over WebSocket connections the project runs itself. Five-second HTTPS polling was rejected because it accepts seconds of lag and repeated reads for a store that would need cursor queries; a hosted realtime service was rejected because it accepts recurring fees and provider coupling for connection capacity the project can own. Self-hosted sockets deliver fast updates without a realtime vendor, at the cost of owning connection capacity and reconnect operations.

No new tenets surfaced from this choice; the existing five still hold.

Three things for you:

1. **Review the HLD changes above** — approve or give numbered feedback.
2. **Decision doc offer:** this choice had three credible options weighed against lag, ops burden, cost, and vendor coupling, and the next three design nodes get sized around it. A cold reader could be tempted to re-litigate it. Want it recorded as a full decision doc at `docs/decisions/change-delivery-approach.md`, or is the Key Design Decisions entry enough?
3. **Cascade flag (cross-segment):** `docs/intent/access/access-design.md` says authorization is "independent of the still-open change-delivery approach" — that phrase is now stale. Small fix, but it's in the access segment, so I'm asking before touching it. Fix it now, or leave it?

Once you approve, we proceed to the three nodes (change-store, delivery, browser-sync), starting with Phase 2 for whichever you want first.