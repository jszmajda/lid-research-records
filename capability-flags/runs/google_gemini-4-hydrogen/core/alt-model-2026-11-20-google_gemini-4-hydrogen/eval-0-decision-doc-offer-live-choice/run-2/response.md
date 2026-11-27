Updated `docs/high-level-design.md` for self-hosted WebSockets:

```markdown
# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board and receive committed changes over self-hosted WebSockets.

Change storage, delivery, and browser recovery are designed around self-hosted WebSockets: the change store maintains replayable revisions and reliable publication, delivery manages WebSocket sessions and fan-out, and browsers implement reconnect and revision catch-up logic.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns authoritative revision history, replayable revision queries, and reliable publication for committed changes.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns self-hosted WebSocket sessions, subscription authorization, and live change fan-out.
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
- **Self-hosted WebSockets for change delivery.** Connected browsers receive committed changes over self-hosted WebSockets, accepting server-side connection management and browser reconnect/catch-up complexity to achieve fast updates without realtime vendor lock-in or recurring provider fees. Five-second HTTPS polling was rejected because it adds lag and repeated read load; a hosted realtime service was rejected to avoid recurring fees and provider coupling.
```

Before moving to Phase 2 for `change-store`, `delivery`, and `browser-sync`, please review and confirm:

1. **HLD approval:** Does the updated HLD match your intent?
2. **Decision doc offer:** Because three credible delivery options were weighed against multiple criteria (latency, connection/reconnect ops, vendor coupling/fees) and three downstream nodes will be sized around the result, a cold reader could question why WebSockets were chosen when 5-second polling also meets the 15-second goal. Would you like me to record this in a full decision doc at `docs/decisions/change-delivery.md` (linked from `Key Design Decisions`), or keep just the `Key Design Decisions` entry above?
3. **Tenets:** Should we keep the existing four tenets as-is, or add a tie-breaker tenet (for example, preferring vendor independence or fast updates over lower operational burden when those trade off)?
4. **Adjacent segment note (`access`):** `docs/intent/access/access-design.md` (line 10) still refers to `"the still-open change-delivery approach"`. Should I update that line to reflect the settled WebSocket approach before we draft the three new nodes?