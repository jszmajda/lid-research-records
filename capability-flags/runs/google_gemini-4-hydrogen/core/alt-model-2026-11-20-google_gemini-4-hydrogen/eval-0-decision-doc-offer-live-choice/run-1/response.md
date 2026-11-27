Updated `docs/high-level-design.md` for Phase 1 to commit to self-hosted WebSockets:

```markdown
# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS, and committed changes are pushed to connected browsers over self-hosted WebSockets so browsers display a fast, revisioned view of the board without depending on a third-party realtime provider.

Change storage, delivery, and browser recovery are designed around self-hosted WebSockets: the change store maintains replayable revisions and reliable publication, delivery manages WebSocket sessions and connection capacity, and browsers implement reconnect and revision catch-up logic.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns revision history, replayable change records, and reliable publication for WebSocket delivery.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns self-hosted WebSocket sessions, subscription authorization, and change fan-out.
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
- **Self-hosted WebSockets for change delivery.** Committed edits are pushed over self-hosted WebSockets rather than five-second HTTPS polling or a hosted realtime service. Five-second polling offers simpler stateless operation but adds repeated reads and a few seconds of lag; a hosted realtime service reduces connection-management operations but introduces recurring vendor fees and provider coupling. Self-hosted WebSockets provide fast updates without vendor lock-in, in exchange for owning connection capacity, reliable publication, and browser reconnect/catch-up behavior.
```

Before proceeding to Phase 2 for `change-store`, `delivery`, and `browser-sync`:

1. **Decision doc offer:** Because the three delivery options trade off latency, connection-management ops, and vendor coupling—and the three downstream nodes will be sized around this choice—a cold reader may re-examine it later. Would you like me to record this as a full decision doc at `docs/decisions/change-delivery.md` (and link it from `Key Design Decisions`), or keep the `Key Design Decisions` entry as-is?
2. **Cross-segment note:** `docs/intent/access/access-design.md` still refers to "the still-open change-delivery approach" in its Context section. Should I update that line to reflect the settled WebSocket approach, or leave `access` untouched?
3. **Phase 1 approval:** Please confirm you approve the updated HLD (and which of the three nodes you'd like to draft first in Phase 2).