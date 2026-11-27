Phase 1 (HLD check) is done — the approach is updated and the only dependent doc touched was one stale sentence in the access LLD. Here's the revised HLD for your review:

**`docs/high-level-design.md`**

```markdown
# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; the server assigns each committed edit one event revision; browsers display a revisioned view of the board and receive committed revisions over self-hosted WebSocket connections to delivery infrastructure we operate.

The delivery mechanism is self-hosted WebSockets rather than five-second HTTPS polling or a hosted realtime service. The project accepts the operational work of connection capacity, reconnection, and catch-up in exchange for fast updates without a realtime vendor dependency. Every committed revision is replayable, so a browser that loses its connection catches up from the change store and then resumes the live stream.

Because delivery, change storage, and browser recovery share the same revision stream, they are designed together: the change store keeps replayable revisions and publishes reliably, delivery manages socket sessions, and browser sync owns reconnection and catch-up.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns replayable revision history and reliable publication of committed revisions to delivery.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns WebSocket sessions, subscription of browsers to events, and fan-out of committed revisions.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns the browser socket client, reconnection, and catch-up after a dropped connection.

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
- **Self-hosted WebSockets for change delivery.** Committed revisions reach browsers over WebSocket connections to delivery infrastructure we operate. Five-second HTTPS polling was rejected because it multiplies read volume and leaves a lag floor on every update; a hosted realtime service was rejected because it ties the board to a vendor's pricing, availability, and subscription model. The cost of the chosen direction is ours to carry: connection capacity, reconnect handling, and catch-up after dropped connections.
```

Also updated in `docs/intent/access/access-design.md:10`: "independent of the still-open change-delivery approach" → "independent of the change-delivery approach" (the choice is no longer open; no other access content changed).

Three things are yours to rule on before I move to the three nodes:

1. **Tenet.** The current tenet "Self-hosted and managed infrastructure are both permitted" is neutral about which to lean toward. Should I add a forward-looking lean — e.g. "When operating burden is acceptable, prefer self-hosted infrastructure over vendor coupling" — or leave the tenet list as is?
2. **Decision doc.** This choice is exactly the kind a cold reader may re-litigate ("why not a hosted service?"), and three nodes are about to be sized around it. Want a full decision doc at `docs/decisions/change-delivery-mechanism.md`, or is the Key Design Decisions row enough?
3. **Freshness goal.** The goal stays "within 15 seconds," which WebSockets meets comfortably. Now that sub-second updates are achievable, should the goal tighten (and if so, to what) — or leave it alone?