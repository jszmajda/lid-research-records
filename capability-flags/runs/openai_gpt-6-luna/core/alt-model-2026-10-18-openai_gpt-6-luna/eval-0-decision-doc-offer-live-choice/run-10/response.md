Updated `docs/high-level-design.md` to select self-hosted WebSockets. `git diff --check` passes.

Please review the HLD below. Does it capture the intended approach, including replayable revisions, reliable publication, session management, and browser reconnect/catch-up? The change-store, delivery, and browser-sync nodes are the next phase after your approval.

```markdown
# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Deliver committed changes to connected browsers over self-hosted WebSockets for fast updates without a realtime-service vendor dependency. The change store retains replayable event revisions and publishes them reliably; delivery manages WebSocket sessions; browser sync reconnects and catches up from its last applied revision. This approach accepts the connection-capacity, publication-reliability, and reconnect work required to operate those paths.

Delivery, change storage, and browser recovery are designed together around that contract: revisions provide replay and catch-up, reliable publication feeds active sessions, and browsers resume from their last applied revision after reconnecting.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns event revision history, replay/cursor queries, and reliable publication of committed changes to delivery.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns self-hosted WebSocket sessions, connection lifecycle, and publication to connected browsers.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Subscribes over WebSockets and reconnects and catches up from the last applied revision.

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
- **Self-hosted WebSockets for committed-change delivery.** Five-second HTTPS polling would reduce connection-management work at the cost of repeated reads and several seconds of update lag. A hosted realtime service would reduce connection operations but add recurring fees and provider coupling. Self-hosted WebSockets provide fast updates without that vendor dependency, accepting responsibility for connection capacity, reliable publication, and reconnect/catch-up behavior.
```

This choice has several credible alternatives and will shape the three downstream nodes. Would you like a standalone decision document recording the trade-offs, or should the HLD decision entry be the record?