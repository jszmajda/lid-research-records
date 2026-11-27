Phase 1 (HLD) is done — the only file changed is `docs/high-level-design.md`. Coherence pre-flight before resuming: EARS specs (`ACCESS-*`) still trace to the Access LLD and that LLD still reflects the HLD's architecture; no tests exist yet. I found one stale cross-segment reference and am flagging it rather than auto-fixing (see Q4). I wrote the HLD context-free: the "still open" option listing and deliberation notes are gone, and the considered alternatives/why now live only in Key Design Decisions.

**Phase 1 output — revised `docs/high-level-design.md`:**

```markdown
# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Committed changes are delivered to browsers over self-hosted WebSockets, giving fast updates without coupling the board to a realtime vendor. This makes the project responsible for connection capacity, reconnect handling, and catch-up behavior. Subsecond delivery is useful but not required to meet the 15-second freshness target.

Delivery, change storage, and browser recovery are designed together around this transport: the change store keeps replayable revisions and reliable publication, delivery manages WebSocket sessions, and browser sync implements reconnect and catch-up logic.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Will own replayable revisions and reliable publication for socket delivery.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Will own WebSocket session management and publication to connected browsers.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Will own subscription, reconnect, and catch-up against the change store.

## Tenets

- A committed edit has one authoritative event revision regardless of its delivery route.
- Connectivity failures must be visible, not mistaken for an unchanged board.
- Commands use server-side authorization; browser state is not evidence of permission.
- Self-hosted and managed infrastructure are both permitted. Event updates contain stall IDs and operational statuses, not customer records.

## Goals

- Show committed changes in connected browsers within 15 seconds under normal connectivity.
- Support 800 simultaneous browsers and opening-time bursts of 20 edits per second.
- Recover the latest board after a browser has been disconnected for up to 20 minutes.
- Retain seven days of event revisions for operational investigation.
- Achieve 99.5 percent availability during published event hours.

## Non-Goals

- Offline editing or resolving conflicting offline commands.
- Vendor payments, customer information, or public attendee access.
- Multi-region active-active operation for the pilot.

## Key Design Decisions

- **Commands over HTTPS, one authoritative board per event.** Editors submit commands to the server, which assigns each committed edit one event revision. Peer-to-peer or browser-side merging was rejected: the tenets require one authoritative revision regardless of delivery route, and offline editing is a non-goal.
- **Committed changes delivered over self-hosted WebSockets.** Browsers receive committed changes over WebSocket sessions managed and hosted by the project. Considered: five-second HTTPS polling and a hosted realtime service. Polling is the simplest stateless operation and meets the 15-second freshness target, but adds repeated reads and a few seconds of lag; a hosted realtime service shortens the path to low-latency updates with less connection operations, but adds recurring fees and provider coupling. Self-hosted WebSockets were chosen for fast updates without tying the board to a realtime vendor, accepting ownership of connection capacity and reconnect/catch-up work. It obligates the change store to replayable revisions and reliable publication, delivery to session management, and browser sync to reconnect/catch-up logic.
```

**STOP for Phase 1 review.** Per your "we'll do the three nodes after that," I'm stopping here: the three unwritten nodes (change-store, delivery, browser-sync) stay deferred, and I won't start Phase 2 until you approve. Please reply with numbered feedback, plus your rulings on these:

1. **Approve the HLD?** Proceed only on your explicit approval; otherwise give numbered corrections.

2. **Decision doc?** This choice clears the bar for one — three credible options weighed against latency, operating cost, and vendor coupling, and three downstream nodes about to be sized around it. I've recorded it as a Key Design Decisions row above. Want me to also write a full `docs/decisions/change-delivery-approach.md` (context, gated/weighted criteria, options, selection) and link it from that row, or keep just the row? I'll write the doc only if you accept.

3. **Tenets — which way should the project lean?** Your choice reveals a lean no current tenet states: accepting connection/reconnect operations to get fast, vendor-independent updates. Should that become a one-line tenet (e.g. "Fast, vendor-independent updates over minimum operational burden"), and if so should it sit alongside, qualify, or replace the existing "Self-hosted and managed infrastructure are both permitted"? Or is this a one-off decision with no standing lean? Invite any other load-bearing tenets you want recorded — I won't add any without your call.

4. **Cross-segment cascade (Access).** `docs/intent/access/access-design.md:10` still says authorization is "independent of the still-open change-delivery approach" — stale now that the approach is settled. The Access design itself is unaffected. Should I clean up that wording now, or defer it with the three nodes? I'm pausing rather than propagating into that segment on my own.