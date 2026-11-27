## Phase 1: HLD Update

`docs/high-level-design.md` now records self-hosted WebSockets as the delivery architecture.

```markdown
# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. A self-hosted WebSocket service delivers committed revisions to connected browsers with low latency, without coupling the board to a realtime vendor.

Delivery, change storage, and browser recovery are designed together around the WebSocket service. The change store retains replayable revisions and reliably publishes committed changes. Delivery owns connection capacity, socket sessions, and publication to connected browsers. Browser sync owns reconnect and catch-up behavior after missed messages or disconnected sessions.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns replayable event revisions and reliable publication of committed changes.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns self-hosted WebSocket capacity, sessions, and delivery of committed revisions.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns WebSocket subscription, reconnect, and revision catch-up behavior.

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
- **Self-hosted WebSockets for committed-change delivery.** Connected browsers receive revisions over WebSocket sessions operated by MarketBoard. Five-second HTTPS polling was rejected because it adds delivery lag and repeated reads. A hosted realtime service was rejected because it would couple the board to a provider and add recurring vendor cost. This choice requires the system to operate connection capacity, reconnection, replay, and reliable publication.
```

The selected approach is coherent with the existing availability, recovery, and scale goals. Please approve this HLD update, or identify any correction, before I draft the three leaf design nodes.