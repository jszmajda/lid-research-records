**Phase 1 — HLD updated.** Full text of `docs/high-level-design.md` after the change:

---

# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Committed changes reach browsers over self-hosted WebSockets: the change store keeps a replayable revision history and publishes each committed revision, delivery holds socket sessions and publishes revisions to connected browsers, and browser sync keeps its subscription alive through reconnect and catch-up against that history.

Delivery, change storage, and browser recovery are designed together around this mechanism. The store must support replay from any revision a browser last saw; delivery must own connection capacity and publish reliably to every open session; browser sync must reconnect and catch up without mistaking a dropped connection for an unchanged board. The trade accepted: this operational work is ours to run, in exchange for fast updates with no realtime vendor's recurring fee or provider coupling. Fifteen-second freshness is met with margin; subsecond updates are a side effect, not a requirement.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns revision history, read indexes, and reliable publication of committed revisions to delivery.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns WebSocket session capacity, publication of committed revisions to connected browsers, and reconnect handling at the socket boundary.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns the browser's socket subscription, reconnect loop, and catch-up against the store's revision history.

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
- **Self-hosted WebSockets for change delivery.** Committed revisions push to browsers over sockets we run. Five-second HTTPS polling was rejected: it adds repeated reads and seconds of lag, and moves the work into cursor queries and a browser polling loop rather than eliminating it. A hosted realtime service was rejected: it reaches low latency with less connection operations work, but adds recurring fees and provider coupling. Self-hosted sockets accept connection capacity and reconnect operations as ours to own in exchange for fast updates without a realtime vendor.

---

**Two decisions for you before I proceed:**

1. **HLD review** — numbered feedback on the text above, or approve as-is.
2. **Decision doc offer** — this choice clears the bar for a standalone decision doc: three credible options weighed against multiple criteria, and the three nodes you want next will be sized around it. The HLD Key Design Decisions entry above is the light alternative. Accept a full decision doc (`docs/decisions/change-delivery-approach.md`), or record the entry only?
3. **Cascade note** — `docs/intent/access/access-design.md` still says authorization is "independent of the still-open change-delivery approach." Delivery is no longer open; the access node's substance doesn't otherwise change. Update that phrase as I move on?