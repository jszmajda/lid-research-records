Updated `docs/high-level-design.md` with the self-hosted WebSockets approach:

# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board and receive committed changes over self-hosted WebSockets. Subsecond updates would be useful, but are not required.

The change store retains replayable revisions and supports reliable publication of committed changes. Delivery manages WebSocket sessions and connection capacity. Browsers reconnect and catch up from revisions after interruptions. These components must be designed together so connected browsers can converge on the authoritative board.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns revision history and reliable publication of committed changes.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns WebSocket sessions and delivery to connected browsers.
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
- **Self-hosted WebSockets for committed changes.** Fast updates without a realtime provider dependency or recurring realtime-service fees justify owning connection capacity, publication, and reconnect operations. Five-second HTTPS polling would simplify stateless operations but add repeated reads and seconds of lag; a hosted realtime service would reduce connection operations but introduce recurring fees and provider coupling.

---

Please review the HLD before we move to the three nodes:

1. Do you approve this approach, or want changes?
2. Should **preferring fast updates and provider independence over minimizing operational work** also be a general project tenet, or only apply to this decision? Are there other tie-breakers you want recorded?
3. This choice has substantial tradeoffs across the three nodes. Would you like a separate decision document, or is the HLD decision entry sufficient?
4. `docs/intent/access/access-design.md` still calls the delivery approach open. May I correct that wording in the access segment when we cascade?