## Phase 1 — HLD updated for review

`docs/high-level-design.md` now reads:

# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Deliver committed changes over self-hosted WebSockets, favoring fast updates and independence from realtime vendors over reduced connection operations. Subsecond updates would be useful, but are not required.

Design delivery, change storage, and browser recovery together. The change store provides replayable revisions and reliable publication; delivery manages connection capacity and socket sessions; browser sync handles reconnect and catch-up. This combination must preserve one authoritative revision sequence and make connectivity failures visible.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns revision history, read indexes, and reliable publication for socket delivery.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns WebSocket connection capacity, socket sessions, and publication of committed revisions.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns socket subscription, reconnect, and catch-up from revision history.

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
- **Self-hosted WebSockets for committed-change delivery.** This provides fast updates without recurring realtime vendor fees or provider coupling, at the accepted cost of owning connection capacity and reconnect operations. Five-second HTTPS polling was rejected because its repeated reads and delivery lag are less attractive at the target scale; a hosted realtime service was rejected to avoid its fees and provider dependency. The choice requires replayable revisions and reliable publication in the change store, session management in delivery, and reconnect/catch-up behavior in browsers.

---

Two items need your decision before proceeding:

1. **Access cascade:** `access-design.md` still describes change delivery as “still-open.” Because Access is a separate segment, I left it unchanged. May I remove that stale wording?
2. **Decision record:** The selected approach and rejected alternatives are now captured in the HLD. Would you also like a standalone decision doc preserving the fuller latency/operations/cost trade-off, or is the HLD entry sufficient?

Please approve the HLD and answer those two points. Then I’ll start the three nodes with **Change Store** and stop for its LLD review.