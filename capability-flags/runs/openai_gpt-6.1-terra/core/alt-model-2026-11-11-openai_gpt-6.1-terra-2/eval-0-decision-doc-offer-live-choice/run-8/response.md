Updated `docs/high-level-design.md` with the selected approach. Here is the full HLD for review:

# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board and receive committed changes through self-hosted WebSockets. This supports low-latency updates without depending on a realtime provider. Subsecond updates would be useful, but are not required.

The change store retains replayable revisions and supports reliable publication of committed changes. Delivery manages WebSocket sessions and connection capacity. Browsers reconnect and catch up after interruptions; these responsibilities must be designed together so browsers can recover an authoritative board view.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns revision history and the storage support for replay and reliable publication.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns WebSocket sessions and delivery of committed changes.
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
- **Self-hosted WebSockets for committed changes.** Low-latency updates without a realtime provider justify operating connection capacity and reconnects. Five-second HTTPS polling offers simpler stateless operation but adds repeated reads and delivery lag; a hosted realtime service reduces connection operations but introduces recurring fees and provider coupling.

---

1. **Do you approve the HLD**, or want changes before we start the three nodes?
2. Should preference for low latency and provider independence over simpler operations be a **general project tenet**, or is it specific to this delivery decision? Are there other tie-breakers you want recorded?
3. The delivery choice has credible alternatives and shapes three nodes. Would you like a **full decision document** capturing its tradeoffs, or is the HLD decision entry sufficient?
4. The existing access design still calls the delivery approach “open.” May I update that stale wording when we cascade, even though access is a separate node?