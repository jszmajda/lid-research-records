`docs/high-level-design.md` is updated for self-hosted WebSockets. Here is the full Phase 1 HLD for review:

```markdown
# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; the server commits each edit with an authoritative event revision and pushes committed updates to connected browsers over self-hosted WebSockets. Browsers display a revisioned view of the board.

Change storage, delivery, and browser synchronization coordinate around ordered event revisions. The change store records replayable revisions and reliably publishes committed edits to delivery; delivery manages WebSocket sessions, event subscriptions, and connection capacity; and browsers surface connection loss and catch up to the latest board revision when reconnecting.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns authoritative event revisions, replayable revision history, board reads, and reliable publication of committed changes to delivery.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns self-hosted WebSocket sessions, subscription authorization, connection capacity, and live revision fan-out.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns browser WebSocket subscriptions, disconnect visibility, reconnect handling, and revision catch-up.

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
- **Self-hosted WebSockets for change delivery.** Committed event revisions push to connected browsers over server-managed WebSocket sessions, backed by replayable revisions in the change store and reconnect catch-up in the browser. This accepts owning connection capacity and reconnect operations in exchange for fast updates without tying the board to a realtime provider. Five-second HTTPS polling was rejected despite simpler stateless operation because of repeated read load across up to 800 simultaneous browsers and multi-second delivery lag; a hosted realtime service was rejected despite lower connection-management overhead because of recurring fees and provider coupling.
```

Before we move to Phase 2 for `change-store`, `delivery`, and `browser-sync`, please confirm how you'd like to handle three points:

1. **Decision doc vs. HLD entry:** Because polling, self-hosted WebSockets, and a hosted realtime service all satisfy the 15-second freshness goal with live trade-offs across latency, operational ownership, and vendor coupling—and three child nodes are about to be sized around this choice—a cold reader could plausibly re-litigate it. Would you like me to expand this into a standalone decision doc at `docs/decisions/change-delivery.md` (linked from `Key Design Decisions`), or keep the `Key Design Decisions` entry above as the sole record?
2. **Tenet check:** Here you leaned toward owning operational work rather than coupling the board to a realtime vendor, while the existing fourth tenet leaves self-hosted and managed infrastructure on equal footing. Should that preference stay specific to realtime delivery (still welcoming managed services for concerns like storage), or should we add a one-line tie-breaker under `## Tenets` (for example: *Prefer owning standard-protocol operations over coupling core board flows to vendor-specific services*)?
3. **Adjacent `access` prose:** `docs/intent/access/access-design.md` still refers to *"the still-open change-delivery approach"* in its `## Context` section (none of `ACCESS-001`–`ACCESS-004` are affected, and WebSocket subscription credentials remain in `delivery`). Should I clean up that stale phrase in `access-design.md` before we draft the three new LLDs?

Does this HLD update look good to approve?