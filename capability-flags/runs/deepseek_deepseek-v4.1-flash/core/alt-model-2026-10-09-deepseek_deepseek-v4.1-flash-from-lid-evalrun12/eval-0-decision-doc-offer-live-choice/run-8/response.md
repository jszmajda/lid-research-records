Updated `docs/high-level-design.md` to commit to self-hosted WebSockets. Here is the phase output in full:

---

# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Committed changes are delivered to browsers over self-hosted WebSockets, giving connected browsers fast updates without a realtime vendor or recurring per-connection fees.

Delivery, change storage, and browser recovery are designed together around this route. The change store keeps replayable event revisions so a reconnecting browser can catch up; delivery manages socket sessions and reliable publication of committed changes; browser sync owns subscription, reconnect, and catch-up behavior. Subsecond updates are useful, but the freshness target remains 15 seconds.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Revision history and read indexes, plus a replayable revision path so a reconnecting browser can catch up.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns socket sessions and reliable publication of committed changes to connected browsers.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns subscription, reconnect, and catch-up behavior over the socket connection.

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
- **Self-hosted WebSockets for change delivery.** Committed changes reach browsers over server-managed socket sessions rather than five-second HTTPS polling or a hosted realtime service. Polling is the simplest stateless operation and meets the freshness target, but adds repeated reads and a few seconds of lag; a hosted service offers the quickest low-latency path with less connection work, but brings recurring fees and provider coupling. Self-hosted sockets keep updates fast without tying the board to a realtime vendor, at the cost of owning connection capacity, reliable publication, and reconnect/catch-up behavior.

---

**STOP — please review the HLD above and approve, or give numbered feedback.**

Two things I need your ruling on:

1. **Stale cross-segment reference.** `docs/intent/access/access-design.md` says authorization "is independent of the still-open change-delivery approach." That's in the *access* segment, and the approach is no longer open. The substantive claim stays true, but "still-open" is now stale. Cascade across a segment boundary needs your say-so — shall I propagate a one-line fix into access this session, or hold it until you work that node?

2. **Recording this decision.** The delivery choice traded three credible options against cost, ops burden, latency, and vendor coupling, and the change-store/delivery/browser-sync nodes will be sized around it — so a cold reader could plausibly re-litigate it. I've recorded it as a Key Design Decisions entry (the default). Want me to also write a full decision doc under `docs/decisions/`, or is the entry enough?

Once you approve and answer those, we can start the three nodes (change-store, delivery, browser-sync).