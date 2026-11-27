I updated `docs/high-level-design.md` for self-hosted WebSockets (`Approach`, `Architecture`, and `Key Design Decisions`). Here is the updated HLD for Phase 1 review:

```markdown
# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS, and browsers display a revisioned view of the board updated over self-hosted WebSockets.

Change storage, delivery, and browser recovery are designed around this WebSocket boundary: the change store persists replayable event revisions and supports reliable publication of committed edits; the delivery service manages WebSocket sessions and pushes revisions to subscribed browsers; browsers maintain live subscriptions, surface connectivity failures, and catch up from their last seen revision on reconnect.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns authoritative revision history, replayable revision queries, and reliable publication of committed changes.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns self-hosted WebSocket sessions, subscription authorization, live fan-out, and replay delivery.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns WebSocket subscriptions, visible connection state, reconnect handling, and revision catch-up.

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
- **Self-hosted WebSockets for change delivery.** Committed edits are pushed to connected browsers over self-hosted WebSockets rather than five-second HTTPS polling or a hosted realtime service. Polling would simplify stateless operations at the cost of repeated reads and multi-second lag; a hosted realtime service would reduce connection operations at the cost of recurring vendor fees and provider coupling. Self-hosted WebSockets deliver fast updates without vendor coupling, accepting the operational cost of managing connection capacity and reconnect/catch-up behavior across the change store, delivery, and browser sync components.
```

Before moving to the three downstream nodes (`change-store`, `delivery`, `browser-sync`):

1. **Decision doc offer:** Because all three options met the 15-second freshness goal, the tenets permit managed infrastructure, and three downstream nodes are being sized around this trade-off, a cold reader could easily re-litigate why MarketBoard took on WebSocket connection and reconnect operations instead of polling or a hosted realtime service. Would you like me to record this as a standalone project-level decision doc at `docs/decisions/change-delivery.md` (linked from `Key Design Decisions`), or keep just the `Key Design Decisions` entry in the HLD?
2. **Tenets check:** Should avoiding vendor coupling / recurring per-connection fees at the cost of owning more operations stay specific to this delivery choice, or be captured as a project-level tenet?
3. **Adjacent segment note:** `docs/intent/access/access-design.md` (line 10) still refers to "the still-open change-delivery approach." Its behavior and specs (`ACCESS-001`–`ACCESS-004`) are unaffected; let me know if you want that phrasing updated as well.

Please review the HLD and let me know your call on these before we proceed to Phase 2.