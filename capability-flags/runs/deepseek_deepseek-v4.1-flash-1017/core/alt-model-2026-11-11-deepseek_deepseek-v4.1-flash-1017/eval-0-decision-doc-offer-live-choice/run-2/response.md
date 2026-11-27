Phase 1 is complete — I updated the HLD's Approach, Architecture, and Key Design Decisions for the self-hosted WebSockets choice. Full document:

```markdown
# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Committed changes reach connected browsers over self-hosted WebSockets. Servers hold a socket session per connected browser, publish committed changes to sessions subscribed to that event, and replay revisions a reconnecting browser missed. Browsers open a socket, resubscribe after reconnect, and request catch-up from their last known revision. Update latency is subsecond under normal connectivity, well inside the 15-second target.

Change storage, delivery, and browser recovery are designed together around that route. The change store keeps an ordered, replayable revision history per event and a publication record that lets delivery retry a change after commit. Delivery owns socket lifecycle, subscriptions, heartbeat, backpressure, and connection capacity. Browser sync owns reconnect, catch-up, and the visible disconnected state. Operating cost is infrastructure capacity; no realtime vendor fee or provider coupling is introduced.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns ordered revision history, read indexes, and the publication record that makes WebSocket delivery retryable after a change commits.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns WebSocket sessions, event subscriptions, publication, heartbeat, backpressure, and connection capacity.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns socket subscription, reconnect, catch-up from the last known revision, and the visible disconnected state.

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
- **Self-hosted WebSockets for change delivery.** Committed changes are pushed to connected browsers over sockets the project operates. Five-second HTTPS polling was rejected: it is the simplest stateless operation but adds repeated reads and a few seconds of lag to a board whose purpose is fast status visibility. A hosted realtime service was rejected: it reaches low latency with less connection work but adds recurring fees and provider coupling. Self-hosting accepts connection capacity and reconnect obligations in exchange for fast updates without a realtime vendor.
```

Access needs no change; it already assigns delivery-specific subscription credentials to the delivery node. I stopped before the three nodes, as you asked.

Do you approve this HLD update so I can begin the change-store, delivery, and browser-sync nodes? And separately, should this delivery choice be recorded as a full decision doc under `docs/decisions/`, or is the Key Design Decisions entry sufficient?