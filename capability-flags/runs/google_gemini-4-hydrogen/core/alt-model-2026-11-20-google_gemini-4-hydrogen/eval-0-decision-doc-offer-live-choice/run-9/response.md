Updated `docs/high-level-design.md` (Phase 1 — HLD) to commit to self-hosted WebSockets:

```markdown
# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Committed changes are pushed to connected browsers over self-hosted WebSockets.

Delivery, change storage, and browser recovery are designed around this choice: the change store provides replayable revisions and reliable publication, the delivery service manages WebSocket sessions, and browsers handle reconnect and catch-up.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns revision history, replayable revision queries, and reliable publication to delivery.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns self-hosted WebSocket sessions and pushing committed changes to connected browsers.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns WebSocket subscription, reconnect, and revision catch-up.

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
- **Self-hosted WebSockets for change delivery.** Committed changes are pushed to browsers over self-hosted WebSocket connections, accepting connection capacity and reconnect operations in exchange for fast updates without recurring realtime vendor fees or provider coupling. Five-second HTTPS polling (simpler stateless operation, but repeated reads and several seconds of lag) and a hosted realtime service (less connection ops, but recurring fees and provider coupling) were rejected.
```

Before we move to Phase 2 for the three downstream nodes (`change-store`, `delivery`, `browser-sync`):

1. **HLD review:** Does `docs/high-level-design.md` look right, or would you like any changes?
2. **Decision doc offer:** Because this choice trades multiple criteria across three credible options and sizes three downstream nodes, a future reader might re-litigate why WebSockets beat 5-second polling or a hosted service. Would you like me to record a full decision doc at `docs/decisions/change-delivery.md` (linked from `Key Design Decisions`), or leave it as the `Key Design Decisions` entry above?
3. **Adjacent segment note:** `docs/intent/access/access-design.md` still refers to "the still-open change-delivery approach" in its Context section — should I update that phrasing too, and which of the three nodes (`change-store`, `delivery`, or `browser-sync`) would you like to draft first?