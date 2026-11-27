Updated `docs/high-level-design.md` for the self-hosted WebSockets approach (Phase 1 — HLD):

```markdown
# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; the server assigns each committed edit an event revision and pushes committed updates to connected browsers over self-hosted WebSockets. Browsers display a revisioned view of the board.

Change storage, socket delivery, and browser recovery coordinate around event revisions. The change store persists replayable revisions and ensures reliable publication of committed edits; the delivery component manages WebSocket sessions and fans out revisions to subscribed browsers; and browsers maintain subscriptions, surface connectivity state, and catch up on missed revisions when reconnecting.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Authorizes HTTPS commands and snapshot reads against session state and current event assignments.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Persists replayable event revisions for retention and recovery, and ensures reliable publication of committed edits.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Handles subscription credentials, manages self-hosted WebSocket sessions, and fans out committed revisions to connected browsers.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Maintains the WebSocket subscription, surfaces connectivity failures, and runs reconnect and revision catch-up logic.

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
- **Self-hosted WebSockets for change delivery.** Committed revisions are pushed to browsers over self-hosted WebSockets, paired with replayable revisions and reliable publication in the change store and reconnect/catch-up logic in the browser. This gives connected staff fast updates without recurring realtime vendor fees or provider coupling, in exchange for owning socket capacity and reconnection operations. Five-second HTTPS polling was rejected despite simpler stateless operation because of repeated read load across up to 800 browsers and multi-second delivery lag; a hosted realtime service was rejected to avoid recurring provider fees and coupling board delivery to an external vendor.
```

Before moving to Phase 2 on the LLDs, please review the HLD update and let me know on four points:

1. **Decision doc vs. HLD entry**: Because all three delivery options satisfy the 15-second freshness goal and infrastructure tenet while trading latency, operational burden, and vendor coupling against each other — and `change-store`, `delivery`, and `browser-sync` will all be shaped around the result — a cold reader could plausibly revisit why polling or a hosted service wasn't chosen. Would you like a standalone decision doc at `docs/decisions/change-delivery.md` (linked from `Key Design Decisions`), or is the `Key Design Decisions` entry above sufficient?
2. **Tenet check**: Your rationale leans toward owning bounded operational work rather than coupling to a third-party service. Should that remain specific to realtime delivery (keeping the existing tenet that self-hosted and managed infrastructure are both permitted), or should we add a one-line tenet — e.g., *"Prefer self-operated standard protocols over vendor-specific services when operational load is bounded"* — to guide upcoming `change-store` and `delivery` choices?
3. **Cross-segment cascade (`access`)**: `docs/intent/access/access-design.md` still refers to the "still-open change-delivery approach" and says subscription credentials "will belong to the delivery node." Should I clean up that phrasing when we move into Phase 2?
4. **Approval & next node**: Does the HLD look good to approve, and which of the three nodes (`change-store`, `delivery`, or `browser-sync`) would you like to draft first?