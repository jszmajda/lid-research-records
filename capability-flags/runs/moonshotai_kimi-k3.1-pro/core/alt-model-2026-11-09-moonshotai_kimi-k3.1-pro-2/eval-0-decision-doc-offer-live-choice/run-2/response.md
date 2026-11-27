## Phase 1 — HLD update

Updated `docs/high-level-design.md` to select self-hosted WebSockets and record the trade-off:

```markdown
# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Self-hosted WebSockets deliver committed changes to connected browsers with low latency and without coupling the board to a realtime vendor. Subsecond updates would be useful, but are not required.

The change store provides replayable revisions and reliable publication. Delivery operates WebSocket sessions, including connection capacity and reconnect handling. Browser sync reconnects after interruption and catches up from its last received revision. These three components must be designed together so that no committed revision is lost between storage, publication, and browser recovery.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns revision history, replay queries, and reliable publication to the delivery component.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns self-hosted WebSocket sessions, connection capacity, and publication of committed revisions.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns subscriptions, reconnects, and revision-based catch-up.

## Tenets

- A committed edit has one authoritative event revision regardless of its delivery route.
- Connectivity failures must be visible, not mistaken for an unchanged board.
- Commands use server-side authorization; browser state is not evidence of permission.
- Prefer self-hosted realtime delivery over provider coupling when its connection operations are affordable.
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
- **Self-hosted WebSockets for committed-change delivery.** The change store retains replayable revisions and publishes them reliably, delivery operates socket sessions and their capacity, and browsers reconnect and catch up by revision. This favors fast updates and avoids recurring realtime-service fees and provider coupling at the cost of owning connection and reconnect operations. Five-second HTTPS polling was rejected because it adds repeated reads and several seconds of lag compared with socket delivery; a hosted realtime service was rejected because its lower connection-operating burden does not justify the recurring fees and provider coupling.
```

I left the change-store, delivery, and browser-sync nodes untouched as requested. One coherence note: the existing access LLD still calls change delivery “still-open”; I have not changed that separate segment.

Please review the HLD. Do you approve it, and should I also refresh that stale access wording when we proceed to the three nodes?