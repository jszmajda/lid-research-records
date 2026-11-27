## Phase 1 — HLD review

Updated `docs/high-level-design.md`; the three downstream nodes remain untouched.

# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board and receive committed changes over self-hosted WebSockets. The server owns connection capacity and socket sessions, while the change store retains replayable revisions and reliably hands committed changes to delivery. Browsers reconnect and catch up from those revisions after interrupted connections. Subsecond updates would be useful, but are not required.

Delivery, change storage, and browser recovery must be designed together around this socket-based approach. This accepts additional connection and reconnect operations in exchange for fast updates without coupling the board to a realtime vendor.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns replayable revision history, read indexes, and reliable publication to delivery.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns WebSocket sessions, connection capacity, and publication of committed revisions.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns socket subscriptions, reconnect, and revision catch-up.

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
- **Self-hosted WebSockets for change delivery.** The server publishes committed revisions to socket sessions, backed by replayable revisions and reliable publication in the change store; browsers reconnect and catch up after interruptions. Five-second HTTPS polling was rejected because its repeated reads and delivery lag were less attractive than prompt socket updates. A hosted realtime service was rejected to avoid recurring fees and provider coupling. This choice accepts operational responsibility for connection capacity and reconnect handling.

---

Two review points:

1. The decision is currently recorded in the HLD. Because it trades operating cost, latency, and vendor coupling, I can instead expand it into a standalone decision document if you want the full comparison preserved.
2. `access-design.md` still describes delivery as “still-open.” I left that separate segment unchanged; authorize the small wording cleanup if you want it included in the cascade.

Please approve the HLD, request changes, or ask for the standalone decision document. After approval, I’ll start with the change-store node, then pause for its LLD review before delivery and browser sync.