## Phase 1: HLD Update

`docs/high-level-design.md` now records self-hosted WebSockets as the committed delivery approach:

- Change storage retains replayable revisions and reliably publishes committed revisions.
- Delivery owns WebSocket sessions and connection capacity.
- Browsers reconnect and catch up from their last received revision before resuming live updates.
- The rationale records the accepted operational overhead in exchange for low-latency delivery without realtime-provider fees or coupling.

```markdown
# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. The server delivers committed changes to connected browsers through self-hosted WebSocket sessions, avoiding a realtime-service dependency while providing low-latency updates.

Delivery, change storage, and browser recovery are designed together. The change store retains replayable revisions and reliably publishes committed revisions to delivery. Delivery manages socket capacity and session lifecycle. Browsers reconnect after a transport failure and catch up from their last received revision before resuming live updates.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Stores revision history, provides replay by revision, and reliably publishes committed revisions to delivery.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Owns self-hosted WebSocket sessions, connection capacity, and publication of committed revisions to connected browsers.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Owns WebSocket connection, reconnect, and revision catch-up behavior.

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
- **Self-hosted WebSockets deliver committed board updates.** The board operates its own WebSocket delivery sessions rather than polling or using a hosted realtime provider. This accepts connection-capacity and reconnect operations in exchange for low-latency updates without recurring provider fees or provider coupling. The change store must retain replayable revisions and reliably publish them; browsers must reconnect and catch up before resuming live delivery.
```

Please approve this HLD update to proceed to the three leaf design nodes: change store, delivery, and browser sync.