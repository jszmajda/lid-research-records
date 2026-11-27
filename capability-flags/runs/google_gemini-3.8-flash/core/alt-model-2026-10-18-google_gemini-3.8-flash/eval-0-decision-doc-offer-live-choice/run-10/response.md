I have updated `docs/high-level-design.md` to establish self-hosted WebSockets as the delivery approach and aligned the downstream architecture descriptions and key design decisions accordingly.

### Updated HLD (`docs/high-level-design.md`)

```markdown
# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Committed changes are delivered using self-hosted WebSockets for low-latency updates without vendor coupling.

Delivery, change storage, and browser recovery are designed around this model:
- The change store records replayable revision history and publishes revision events reliably.
- The delivery layer manages persistent WebSocket connections, connection capacity, and client sessions.
- Browser sync maintains the WebSocket connection and implements reconnect and catch-up logic to fetch missed revisions upon reconnection.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Maintains revision history and event publication for delivery replay.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Manages WebSocket client connections, sessions, and broadcast/replay of revision events.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Manages browser WebSocket connection lifecycle, reconnect backoff, and catch-up logic.

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
- **Change delivery via self-hosted WebSockets.** Changes are broadcast directly to connected browsers over WebSockets rather than periodic HTTPS polling or a third-party hosted realtime service. This achieves fast, low-latency updates while avoiding ongoing vendor fees and provider lock-in, accepting the operational responsibility for socket connection capacity and client reconnect/catch-up protocols.
```

---

### Decision Documentation & Next Steps

1. **Decision Doc Check**: This decision trades operational complexity against recurring cost and vendor independence across multiple downstream nodes (`change-store`, `delivery`, `browser-sync`). Would you like a dedicated decision document under `docs/decisions/` capturing the criteria, gates, and evaluated alternatives, or is the entry in the HLD's `Key Design Decisions` sufficient?
2. **Phase 2 LLD Sequencing**: When you approve proceeding past this Phase 1 boundary, which of the three downstream nodes should we draft first — `change-store`, `delivery`, or `browser-sync`?