Updated `docs/high-level-design.md` to select self-hosted WebSockets, capture the store, delivery, and browser-sync responsibilities, and record why polling and hosted realtime were rejected. `git diff --check` passes.

## Updated HLD

```markdown
# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Deliver committed changes through self-hosted WebSockets for fast updates without coupling the board to a realtime vendor. The change store retains replayable revisions and supports reliable publication; delivery manages WebSocket sessions; browsers reconnect and catch up from their last received revision.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Retains replayable revisions and supports reliable publication of committed changes.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns self-hosted WebSocket publication and connection sessions.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Subscribes over WebSockets, reconnects after interruptions, and catches up from the last received revision.

## Tenets

- A committed edit has one authoritative event revision regardless of its delivery route.
- Connectivity failures must be visible, not mistaken for an unchanged board.
- Commands use server-side authorization; browser state is not evidence of permission.
- Event updates contain stall IDs and operational statuses, not customer records.

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
- **Self-hosted WebSocket delivery for committed changes.** Five-second HTTPS polling was rejected because it adds repeated reads and update lag; a hosted realtime service was rejected to avoid recurring provider fees and vendor coupling. Self-hosted WebSockets provide fast updates while keeping connection capacity, session management, reliable publication, replay, and reconnect/catch-up behavior within the system's design responsibility.
```

Please review this HLD before we move on to the three nodes. Should the WebSocket choice stay as this HLD decision row, or would you like a standalone decision doc that preserves the fuller tradeoff analysis?