## Phase 1 — HLD revised for self-hosted WebSockets

`docs/high-level-design.md` now reads:

# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Committed changes reach connected browsers over self-hosted WebSockets: the server publishes each committed event revision to persistent socket sessions, and browsers that rejoin after a disconnect catch up from the retained revisions.

Self-hosted sockets were chosen over five-second HTTPS polling and a hosted realtime service. Polling is the simplest stateless operation but adds a few seconds of lag and repeated reads. A hosted service reaches low latency with less connection operations work but carries recurring fees and provider coupling. Self-hosting accepts ownership of connection capacity and reconnect behavior in exchange for fast updates without a realtime vendor dependency.

Delivery, change storage, and browser recovery are designed together. The store retains replayable event revisions; delivery owns socket sessions and publication; browsers own reconnect and catch-up.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns revision history, read indexes, and retention of replayable revisions for socket catch-up.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns socket sessions, connection capacity, publication of committed revisions, and server-side replay support for reconnecting browsers.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns the socket subscription, reconnect, and catch-up behavior.

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
- **Self-hosted WebSockets for delivery.** The server publishes committed revisions over persistent socket sessions, owning connection capacity and replay; browsers own reconnect and catch-up. Five-second HTTPS polling was rejected for its lag and repeated reads. A hosted realtime service was rejected for recurring fees and provider coupling. Self-hosting accepts the connection and reconnect operations burden to get fast updates without a realtime vendor.

---

I have three numbered items for you before Phase 2 (the three design nodes):

1. **Approve the HLD revision?** Feedback as numbered items, or approve to proceed.
2. **Decision doc or row only?** This choice will stay live for a cold reader (three credible options traded across cost, coupling, and ops burden, with three nodes about to be sized around it). I can record it as a full decision doc under `docs/decisions/` linked from the HLD, or leave the Key Design Decisions entry as the only record.
3. **Cascade into Access?** `docs/intent/access/access-design.md:10` still says authorization is "independent of the still-open change-delivery approach" — now stale. May I update that one sentence to read "independent of the chosen WebSocket delivery approach"? It crosses into the access segment, so I'm asking before propagating.

Then we'll take change store, delivery, and browser sync in turn.