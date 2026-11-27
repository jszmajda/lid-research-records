Updated `docs/high-level-design.md` and stopped before cascading into the three nodes.

```markdown
# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. The service delivers committed changes over self-hosted WebSockets so connected browsers receive updates promptly without coupling board delivery to a realtime provider.

The change store preserves replayable event revisions and supports reliable publication after a commit. Delivery owns WebSocket session capacity and disconnect handling. Browsers track their last applied revision, reconnect after interrupted sessions, and catch up from persisted revisions before resuming live updates. The project accepts the resulting connection and recovery operations work in exchange for fast updates without a hosted realtime dependency.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns replayable event revisions and the persistence boundary needed for reliable WebSocket publication and catch-up.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns self-hosted WebSocket sessions, connection capacity, publication, and disconnect handling.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns live subscription, reconnect, revision tracking, and catch-up behavior.

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
- **Self-hosted WebSockets for committed changes.** The service publishes committed revisions over WebSocket connections and retains enough revision history for reconnecting browsers to catch up. Five-second HTTPS polling was operationally simpler but added repeated reads and delivery lag; a hosted realtime service reduced connection operations but introduced recurring fees and provider coupling. Self-hosting accepts connection-capacity and reconnect responsibilities to provide fast updates without making a realtime vendor part of the board's delivery path.
```

This choice could plausibly be re-litigated by a future reader and sizes all three downstream nodes, so it qualifies for a project-level decision document. Please reply with:

1. Any HLD changes, or approval to proceed.
2. Whether to keep the current Key Design Decisions entry or expand it into `docs/decisions/realtime-delivery.md`.