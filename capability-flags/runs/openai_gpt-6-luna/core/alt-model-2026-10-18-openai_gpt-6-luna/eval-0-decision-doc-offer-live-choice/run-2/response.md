Updated `docs/high-level-design.md` to select self-hosted WebSockets and define the resulting responsibilities for the change store, delivery, and browser sync. `git diff --check` passes.

Please review the HLD below and confirm whether it’s ready to proceed to the three design nodes.

---

# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Deliver committed changes to browsers through self-hosted WebSockets for fast updates without a realtime vendor. The change store retains replayable event revisions and supports reliable publication; delivery manages WebSocket sessions; browsers reconnect and catch up from revisions after interruptions. The system owns connection capacity and reconnect reliability. Subsecond updates are useful, though the freshness goal does not require them.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns replayable event revisions and the reliable publication path for committed changes.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns self-hosted WebSocket publication and connection sessions.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns browser subscriptions, reconnection, and revision catch-up.

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
- **Self-hosted WebSockets for committed-change delivery.** Five-second HTTPS polling would reduce connection-management work but add repeated reads and update lag; hosted realtime would reduce connection operations but add recurring fees and provider coupling. Self-hosted WebSockets provide fast updates without a realtime vendor, with the trade-off that MarketBoard owns connection capacity and reconnect reliability. This choice requires replayable revisions and reliable publication in the change store, session management in delivery, and reconnect/catch-up behavior in browsers.

---

Would you also like this choice recorded in a standalone decision doc, or is the HLD decision entry sufficient?