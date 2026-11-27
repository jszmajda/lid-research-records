Phase 1 (HLD) is updated. I recorded the self-hosted WebSockets selection in `docs/high-level-design.md` — the Approach now commits to it, Architecture names each node's new responsibility, and Key Design Decisions captures the choice against the rejected polling and hosted options.

Updated `docs/high-level-design.md` in full:

```markdown
# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Committed changes reach connected browsers over self-hosted WebSockets, which gives fast updates without paying a realtime vendor. The project accepts ownership of connection capacity and reconnect behavior in exchange.

Delivery, change storage, and browser recovery are designed together around this choice: the change store retains replayable revisions and publishes them reliably, delivery manages socket sessions, and browsers reconnect and catch up from their last-known revision. Subsecond updates are useful but not required; the freshness goal below bounds the design.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns revision history, read indexes, and reliable publication of replayable revisions to delivery.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns WebSocket session management and publication of committed revisions to connected browsers.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns the subscription, reconnect, and catch-up behavior that recovers the latest board after a disconnection.

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
- **Committed changes over self-hosted WebSockets.** Delivery keeps fast updates without a realtime vendor bill, at the cost of owning connection capacity and reconnect behavior. Five-second HTTPS polling was rejected for its repeated reads and seconds of lag; a hosted realtime service was rejected for its recurring fees and provider coupling. All three meet the freshness goal, so the deciding trade-off is vendor independence against operational burden.
```

Coherence note: the written `access` node stays consistent — its note that subscription credentials belong to the delivery node still fits, now as socket-session management rather than a vendor subscription. The three downstream nodes (change store, delivery, browser sync) are left untouched per your instruction to do them next.

Two questions before we move on:

1. Approve this HLD update as-is?
2. This choice is likely to stay live for a cold reader (credible options traded against cost, latency, ops, and vendor coupling, with three nodes about to be sized around it). Want me to record it as a full decision doc under `docs/decisions/`, or is the Key Design Decisions entry enough?