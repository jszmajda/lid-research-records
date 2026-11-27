Updated `docs/high-level-design.md` to make self-hosted WebSockets the selected architecture.

# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS, and the server delivers committed changes to connected browsers over self-hosted WebSockets. Each change has a replayable event revision so browsers can reconnect and catch up without treating a connection failure as an unchanged board.

The change store provides revision history and reliable publication to the delivery layer. Delivery owns WebSocket sessions, connection capacity, and change fan-out. Browsers own reconnect and catch-up behavior. This keeps realtime delivery under project control and avoids coupling the board to a hosted realtime provider, at the cost of operating persistent connections and recovery paths.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns replayable event revisions and reliable publication to delivery.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns WebSocket sessions, connection capacity, revision fan-out, and connection recovery at the server boundary.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns the browser subscription lifecycle, reconnect behavior, and revision catch-up.

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
- **Committed changes over self-hosted WebSockets.** Persistent connections provide fast updates without a realtime vendor dependency or recurring provider fees. Five-second HTTPS polling would reduce connection operations but add repeated reads and delivery lag; a hosted realtime service would reduce connection operations but add provider coupling and recurring fees. The project accepts responsibility for connection capacity, reconnects, replay, and reliable publication.

This choice is substantial enough that a future reader could reasonably re-litigate it while designing the three dependent nodes. Should it remain as the HLD decision entry above, or should I add a project-level decision document preserving the full criteria and option analysis? Please also approve or revise the HLD before we proceed to the three nodes.