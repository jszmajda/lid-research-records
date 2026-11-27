I updated the HLD for the self-hosted WebSockets choice. Pre-flight coherence check first: `access-design.md` / `access-specs.md` remain valid — that node already places delivery-specific subscription credentials in the delivery node, so the choice doesn't force a change there (ACCESS-001..004 untouched). Project is Full LID at v1.4.0, matching the installed plugin.

**Phase 1 output — `docs/high-level-design.md` (rewritten in place):**

```markdown
# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Committed changes reach browsers over self-hosted WebSocket connections: the server pushes each committed revision to the browsers watching that event, and a browser that missed revisions while disconnected catches up by asking for the revisions it missed.

Realtime delivery is operated by the project itself rather than purchased from a realtime vendor. The price of that choice is owned connection capacity and reconnect handling — the server tracks which browsers are connected, and browsers re-synchronize after a dropped connection. This buys updates that typically land well inside a second, without a recurring provider fee or a vendor between the board and its readers.

Delivery, change storage, and browser recovery are designed together around this choice: the change store keeps replayable revisions so a reconnecting browser can be brought up to date, the delivery node owns WebSocket sessions, and the browser node owns reconnect and catch-up.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns the revision log, the board read index, and the publication outbox that makes a committed revision available to delivery. Revisions must be replayable so a reconnecting browser can be brought up to date.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns WebSocket sessions: accepting and authorizing connections, pushing committed revisions to the browsers watching an event, and tracking the last revision each session has seen.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns the browser side of the subscription: holding the socket open, applying pushed revisions, and reconnecting and catching up after a disconnection.

## Tenets

- A committed edit has one authoritative event revision regardless of its delivery route.
- Connectivity failures must be visible, not mistaken for an unchanged board.
- Commands use server-side authorization; browser state is not evidence of permission.
- Self-hosted and managed infrastructure are both permitted. Event updates contain stall IDs and operational statuses, not customer records.
- Own the operations over vendor coupling. When a managed realtime service would deliver the same board updates with less work on our side, prefer operating the service ourselves.

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
- **Self-hosted WebSockets for change delivery.** Committed revisions are pushed over WebSocket connections that the project operates. Five-second HTTPS polling was rejected: it repeats reads, adds seconds of lag, and keeps delivery stateless at the cost of the freshness the board is for. A hosted realtime service was rejected: it adds recurring fees and provider coupling, and vendor payments are a non-goal. The accepted cost is owned connection capacity and reconnect handling, plus replayable revisions in the change store to support catch-up.
- **Socket connections are authorized server-side.** A browser receives an event's revisions only over a connection the server has authorized for that event, using the same session identity and event assignments as the command API. Per-event subscription tokens and per-socket authorization were both considered; server-side authorization at connect time was chosen so that access rules apply in one place. Delivery is the node that owns this, but the constraint is project-wide.
```

Stopping here for your review before I touch the three nodes (change-store, delivery, browser-sync). Four things I need from you:

1. **Tenet:** I added "Own the operations over vendor coupling" (your stated reason for choosing sockets). Keep it?
2. **Possible second tenet:** "Prefer a reconnectable, stateful session over a stateless read when both can serve the board" — its reverse (prefer stateless for simpler ops) is a choice another project would make, and it will decide several questions in the three nodes. Add it, or is it only true for this one decision?
3. **Freshness goal:** I left the commitment at "within 15 seconds" even though pushes land subsecond, because tightening it is your call, not mine. Keep 15s, or tighten it?
4. **Decision doc:** the delivery choice stays live for a cold reader — three credible options, and the three nodes will be sized around it. Want a full decision doc at `docs/decisions/delivery-approach.md`, or is the Key Design Decisions entry enough?