I updated `docs/high-level-design.md` to select self-hosted WebSockets and spell out the resulting responsibilities for the change store, delivery, and browser sync. This is the Phase 1 HLD review stop; I have not started the three design nodes.

```markdown
# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. The server publishes committed changes to connected browsers over self-hosted WebSockets. The change store retains replayable revisions and supports reliable publication to delivery. Delivery manages WebSocket connections, and browsers reconnect and catch up from their last applied revision after interruptions.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns authoritative revision history, replay, and reliable publication of committed changes to delivery.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns self-hosted WebSocket connections and the publication of committed revisions to connected browsers.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Subscribes over WebSockets and recovers missed changes after reconnecting.

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
- **Self-hosted WebSockets for committed change delivery.** This provides fast push updates without recurring realtime-service fees or provider coupling. Five-second HTTPS polling was rejected because it adds repeated reads and update lag; a hosted realtime service was rejected because it adds recurring fees and provider coupling. Self-hosting means the system owns connection capacity, publication reliability, and reconnect and catch-up behavior.
```

Please review the HLD and approve it or give corrections. A few choices to settle at this stop:

- Should avoiding realtime-vendor coupling be a broader tenet for future choices, or remain specific to this delivery decision?
- A cold reader might revisit this transport choice given its competing costs and downstream effects. Should I expand the HLD decision entry into a full decision doc, or keep the current rationale row?
- The existing Access design says the delivery approach is “still-open.” That wording is now stale, though its authorization design remains independent. Should I update that wording during the cascade, or leave Access untouched while we work on the three planned nodes?