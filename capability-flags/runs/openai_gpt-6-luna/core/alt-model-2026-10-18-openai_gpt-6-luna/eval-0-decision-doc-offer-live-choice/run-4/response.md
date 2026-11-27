Updated `docs/high-level-design.md` to select self-hosted WebSockets and record the responsibilities and tradeoffs.

```markdown
# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Deliver committed changes to connected browsers over self-hosted WebSockets. This provides fast updates without a realtime-service dependency, with the operational cost of managing connection capacity, reliable publication, and reconnect and catch-up behavior.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Retains replayable event revisions and supports their reliable publication.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Manages self-hosted WebSocket sessions and delivers published revisions to connected browsers.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Subscribes over WebSockets and reconnects and catches up from its last applied revision.

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
- **Self-hosted WebSockets for committed-change delivery.** Five-second HTTPS polling keeps delivery stateless but adds repeated reads and up to five seconds of lag; a hosted realtime service reduces connection operations but adds recurring fees and provider coupling. Self-hosted WebSockets provide fast updates without a realtime vendor dependency. The system accepts the added work of connection capacity, reliable publication, and client reconnect and catch-up; the change store, delivery service, and browser sync component own those responsibilities respectively.
```

`git diff --check` passes. Do you approve this HLD as written, or would you like changes? Since the tradeoffs could remain relevant as the three design nodes are shaped, would you also like a full decision document for the WebSocket choice, or is the HLD decision entry sufficient?

I’ll pause here for your review before drafting the three nodes.