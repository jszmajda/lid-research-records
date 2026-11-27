I have updated the High-Level Design (`docs/high-level-design.md`) to reflect the self-hosted WebSockets approach, specifying the responsibilities across the architecture and recording the choice under Key Design Decisions.

### Updated High-Level Design

```markdown
# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Committed changes are delivered using self-hosted WebSockets: the change store publishes ordered event revisions, delivery manages persistent socket connections for viewers and editors, and browsers maintain socket sessions with reconnect and catch-up logic to stay synchronized.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Maintains revision history, replayable revision feeds, and publication ordering for the delivery layer.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Manages WebSocket client sessions, connection lifecycle, and broadcast of committed revisions to connected event listeners.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Manages client WebSocket connection lifecycle, reconnect backoff, and revision catch-up upon reconnection.

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
- **Change delivery via self-hosted WebSockets.** Committed changes are pushed to connected browsers over persistent WebSockets rather than short-polling or a hosted realtime vendor. Avoids vendor lock-in and ongoing third-party service costs while delivering low-latency updates, in exchange for managing connection lifecycle, server socket capacity, and client reconnection/catch-up logic directly. Alternative short-polling was rejected due to repeated read load and latency; hosted realtime was rejected due to recurring fees and external provider coupling.
```

---

### Phase 1 Stop & Review

1. Would you like to record this architectural choice as a standalone decision doc (at `docs/decisions/change-delivery.md`), or is the entry in `docs/high-level-design.md § Key Design Decisions` sufficient?
2. Do you approve the updated HLD so we can proceed to Phase 2 for the three downstream nodes (`change-store`, `delivery`, and `browser-sync`), and which node should we design first?