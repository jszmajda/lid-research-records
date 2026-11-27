Updated `docs/high-level-design.md` for Phase 1. Here is the revised HLD in full for review:

```markdown
# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; committed changes are pushed to subscribed browsers over self-hosted WebSockets, and browsers display a revisioned view of the board.

Change storage, delivery, and browser recovery work together around ordered event revisions. The change store persists each committed edit as the next event revision, retains replayable revision history, and publishes committed revisions reliably to delivery. The delivery component manages WebSocket sessions and streams revisions to connected browsers. Browsers maintain socket subscriptions, surface disconnections visibly, and catch up to the latest event revision on reconnect.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns authoritative event revisions, board snapshots, replayable revision history, and reliable publication of committed changes.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns self-hosted WebSocket sessions, subscription credentials, and live delivery and replay of committed revisions.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns browser WebSocket subscriptions, visible connectivity state, reconnect, and revision catch-up.

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
- **Self-hosted WebSockets for change delivery.** Committed event revisions are pushed to browsers over server-managed WebSocket sessions, accepting connection-capacity and reconnect operations work in exchange for low-latency updates without recurring realtime-vendor fees or provider coupling. Five-second HTTPS polling was rejected: although stateless and sufficient for the 15-second freshness goal, it adds several seconds of lag and repeated read load across simultaneous browsers. A hosted realtime service was rejected: although permitted by the infrastructure tenet and lighter on connection operations, it introduces recurring vendor costs and couples delivery and browser sync to a third-party subscription model.
```

Before moving to Phase 2 on the LLDs, please let me know on these points alongside your review of the HLD:

1. **Decision doc vs. HLD entry**: Because all three options satisfy the 15-second freshness goal and existing tenets—trading latency, connection/reconnect ops, and vendor coupling against each other while sizing `change-store`, `delivery`, and `browser-sync`—a cold reader could reasonably revisit polling or hosted pub/sub later. Would you like to capture this as a standalone decision doc at `docs/decisions/change-delivery.md` (linked from `Key Design Decisions`), or is the `Key Design Decisions` entry above sufficient?
2. **Tenet check**: Should "accepting self-owned operational work over vendor coupling and recurring per-connection/message fees" remain specific to this delivery decision (leaving Tenet 4 as-is), or should we record a general tie-breaker tenet leaning toward self-owned operations over third-party service coupling for downstream choices in `change-store` and `delivery` as well?
3. **Sibling cascade (`access`) and next node**: `docs/intent/access/access-design.md` still refers to "the still-open change-delivery approach" (and future-tense "will belong to the delivery node"). Should I clean up that prose in `access-design.md` once you approve the HLD, and which of the three nodes (`change-store`, `delivery`, `browser-sync`) would you like to draft first?