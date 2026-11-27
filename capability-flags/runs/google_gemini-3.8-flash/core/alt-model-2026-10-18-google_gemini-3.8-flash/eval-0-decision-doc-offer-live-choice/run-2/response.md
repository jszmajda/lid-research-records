I have updated `docs/high-level-design.md` with the self-hosted WebSockets approach, aligning the approach description, architecture dependencies across the downstream nodes, and key design decisions.

### Updated High-Level Design (`docs/high-level-design.md`)

```markdown
# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Committed changes are delivered to connected browsers over self-hosted WebSockets. The server coordinates active client socket sessions and broadcasts committed event revisions. Connected browsers receive push updates immediately, while reconnecting browsers request catch-up ranges to recover missed revisions without vendor lock-in.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Maintains monotonically increasing event revisions, ordered revision queries for reconnect catch-up, and publication dispatch.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Manages WebSocket connections, client subscriptions, session heartbeat/liveness, and broadcast dispatch of committed event revisions.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Establishes the WebSocket connection, applies streaming revision patches, detects disconnection, and initiates revision catch-up upon reconnect.

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
- **Change delivery via self-hosted WebSockets.** Committed event revisions are pushed to connected browsers across self-hosted WebSocket connections, backed by revision replay for reconnecting clients. HTTPS polling was rejected because of update latency and repeated read traffic. A hosted realtime provider was rejected to avoid recurring vendor fees and third-party operational coupling, accepting server-side connection lifecycle management and client reconnect/catch-up logic.
```

---

### Phase 1 Stop & Review

1. Would you like to record this choice as a full decision doc (`docs/decisions/change-delivery.md`) detailing the weighted trade-offs against polling and hosted realtime, or is the entry in **Key Design Decisions** sufficient?
2. Does the updated HLD meet your intent, and are we ready to proceed to Phase 2 for the three downstream nodes (`change-store`, `delivery`, and `browser-sync`), starting with which node?