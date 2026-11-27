## Phase 1 — High-Level Design

Updated `docs/high-level-design.md`:

# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; the server assigns each committed edit an event revision, and self-hosted WebSockets deliver those changes to browsers. Browsers display a revisioned view, maintain their socket connections, and catch up from revision history after reconnecting. Subsecond updates would be useful, but are not required.

Delivery, change storage, and browser recovery must be designed together. The change store must provide replayable revisions and reliable publication; delivery must manage socket sessions and connection capacity; browser sync must handle reconnect and catch-up. Owning these operational concerns avoids recurring realtime service fees and provider coupling while providing faster updates than five-second polling.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns revision history, read indexes, and reliable publication for socket delivery and browser replay.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns WebSocket sessions, connection capacity, and publication of committed revisions.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns socket subscriptions, reconnect, and catch-up from revision history.

## Tenets

- A committed edit has one authoritative event revision regardless of its delivery route.
- Connectivity failures must be visible, not mistaken for an unchanged board.
- Commands use server-side authorization; browser state is not evidence of permission.
- Prefer owning update-delivery connection operations over coupling board synchronization to a realtime vendor.
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
- **Self-hosted WebSockets for change delivery.** The server publishes committed revisions over socket connections, with replayable history supporting reconnect and catch-up. Five-second HTTPS polling was rejected because its repeated reads and delivery lag are unnecessary when fast updates are a priority. A hosted realtime service was rejected to avoid recurring fees and provider coupling. This choice commits the project to operating connection capacity, reliable publication, and reconnect recovery itself.

---

Please review this HLD before we start the three nodes.

1. Is the new tenet’s preference for self-hosted update delivery scoped correctly?
2. Would you like a full decision doc preserving the three-option trade-off, or is the Key Design Decisions entry sufficient?
3. The existing Access LLD still describes delivery as “still-open.” May I reconcile that wording in the Access segment when we resume?