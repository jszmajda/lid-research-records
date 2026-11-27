Phase 1 — HLD updated. The approach now commits to self-hosted WebSockets, and the three downstream node descriptions name their resulting responsibilities.

```markdown
# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Committed changes reach connected browsers over self-hosted WebSockets, giving fast updates without tying the board to a realtime vendor.

Self-hosting means the project owns connection capacity and reconnect behavior. Delivery, change storage, and browser recovery are designed together around this: the change store keeps replayable revisions and reliably publishes committed changes; delivery manages socket sessions; browser sync reconnects and catches up from the last revision it displayed. Subsecond updates are useful but not required; the freshness goal is fifteen seconds under normal connectivity.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns revision history, read indexes, and reliable publication of committed revisions for delivery to replay.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns WebSocket session management, publication to connected browsers, and reconnect coordination.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns socket subscription, reconnect, and catch-up from the last displayed revision.

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
- **Self-hosted WebSockets for change delivery.** Committed revisions reach browsers over sockets the project operates, which gives fast updates without a realtime vendor bill or provider coupling. Five-second HTTPS polling was simpler and stateless but repeats reads and lags by seconds; a hosted realtime service minimized connection operations but added recurring fees and provider dependency. Self-hosting accepts ownership of connection capacity and reconnect handling in exchange for vendor independence and responsive updates.
```

Please review this HLD and approve it before I move on to the three node designs.

One recording question: this choice stays genuinely live for a cold reader because all three downstream nodes will be shaped around it. Would you like a full decision doc at `docs/decisions/self-hosted-websockets.md` capturing the options and criteria, or is the Key Design Decisions entry sufficient?