Phase 1 (HLD) is updated. Here is the full revised HLD:

---

# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Committed changes reach browsers over self-hosted WebSockets: the server holds a socket session per connected browser, the change store records every committed edit as a replayable revision, and delivery publishes each revision to connected sessions as it commits. A browser whose socket drops reconnects and catches up from the last revision it received.

Change storage, delivery, and browser recovery are designed together around this mechanism: the change store keeps the revision history that replay reads, delivery owns socket capacity and publication reliability, and browser sync owns reconnect and catch-up.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Replayable revision history, read indexes, and the durable record delivery publishes from.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns WebSocket session capacity and reliable publication of committed revisions to connected browsers.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns subscription over the delivery socket, reconnect after a dropped connection, and catch-up from the last received revision.

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
- **Self-hosted WebSockets for change delivery.** Five-second HTTPS polling was rejected for its repeated reads and seconds of lag despite simpler stateless operation. A hosted realtime service was rejected for recurring fees and provider coupling despite needing fewer connection operations. Self-hosted sockets deliver fast updates without a realtime vendor; the accepted cost is owning connection capacity and reconnect operations.

---

Three things before I proceed to the three nodes:

1. **Approve or amend the HLD above** — any edits you want, numbered feedback preferred.
2. **Decision doc offer (once):** this choice — three credible options traded on ops burden, latency, and vendor coupling, with three design nodes about to be sized around it — clears the bar for a full decision doc at `docs/decisions/`. The Key Design Decisions row is already recorded either way. Want the doc, or row only?
3. **Cross-segment cascade flag:** `docs/intent/access/access-design.md` still says authorization is "independent of the still-open change-delivery approach." Fix that phrase now as part of this change, or leave it for a later pass?

Once you approve, I'll start the change-store, delivery, and browser-sync LLDs.