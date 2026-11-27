Updated `docs/high-level-design.md` with the selected approach. The full HLD is below.

# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board and receive committed changes over self-hosted WebSockets. Subsecond updates would be useful, but are not required.

The change store maintains replayable revisions and supports reliable publication of committed changes. Delivery manages WebSocket sessions and connection capacity. Browsers reconnect and catch up after interruptions. These components must be designed together so disconnected browsers can recover the authoritative board.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns replayable revisions and reliable publication of committed changes.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns WebSocket sessions and connection management.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns browser reconnection and catch-up.

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
- **Self-hosted WebSockets for change delivery.** Fast updates without a realtime vendor justify owning connection capacity and reconnect operations. Five-second HTTPS polling is simpler and stateless but produces repeated reads and several seconds of lag; a hosted realtime service reduces connection operations but adds recurring fees and provider coupling. All three can meet the freshness target.

---

The access design still describes delivery as open. Its command-authorization boundary remains compatible, but that wording needs a cross-node update.

1. Do you approve this HLD, and may I correct that stale access wording when we cascade?
2. Should **“Prefer faster updates over lower operational burden”** be a general tenet, or was that preference specific to this choice? Are there other tie-breakers you want recorded?
3. This choice has credible alternatives and affects all three nodes. Would you like a full decision document, or is the HLD decision entry sufficient?