I have updated `docs/high-level-design.md` to reflect the selection of self-hosted WebSockets. The Approach, Architecture, and Key Design Decisions sections have been updated context-free:

- **Approach**: Updated to define delivery via self-hosted WebSockets with persistent browser connections, broadcast updates upon commit, and replay for reconnection, trading off connection and reconnect operational complexity against low latency and zero vendor lock-in.
- **Architecture**: Clarified responsibilities for `change-store` (revision history, ordered replay log, publication triggers), `delivery` (WebSocket connection management, client subscriptions, broadcast/replay dispatch), and `browser-sync` (connection lifecycle, reconnect backoff, revision catch-up/resync).
- **Key Design Decisions**: Recorded the self-hosted WebSockets decision alongside the rationale and rejected alternatives (HTTPS polling and hosted realtime services).

### Full Updated HLD (`docs/high-level-design.md`)

```markdown
# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Committed changes are delivered using self-hosted WebSockets: the server manages persistent browser connections, broadcasts updates as edits commit, and supports replay over the socket connection to bring clients up to date. This achieves subsecond update latency and avoids vendor lock-in or recurring service bills, in exchange for owning connection capacity, session tracking, and client reconnect handling.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Manages event revision history, ordered replay log, and reliable publication triggers for delivery.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Manages self-hosted WebSocket connections, client subscription state, and broadcast/replay message dispatch.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Manages WebSocket connection lifecycle, reconnect backoff, and revision catch-up or full resynchronization.

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
- **Change delivery via self-hosted WebSockets.** Changes are broadcast to connected browsers over self-hosted WebSockets rather than five-second HTTPS polling or a hosted realtime provider. HTTPS polling was rejected because, although simpler and stateless, it introduces multiple seconds of lag and repetitive read traffic. A hosted realtime service was rejected because, despite lower operational overhead for connections, it introduces vendor coupling and recurring costs. Self-hosted WebSockets deliver low-latency updates with complete operational independence, accepting the obligation to manage connection capacity, session tracking, and reconnect catch-up logic.
```

---

### Questions for Review

1. Do you approve the HLD changes as drafted, or would you like any adjustments to the approach, architectural responsibilities, or decision rationale?
2. Per Phase 1 decision doc guidance: Would you prefer keeping this recorded as a concise entry under `Key Design Decisions` (as drafted above), or would you like a dedicated standalone decision doc (`docs/decisions/change-delivery-mechanism.md`) detailing the full tradeoff matrix and criteria?
3. In which order would you like to tackle the three downstream nodes (`change-store`, `delivery`, `browser-sync`) in Phase 2?