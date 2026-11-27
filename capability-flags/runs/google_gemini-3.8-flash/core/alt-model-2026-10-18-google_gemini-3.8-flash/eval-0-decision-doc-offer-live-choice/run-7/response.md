I have updated `docs/high-level-design.md` with the self-hosted WebSockets approach, aligned the architecture descriptions for the three downstream nodes (`change-store`, `delivery`, and `browser-sync`), and recorded the architectural choice under Key Design Decisions.

Here is the updated document:

```markdown
# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board via self-hosted WebSockets. The server assigns monotonically increasing revision numbers to committed edits and publishes updates directly to connected browser sessions.

Delivery, change storage, and browser recovery are coordinated around this connection model:
- The change store maintains replayable event revisions and reliable publication to local socket connections.
- Delivery manages persistent WebSocket sessions, handling connection capacity and fan-out.
- Browsers maintain a persistent WebSocket connection with reconnect and catch-up logic to resume cleanly after transient disconnections.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Revision history, replayable revision reads, and reliable publication to delivery.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns WebSocket session lifecycles, connection capacity, and fan-out of committed revisions.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns WebSocket connection maintenance, reconnect backoff, and catch-up synchronization.

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
- **Change delivery via self-hosted WebSockets.** Board updates are streamed directly to browsers over self-hosted WebSocket connections rather than HTTPS polling or a managed realtime service. Polling introduced unwanted latency (5s lag) and higher read load on the store; hosted realtime introduced recurring provider costs and vendor coupling. Self-hosted WebSockets deliver low-latency updates without vendor lock-in, in exchange for managing connection capacity, socket sessions, and client reconnect/replay mechanisms.
```

Would you also like to record this choice as a full standalone decision doc (`docs/decisions/change-delivery.md`) detailing the criteria, options, and analysis, or keep it recorded as a Key Design Decision in the HLD? Once you approve the HLD update, we can proceed to Phase 2 for the downstream nodes.