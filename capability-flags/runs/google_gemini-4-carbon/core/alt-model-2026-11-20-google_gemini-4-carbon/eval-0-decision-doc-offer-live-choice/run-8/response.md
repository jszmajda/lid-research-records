`docs/high-level-design.md` has been updated for Phase 1 to reflect self-hosted WebSockets as the current architecture. Here is the updated HLD in full for review:

```markdown
# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; the server assigns each committed edit an authoritative event revision, and browsers display a revisioned view of the board. Committed changes reach connected browsers over self-hosted WebSockets.

Change storage, socket delivery, and browser recovery coordinate around event revisions. The change store persists replayable revisions and reliably publishes committed edits to delivery; delivery manages WebSocket sessions and streams revisions to subscribed browsers; and browsers maintain the socket connection, surface connectivity losses, and reconnect with revision-based catch-up after interruptions.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Authorizes actions against server-side event assignments at the HTTPS boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns authoritative event revisions, replayable revision history, board snapshot reads, and reliable publication of committed changes to delivery.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns self-hosted WebSocket sessions, subscription credentials, and streaming committed revisions to connected browsers.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns WebSocket connection management, reconnect and revision catch-up, and visible connectivity status in the browser.

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
- **Change delivery over self-hosted WebSockets.** Committed revisions stream to browsers over self-hosted WebSocket sessions, backed by replayable revision storage, reliable publication from the change store, and browser reconnect/catch-up logic. Although the required freshness target is 15 seconds and managed infrastructure is permitted, self-hosted WebSockets was chosen to deliver fast push updates without recurring realtime vendor fees or provider coupling, accepting ownership of connection capacity and reconnect operations. Five-second HTTPS polling was rejected despite simpler stateless operation because it adds multi-second lag and repeated cursor reads across up to 800 browsers; a hosted realtime service was rejected despite lower connection-management effort because it introduces recurring fees and couples delivery to a provider's subscription model.
```

Before we move to Phase 2 for `change-store`, `delivery`, and `browser-sync`, please confirm a few Phase 1 items:

1. **HLD review**: Does the updated `docs/high-level-design.md` match your intent as written?
2. **Decision doc vs. HLD entry**: Because all three options clear the 15-second freshness target, managed infrastructure is permitted by the tenets, and three downstream nodes are about to be sized around this trade-off, a future cold reader could reasonably question why MarketBoard owns stateful WebSocket infrastructure instead of 5-second polling or a hosted realtime service. Would you like me to record a standalone decision doc at `docs/decisions/change-delivery.md` (linked from `Key Design Decisions`), or keep just the `Key Design Decisions` entry in the HLD?
3. **Tenets**: Do you want to keep "accept extra operational work over vendor coupling" scoped to this realtime-delivery decision (leaving the fourth tenet as-is), or add a general tie-breaker under `## Tenets` — e.g., *Prefer owning runtime state over coupling core board flows to vendor-specific protocols, even when managed infrastructure is permitted*?
4. **Sibling cascade (`access`) & Phase 2 order**: `docs/intent/access/access-design.md` still refers to the "still-open change-delivery approach" (its specs in `access-specs.md` are unaffected since socket subscription credentials belong to `delivery`). Should I update that wording in `access-design.md` first, and which of the three new nodes (`change-store`, `delivery`, `browser-sync`) would you like to draft first?