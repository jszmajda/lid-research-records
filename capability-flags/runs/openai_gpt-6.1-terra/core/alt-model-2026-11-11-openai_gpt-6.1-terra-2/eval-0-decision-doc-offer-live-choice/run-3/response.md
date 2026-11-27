Updated `docs/high-level-design.md` with the self-hosted WebSocket approach. The full HLD is below for review.

````markdown
# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Committed changes are delivered over self-hosted WebSockets for low-latency updates without dependency on a hosted realtime provider. Subsecond updates would be useful, but are not required.

The change store must support replayable revisions and reliable publication of committed changes. Delivery manages WebSocket sessions and connection capacity. Browsers reconnect and catch up after interruptions. These components must be designed together to keep the board current through delivery and connectivity failures.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns revision history and reliable publication of committed changes for delivery and replay.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns self-hosted WebSocket sessions and delivery to connected browsers.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns browser subscription, reconnection, and catch-up.

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
- **Self-hosted WebSockets for committed changes.** Low-latency updates without a realtime vendor are worth owning connection capacity and reconnect operations. Five-second HTTPS polling is simpler to operate but adds repeated reads and seconds of lag; a hosted realtime service reduces connection operations but adds recurring fees and provider coupling. Both can meet the freshness target.
````

The existing access design still calls delivery an open choice; the three other design nodes remain unwritten.

1. Do you approve the HLD as drafted?
2. Should the preference for avoiding provider coupling despite extra operations work guide future infrastructure choices as a **tenet**, or is it specific to this delivery decision? Are there other tie-breakers you want recorded?
3. This tradeoff may remain worth revisiting as the three nodes are designed. Would you like a standalone decision document, or is the HLD decision entry sufficient?
4. May I correct the stale “still-open” reference in the access design when we proceed with the cascade?