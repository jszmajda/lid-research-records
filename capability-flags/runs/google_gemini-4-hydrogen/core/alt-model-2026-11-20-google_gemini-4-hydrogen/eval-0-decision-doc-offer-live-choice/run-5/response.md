Updated `docs/high-level-design.md` (Phase 1 — HLD) for the self-hosted WebSockets approach:

```markdown
# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS, and the server assigns each committed edit a single event revision and pushes updates to connected browsers over self-hosted WebSockets.

Delivery, change storage, and browser recovery are designed around this transport: the change store persists replayable event revisions and supports reliable publication; the delivery component manages WebSocket sessions and fan-out; and browser sync handles subscriptions, reconnects, and revision catch-up.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns replayable event revisions, read indexes, and reliable publication for WebSocket delivery.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns self-hosted WebSocket sessions, subscription routing, and fan-out of committed revisions.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns WebSocket subscription lifecycle, reconnect handling, and revision catch-up.

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
- **Self-hosted WebSockets for change delivery.** Committed revisions are pushed to browsers over self-hosted WebSockets rather than five-second HTTPS polling or a hosted realtime service. This provides fast updates without recurring realtime vendor fees or provider coupling, in exchange for owning WebSocket connection capacity, session management, and reconnect/catch-up logic in-house.
```

Before moving to Phase 2 for `change-store`, `delivery`, and `browser-sync`, please confirm:

1. **HLD approval:** Do you approve this Phase 1 update to `docs/high-level-design.md` (including whether any tenets should be added or adjusted)?
2. **Decision doc offer:** Because this choice trades multiple criteria across three credible options and sizes three downstream nodes, a cold reader could question why self-hosted WebSockets were chosen over 5-second polling or a hosted service. Would you like me to record it as a full decision doc at `docs/decisions/change-delivery.md` (and link it from `## Key Design Decisions`), or keep just the `## Key Design Decisions` entry?
3. **Adjacent segment note:** `docs/intent/access/access-design.md` still refers to "the still-open change-delivery approach" (line 10). Should I update that phrase as well, or leave `access` untouched?