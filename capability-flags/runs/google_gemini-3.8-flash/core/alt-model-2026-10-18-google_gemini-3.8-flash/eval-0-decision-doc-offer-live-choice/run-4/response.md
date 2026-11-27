I have updated `docs/high-level-design.md` to reflect the selection of the self-hosted WebSockets approach, aligning the approach description, component architectural roles, and Key Design Decisions accordingly.

Here is the updated High-Level Design for review:

```markdown
# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Committed changes are delivered to connected browsers over self-hosted WebSockets. The server publishes committed revisions immediately over active socket sessions for low-latency updates, while the change store retains replayable event revisions. Browsers manage persistent connections, detect drops, and execute reconnect and catch-up workflows against the revision history.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Maintains revision history, read indexes, and an outbox or publication stream to feed websocket delivery and replay requests.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns self-hosted WebSocket connections, client session lifecycles, event channel multiplexing, heartbeat monitoring, and live broadcast of committed revisions.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns the browser-side WebSocket lifecycle, heartbeat tracking, disconnection detection, backoff reconnects, and snapshot/revision catch-up.

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
- **Change delivery via self-hosted WebSockets.** Committed board updates are broadcast to connected browsers via self-hosted WebSocket connections rather than HTTPS polling or a third-party hosted realtime service. HTTPS polling was rejected because of recurring read load and higher latency lag; hosted realtime services were rejected to avoid recurring vendor fees and third-party lock-in. Self-hosted WebSockets deliver low-latency updates and vendor independence at the cost of managing connection lifecycles, session capacity, and client reconnect/catch-up logic directly.
```

---

### Questions for User Review

1. Does the revised High-Level Design look accurate, or would you like any adjustments to the approach, architecture roles, or decision rationale?
2. Because this choice involves non-trivial architectural trade-offs across multiple nodes, would you like to memorialize it as a standalone decision doc (`docs/decisions/change-delivery-mechanism.md`), or does keeping the entry in the HLD's Key Design Decisions suffice?
3. Once approved, which of the three downstream nodes (`change-store`, `delivery`, or `browser-sync`) would you like to design first?