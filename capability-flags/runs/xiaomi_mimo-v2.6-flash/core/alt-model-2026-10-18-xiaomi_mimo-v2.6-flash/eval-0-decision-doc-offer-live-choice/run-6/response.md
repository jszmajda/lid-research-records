Phase 1 (HLD) is updated for the self-hosted WebSockets selection. Here is the full updated HLD for your review:

```markdown
# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power
problems through group chats. About 120 coordinators maintain boards used by up
to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages
two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS;
browsers display a revisioned view of the board. Committed changes reach
browsers over self-hosted WebSockets: the server holds a socket per connected
browser and publishes each committed revision as it lands. The project runs the
sockets itself; no realtime vendor is involved. Subsecond updates would be
useful, but are not required, and socket delivery meets the fifteen-second
freshness goal under normal connectivity.

Change storage, delivery, and browser recovery are designed together around
this choice. The change store keeps replayable revision history so a browser can
catch up after a disconnect; delivery manages socket sessions and reliable
publication of each committed revision; browsers reconnect and catch up from a
revision cursor. Five-second HTTPS polling was considered and rejected: the
simplest stateless operation, but it entails repeated reads, a few seconds of
lag, and a polling loop in every browser. A hosted realtime service was
considered and rejected: the quickest route to low-latency updates with fewer
connection operations, but it adds recurring fees and provider coupling.
Self-hosted sockets accept connection-capacity and reconnect operations as the
cost of fast updates with no realtime vendor dependency.

## Architecture

- Access: `docs/intent/access/access-design.md`, with
  `docs/intent/access/access-specs.md`. Written below the stable HTTPS command
  boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with
  `docs/intent/change-store/change-store-specs.md`. Not written yet. Replayable
  revision history and read indexes backing socket publication.
- Delivery: `docs/intent/delivery/delivery-design.md`, with
  `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns socket
  sessions and publication of committed revisions to connected browsers.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with
  `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Reconnect
  and catch-up against the socket subscription.

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

- **Commands over HTTPS, one authoritative board per event.** Editors submit
  commands to the server, which assigns each committed edit one event revision.
  Peer-to-peer or browser-side merging was rejected: the tenets require one
  authoritative revision regardless of delivery route, and offline editing is a
  non-goal.
- **Self-hosted WebSockets for change delivery.** Committed revisions reach
  browsers over sockets the project runs itself. Five-second HTTPS polling was
  rejected for its repeated reads, seconds of lag, and a polling loop in every
  browser. A hosted realtime service was rejected for its recurring fees and
  provider coupling. The accepted cost is owning connection capacity for 800
  browsers plus reconnect and catch-up logic.
```

Two things need your word before I proceed:

1. **Review the HLD above.** Reply with numbered feedback, or "approved" to accept it as-is. Once approved, I'll move to the three unwritten nodes (change store, delivery, browser sync), one at a time through the phase stops.

2. **Decision doc offer.** The delivery-approach choice is a genuine three-way trade that the change-store, delivery, and browser-sync designs will all be sized around — a cold reader could plausibly want to re-litigate it. I can either (a) leave it as the Key Design Decisions row above (usually enough), or (b) expand it into a full decision doc at `docs/decisions/self-hosted-websockets-delivery.md` laying out all three options against criteria. Which do you prefer?

One cascade note (segment boundary, so I'm asking rather than editing): `docs/intent/access/access-design.md` says authorization is "independent of the still-open change-delivery approach" — the substance still holds, but "still-open" is now stale. Want me to fix that phrase in the access node as part of this approval, or leave access untouched?