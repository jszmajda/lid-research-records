I've updated the HLD to lock in the self-hosted WebSockets choice for delivery. Here's the full updated doc:

```markdown
# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Committed changes reach browsers over self-hosted WebSocket connections: the server pushes each committed revision to connected sessions as it commits, rather than browsers polling for updates or a hosted realtime vendor relaying them. Subsecond updates would be useful, but are not required; self-hosted sockets were chosen for low-latency delivery without recurring vendor fees or provider coupling, at the cost of owning connection capacity and reconnect handling.

Delivery, change storage, and browser recovery are designed together around this choice. The change store keeps revisions replayable so a reconnecting browser can catch up. Delivery owns socket sessions and reconnection. Browser sync subscribes to a session and performs catch-up reads after a gap.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns replayable revision history and reliable publication to delivery.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns WebSocket session management and reconnection.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns subscription, reconnect, and catch-up behavior against delivery's sessions.

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
- **Self-hosted WebSockets for delivery.** The server pushes committed revisions to browsers over sockets it operates itself. Five-second HTTPS polling was rejected for its repeated reads and added lag; a hosted realtime service was rejected for its recurring fees and provider coupling. Self-hosted sockets give low-latency delivery without a realtime vendor bill, in exchange for owning connection capacity and reconnect handling.
```

This is a choice with real tradeoffs across more than one criterion (latency, cost, ops burden), and the change store, delivery, and browser-sync nodes are all about to be sized around it — that clears the bar where I'd normally offer a standalone decision doc instead of just the HLD row above. Want a full decision doc for this, or is the row sufficient?

Once you confirm the HLD (and the decision-doc question), we'll move to the three nodes as planned.