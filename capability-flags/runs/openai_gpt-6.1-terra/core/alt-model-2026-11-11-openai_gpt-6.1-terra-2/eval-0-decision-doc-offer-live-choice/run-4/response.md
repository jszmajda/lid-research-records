Updated `docs/high-level-design.md` with the self-hosted WebSocket approach. The revised HLD is below for review.

```markdown
# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. A self-hosted WebSocket service delivers committed changes to connected browsers, supporting fast updates without dependence on a hosted realtime provider. Subsecond updates would be useful, but are not required.

The change store maintains replayable revisions and supports reliable publication of committed changes. Delivery manages WebSocket sessions and connection capacity; browsers reconnect and catch up after interruptions. These responsibilities must be designed together to keep browser views aligned with the authoritative board.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns revision history and reliable publication of committed changes.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns self-hosted WebSocket sessions and delivery to browsers.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns browser subscription, reconnect, and catch-up behavior.

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
- **Self-hosted WebSockets for committed changes.** Fast updates and independence from a realtime provider justify owning connection capacity and reconnect operations. Five-second HTTPS polling would simplify stateless operations but add repeated reads and several seconds of lag; a hosted realtime service would reduce connection operations but introduce recurring fees and provider coupling. Both alternatives can meet the freshness goal.
```

The access design still calls the delivery approach “open”; that is now stale. The three planned nodes also need their designs and specs before implementation.

1. **Do you approve the HLD as revised?** May I also correct that stale sentence in the access node when we cascade?
2. Would you like a standalone decision document preserving the tradeoffs among the three delivery options, or is the HLD decision entry sufficient?
3. Should either of these be a broader project tenet, beyond this particular choice: **favor lower latency over simpler operations**, or **favor provider independence over reduced operational burden**? You can accept, revise, or decline either.