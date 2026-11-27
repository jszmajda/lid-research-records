I have updated `docs/high-level-design.md` for Phase 1 to commit to self-hosted WebSockets and reflect the resulting responsibilities across `change-store`, `delivery`, and `browser-sync`:

```markdown
# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board and receive committed changes over self-hosted WebSockets.

The change store records an ordered revision history so committed changes can be broadcast as they land and replayed when a socket reconnects. The delivery service manages WebSocket sessions and fans out committed revisions to subscribed browsers, and browser sync handles live subscription, reconnects, and revision catch-up.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Authorizes HTTPS edit commands and board snapshot reads.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Stores ordered event revisions, supports snapshot and replay reads, and publishes committed revisions for WebSocket fan-out.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Manages self-hosted WebSocket sessions and broadcasts committed revisions to subscribed browsers.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Manages the browser's WebSocket subscription, connection state visibility, reconnects, and revision catch-up.

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
- **Self-hosted WebSockets for change delivery.** Committed revisions are pushed to connected browsers over self-hosted WebSockets, backed by replayable revisions in the change store and browser reconnect/catch-up logic. Five-second HTTPS polling (simpler stateless operation, but higher read load and multi-second lag) and a hosted realtime service (lower connection-ops burden, but recurring vendor fees and provider coupling) were rejected: self-hosted WebSockets deliver fast updates without tying the board to a realtime vendor, accepting connection-capacity and reconnect operations in exchange.
```

Before moving to Phase 2 for the three downstream nodes (`change-store`, `delivery`, and `browser-sync`), please review and let me know:

1. **Decision recording**: Because all three options meet the 15-second freshness goal and trade off latency, operational burden, and vendor coupling while sizing the three downstream nodes, this choice will stay live for a cold reader. Would you like me to record it as a standalone decision doc at `docs/decisions/change-delivery-transport.md` (linked from `## Key Design Decisions`), or keep the entry in `## Key Design Decisions` above as the sole record?
2. **Tenet check**: Your selection leans on avoiding realtime vendor lock-in and recurring fees at the cost of owning connection operations, whereas the existing fourth tenet states only *"Self-hosted and managed infrastructure are both permitted."* Would you like to add or refine a tenet capturing that preference (e.g., *"Own core runtime paths over recurring third-party service coupling when operational complexity is bounded"*), or keep the existing tenets as-is?
3. **Note on `access`**: `docs/intent/access/access-design.md` currently mentions *"the still-open change-delivery approach"* in its `## Context` section. Per cross-segment cascade discipline, I left `access` untouched for now — let me know if you want to update that phrasing as well.

Does this HLD update look good to proceed?