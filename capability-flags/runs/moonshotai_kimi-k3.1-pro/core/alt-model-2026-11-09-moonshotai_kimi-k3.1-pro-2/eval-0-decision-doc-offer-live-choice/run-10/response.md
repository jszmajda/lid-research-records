Updated `docs/high-level-design.md` to select self-hosted WebSockets. The change-store, delivery, and browser-sync nodes remain untouched pending your review.

# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board and receive committed changes over self-hosted WebSocket connections. This provides fast updates without recurring realtime service fees or provider coupling, in exchange for owning connection capacity and reconnect operations. Subsecond updates would be useful, but are not required.

Delivery, change storage, and browser recovery form one replayable update path. The change store retains replayable revisions and reliably publishes committed changes; delivery manages WebSocket capacity and sessions; browsers reconnect and catch up from event revisions. HTTPS remains the command boundary.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Will own revision history, replay queries, and reliable publication of committed changes.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Will own self-hosted WebSocket sessions, connection capacity, and publication to connected browsers.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Will own WebSocket subscription, reconnect, and revision-based catch-up behavior.

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
- **Self-hosted WebSockets for committed-change delivery.** Five-second HTTPS polling would offer simpler stateless operation but requires repeated reads and introduces several seconds of lag. A hosted realtime service would reduce connection operations but adds recurring fees and provider coupling. Self-hosted WebSockets provide fast updates without a realtime vendor dependency; the project accepts responsibility for connection capacity, reconnect handling, replayable revisions, and reliable publication.

This delivery choice will shape all three forthcoming nodes and involves live cost, operations, latency, and vendor-coupling trade-offs. I recorded it as a concise HLD decision; I can also preserve the full comparison in a project-level decision doc if you want that deeper rationale.

Please review the HLD and approve it, or tell me what to adjust. Once approved, I’ll proceed to the three nodes.