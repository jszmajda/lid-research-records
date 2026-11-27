Phase 1 — HLD check complete. Updated `docs/high-level-design.md` to record the self-hosted WebSockets delivery choice.

Updated Approach:
Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Committed changes are delivered to connected browsers over self-hosted WebSockets, providing fast updates without a realtime vendor dependency.

The change store maintains replayable revisions and a reliable publication outbox for WebSocket delivery. Delivery manages persistent sessions, reconnection, and ordered publication. Browser sync implements reconnect and catch-up logic to recover the latest board after disconnection.

Updated Architecture:
- Change store: Maintains revision history, read indexes, and a publication outbox for replayable revisions.
- Delivery: Owns WebSocket sessions, connection management, and reliable publication.
- Browser sync: Implements subscription via WebSocket, reconnect, and catch-up logic.

Key Design Decision added:
- **Delivery via self-hosted WebSockets.** Committed changes are pushed to browsers over self-hosted WebSockets to achieve fast updates without a realtime vendor dependency. Five-second HTTPS polling was rejected for its lag and repeated reads; a hosted realtime service was rejected to avoid recurring fees and provider coupling. The store therefore needs replayable revisions and reliable publication, delivery manages sessions and reconnection, and browsers implement reconnect and catch-up logic.

Current HLD:

# MarketBoard High-Level Design

## Problem
Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach
Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Committed changes are delivered to connected browsers over self-hosted WebSockets, providing fast updates without a realtime vendor dependency.

The change store maintains replayable revisions and a reliable publication outbox for WebSocket delivery. Delivery manages persistent sessions, reconnection, and ordered publication. Browser sync implements reconnect and catch-up logic to recover the latest board after disconnection.

## Architecture
- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Maintains revision history, read indexes, and a publication outbox for replayable revisions.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns WebSocket sessions, connection management, and reliable publication.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Implements subscription via WebSocket, reconnect, and catch-up logic.

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
- **Delivery via self-hosted WebSockets.** Committed changes are pushed to browsers over self-hosted WebSockets to achieve fast updates without a realtime vendor dependency. Five-second HTTPS polling was rejected for its lag and repeated reads; a hosted realtime service was rejected to avoid recurring fees and provider coupling. The store therefore needs replayable revisions and reliable publication, delivery manages sessions and reconnection, and browsers implement reconnect and catch-up logic.

Stop for your review. Approve this HLD update and I will proceed to Phase 2 for the three nodes — change-store, delivery, browser-sync — per the LID workflow.