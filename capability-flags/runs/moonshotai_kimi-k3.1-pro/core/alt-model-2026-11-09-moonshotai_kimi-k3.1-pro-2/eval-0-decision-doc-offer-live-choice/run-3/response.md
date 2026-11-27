## Phase 1 — HLD review

Updated `docs/high-level-design.md` for self-hosted WebSockets. The three downstream nodes remain untouched.

```markdown
# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Self-hosted WebSockets deliver committed changes to connected browsers. The platform owns connection capacity and reconnect handling in exchange for fast updates without recurring realtime service fees or provider coupling. Subsecond updates would be useful, but are not required.

The change store, delivery service, and browser sync client form a revision-based delivery path. The change store retains replayable event revisions and reliably publishes committed changes. Delivery manages WebSocket sessions and sends new revisions to connected browsers. Browsers reconnect and catch up from revision history after an interruption.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns replayable revision history, read indexes, and reliable publication of committed changes.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns self-hosted WebSocket sessions, connection capacity, and publication to connected browsers.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns socket subscriptions, reconnects, and catch-up from revision history.

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
- **Self-hosted WebSockets for committed-change delivery.** Browsers maintain socket connections and recover through revision replay. Five-second HTTPS polling was rejected because it adds repeated reads and several seconds of lag; a hosted realtime service was rejected because its recurring fees and provider coupling outweigh its reduced connection operations for this project. The team accepts owning connection capacity, reliable publication, and reconnect handling in exchange for fast updates without a realtime vendor dependency.
```

One coherence issue remains: `docs/intent/access/access-design.md` still describes the delivery approach as “still-open.” I left it unchanged because it belongs to a separate segment.

Do you approve this HLD, and may I also correct that Access wording before starting the change-store node?