Updated the HLD's delivery approach. Here's the Phase 1 output for your review.

**Approach** (rewritten):

> Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Committed changes reach connected browsers over self-hosted WebSockets: delivery maintains a socket session per browser and publishes each committed revision to the browsers subscribed to that event. A browser that disconnects reconnects and catches up to the latest revision. Self-hosting trades connection-capacity and reconnect operations for fast updates without tying the board to a realtime vendor.
>
> Change storage and browser recovery are designed around socket delivery: the change store keeps replayable revisions and publishes them reliably, delivery owns session lifecycle, and browsers carry reconnect and catch-up logic. Subsecond updates would be useful, but are not required; socket delivery meets the 15-second freshness goal comfortably.

**Architecture** — the three unwritten nodes now state the socket shape instead of "depending on the approach":
- Change store: owns revision history, read indexes, and reliable publication of committed revisions for socket delivery.
- Delivery: owns socket session lifecycle and publication of committed revisions to subscribed browsers.
- Browser sync: owns subscription, reconnect, and catch-up to the latest revision.

**Key Design Decisions** — added: *Self-hosted WebSockets for change delivery*, naming polling (rejected: added lag and repeated reads) and hosted realtime (rejected: recurring fees and provider coupling) as the alternatives, and accepting connection-capacity/reconnect ops as the cost of avoiding a realtime vendor.

Tenets and Goals were left unchanged — none conflicted with the choice.

Two things for you:

1. **Review/approve this HLD update.** On your go, I'll proceed to the three nodes (change-store → delivery → browser-sync), one at a time with their own stops.
2. **Decision doc?** This choice stays live for a cold reader — credible options traded against more than one criterion, and three nodes are about to be sized around it — so it clears the bar for a standalone decision doc. Want me to record it as one (in `docs/decisions/`, linked from the Key Design Decisions entry), or keep just the HLD row?

One cascade note: `access-design.md` says authorization is independent of "the still-open change-delivery approach." That phrase is now stale. It's a different segment, so I've left it untouched — want me to update that wording when we proceed?