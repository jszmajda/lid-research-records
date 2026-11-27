Updated `docs/high-level-design.md` for Phase 1 to commit to self-hosted WebSockets:

```markdown
# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; the server assigns each committed edit a monotonic event revision and publishes committed changes to connected browsers over self-hosted WebSockets.

Delivery, change storage, and browser recovery are designed together around this choice: the change store provides replayable revisions and reliable publication, delivery manages WebSocket sessions and fan-out, and browser sync handles WebSocket subscriptions, reconnects, and revision catch-up.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns revision history, replayable revision queries, and reliable publication of committed changes.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns WebSocket session management, subscription authorization, and fan-out of committed changes.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns WebSocket subscription, reconnect handling, and revision catch-up.

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
- **Self-hosted WebSockets for change delivery.** Committed changes are pushed to browsers over self-hosted WebSockets, requiring replayable revisions and reliable publication in the change store, session management in delivery, and reconnect/catch-up logic in browsers. Five-second HTTPS polling (simpler stateless operation, but repeated reads and several seconds of lag) and a hosted realtime service (lower connection-management burden, but recurring fees and provider coupling) were rejected to get fast updates without vendor lock-in, accepting responsibility for connection capacity and reconnect operations.
```

**Before we move to Phase 2 for the three nodes (`change-store`, `delivery`, `browser-sync`):**

1. **HLD review:** Does `docs/high-level-design.md` look right, or would you like any changes (including any new tenets)?
2. **Decision doc offer:** Because all three delivery options met the 15-second freshness goal with competing tradeoffs (latency, operational burden, vendor cost/coupling) and three downstream nodes are being sized around this choice, a cold reader could re-litigate it. Would you like me to record this in a standalone decision doc (`docs/decisions/change-delivery-approach.md`) linked from `Key Design Decisions`, or keep just the `Key Design Decisions` entry above?
3. **Adjacent segment note:** `docs/intent/access/access-design.md` still refers to "the still-open change-delivery approach." Would you like me to update that wording as well, or leave the `access` segment untouched?