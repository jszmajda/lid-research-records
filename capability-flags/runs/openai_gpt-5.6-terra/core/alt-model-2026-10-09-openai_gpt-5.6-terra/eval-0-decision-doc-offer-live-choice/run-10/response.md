## Phase 1: HLD Review

```markdown
# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. The server delivers committed changes through self-hosted WebSocket connections, allowing connected browsers to receive updates without a polling interval or a realtime-service dependency.

Delivery, change storage, and browser recovery are designed together around replayable event revisions. The change store retains revisions for reconnect catch-up and delivery publishes each committed revision reliably. Delivery owns WebSocket session capacity and connection lifecycle; browser sync owns reconnect and catch-up behavior. The project accepts the resulting connection and reconnect operational work to provide fast updates without provider coupling.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns replayable event revisions and reliable publication of committed revisions.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns self-hosted WebSocket sessions, connection capacity, and revision delivery.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns the browser's socket subscription, reconnection, and revision catch-up behavior.

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
- **Self-hosted WebSockets for committed-change delivery.** The server pushes committed revisions to connected browsers over WebSockets. Five-second HTTPS polling was rejected because it introduces repeated reads and delivery lag; a hosted realtime service was rejected because it introduces recurring cost and provider coupling. The project accepts responsibility for connection capacity and reconnect handling to achieve low-latency updates without a realtime vendor.
```

This decision has credible alternatives and will shape three design nodes. Would you like a standalone decision document recording its criteria and trade-offs, or is the HLD decision entry sufficient?

Please approve this HLD revision, with any changes and your decision-document preference.