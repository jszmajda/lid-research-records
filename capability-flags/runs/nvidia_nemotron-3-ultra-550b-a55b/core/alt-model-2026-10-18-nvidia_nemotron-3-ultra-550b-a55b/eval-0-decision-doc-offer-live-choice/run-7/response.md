**Phase 1 — HLD updated.** The approach is now recorded as self-hosted WebSockets with the tradeoff rationale in both the Approach and Key Design Decisions sections.

```markdown
# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. **Delivery uses self-hosted WebSockets.** This was chosen over five-second HTTPS polling and a hosted realtime service to get fast updates without a recurring vendor bill, accepting the operational work of connection capacity and reconnect logic. All three could meet the required freshness target; subsecond updates would be useful, but are not required.

Delivery, change storage, and browser recovery are designed together for WebSocket delivery: the change store provides replayable revisions and a publication outbox; delivery manages socket sessions and reliable publication; browser sync handles subscription, reconnect, and catch-up logic.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Provides revision history, read indexes, and a publication outbox for WebSocket delivery.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Manages WebSocket sessions, reliable publication from the outbox, and session recovery.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Handles WebSocket subscription, reconnect with backoff, and revision catch-up.

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
- **Self-hosted WebSockets for change delivery.** Chosen over five-second HTTPS polling and a hosted realtime service. Trades operational ownership of connection capacity and reconnect logic for fast updates without a recurring vendor bill. The change store provides replayable revisions and a publication outbox; delivery manages socket sessions and reliable publication; browser sync handles subscription, reconnect with backoff, and revision catch-up.
```

**STOP for user review.** Approve to proceed to Phase 2 (drafting LLDs for change-store, delivery, and browser-sync)?