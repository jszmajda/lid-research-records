I have updated `docs/high-level-design.md` to reflect the self-hosted WebSockets approach (read cold as current intent, without transitional framing):

```markdown
# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board and receive committed changes over self-hosted WebSockets.

Delivery, change storage, and browser recovery work together around this transport: the change store persists replayable event revisions and reliably publishes committed edits; the delivery service manages WebSocket sessions and pushes revisions to subscribed browsers; and browsers maintain the socket connection, surface connectivity loss, and catch up from their last seen revision on reconnect.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Authorizes HTTPS commands and snapshot reads against current server-side event assignments.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns revision history, replay queries for reconnecting browsers, and reliable publication of committed edits to delivery.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns WebSocket session lifecycle, event subscriptions, and pushing committed revisions to connected browsers.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns WebSocket subscription, connection-state visibility, reconnect, and revision catch-up.

## Tenets

- A committed edit has one authoritative event revision regardless of its delivery route.
- Connectivity failures must be visible, not mistaken for an unchanged board.
- Commands use server-side authorization; browser state is not evidence of permission.
- Prefer owning operational work over recurring realtime vendor fees or external provider coupling when low-latency delivery is achievable in-house.

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
- **Self-hosted WebSockets for change delivery.** Committed revisions are pushed to browsers over self-hosted WebSocket sessions, backed by replayable revisions in the change store and browser reconnect/catch-up logic. Five-second HTTPS polling was rejected because although stateless and operationally simpler, it adds multi-second lag and repeated read load across 800 browsers. A hosted realtime service was rejected because recurring vendor fees and provider coupling outweigh the reduced connection-management burden.
```

Before we move to Phase 2 for the leaf nodes, please review and let me know on these points:

1. **Decision doc vs. HLD entry**: Because the delivery transport choice trades three credible options across latency, operational complexity, and vendor coupling—and sizes `change-store`, `delivery`, and `browser-sync`—would you like to record it in a full decision doc at `docs/decisions/change-delivery-transport.md` (linked from `## Key Design Decisions`), or keep the summary entry in `## Key Design Decisions` above?
2. **Tenet check**: I replaced the prior neutral infrastructure bullet with the tie-breaker you expressed (*"Prefer owning operational work over recurring realtime vendor fees or external provider coupling when low-latency delivery is achievable in-house"*). Would you like to keep that tenet as phrased, adjust it, or surface any additional tie-breakers (e.g., around replay vs. full-snapshot fallback on reconnect)?
3. **Cascade note (`access`)**: `docs/intent/access/access-design.md` currently includes one sentence referring to "the still-open change-delivery approach." Once you approve the HLD, should we touch `access-design.md` to remove that stale phrasing, or go straight to drafting `change-store`, `delivery`, and `browser-sync` (and which of the three would you like to tackle first)?